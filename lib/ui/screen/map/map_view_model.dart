import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:food_gram_app/core/config/constants/map_overlay_constants.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/providers/map_category_filter_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/ui/screen/map/components/map_heatmap_layer.dart';
import 'package:food_gram_app/ui/screen/map/components/map_pin_data.dart';
import 'package:food_gram_app/ui/screen/map/components/map_pin_image_loader.dart';
import 'package:food_gram_app/ui/screen/map/components/map_pin_style.dart';
import 'package:food_gram_app/ui/screen/map/components/map_runtime_layer.dart';
import 'package:food_gram_app/ui/screen/map/map_state.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:screenshot/screenshot.dart';

part 'map_view_model.g.dart';

/// マップ投稿ピンの表示方針:
/// - ズーム < 8 → 赤点（CircleLayer）
/// - ズーム >= 8 → カスタムピン（Annotation）
/// - ランタイム SymbolLayer は使わない（端末で消える問題があるため）
@riverpod
class MapViewModel extends _$MapViewModel {
  @override
  MapState build() {
    _pinLoader.preload();
    return const MapState();
  }

  final screenshotController = ScreenshotController();
  MapPinImageLoader? _pinLoaderHolder;
  MapPinImageLoader get _pinLoader {
    _pinLoaderHolder ??= MapPinImageLoader(screenshotController);
    return _pinLoaderHolder!;
  }

  List<Posts>? _cachedPosts;
  Map<String, String>? _cachedImageKeys;
  bool _heatmapLayerAdded = false;
  bool _dotsLayerReady = false;
  bool _tapHandlerRegistered = false;
  bool _isHandlingPinTap = false;
  void Function(List<Posts> posts)? _onPinTapHandler;

  /// 地名検索で選んだ地点（スプライト marker_11）
  LatLng? _searchResultPinLatLng;

  /// null = 未同期。true=赤点モード / false=ピンモード
  bool? _isDotMode;

  /// heatmap など重い処理用（ピン切替とは別）
  static const Duration _cameraIdleDebounceDuration =
      Duration(milliseconds: 350);
  Timer? _cameraIdleDebounceTimer;

  Future<void> applyInitialCameraZoom(LatLng center) async {
    await state.mapController?.moveCamera(
      CameraUpdate.newLatLngZoom(center, MapOverlayConstants.initial),
    );
  }

  Future<void> setMapController(
    MapLibreMapController controller, {
    required void Function(List<Posts> posts) onPinTap,
    required double iconSize,
    LatLng? initialCenter,
  }) async {
    _cameraIdleDebounceTimer?.cancel();
    _cameraIdleDebounceTimer = null;
    state = state.copyWith(
      mapController: controller,
      cameraCenterLatLng: initialCenter ?? state.cameraCenterLatLng,
    );
    _onPinTapHandler = onPinTap;
    _registerTapHandlers(controller);
    await setPin();
  }

  void _registerTapHandlers(MapLibreMapController controller) {
    if (_tapHandlerRegistered) {
      return;
    }
    _tapHandlerRegistered = true;

    // 赤点レイヤーのタップ
    controller.onFeatureTapped.add((point, latLng, id, layerId, annotation) {
      if (layerId != MapOverlayConstants.runtimeDotsLayerId) {
        return;
      }
      unawaited(_handlePinTap(latLng));
    });

    // カスタムピン（Annotation）のタップ
    controller.onSymbolTapped.add((symbol) {
      final latLng = symbol.options.geometry;
      if (latLng == null) {
        return;
      }
      unawaited(_handlePinTap(latLng));
    });
  }

  Future<void> _handlePinTap(LatLng latLng) async {
    if (_isHandlingPinTap) {
      return;
    }
    _isHandlingPinTap = true;
    state = state.copyWith(isLoading: true);
    try {
      final result =
          await ref.read(mapPostRepositoryProvider.notifier).getRestaurantPosts(
                lat: latLng.latitude,
                lng: latLng.longitude,
              );
      final handler = _onPinTapHandler;
      if (handler != null) {
        result.whenOrNull(success: handler);
      }
      await state.mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, MapOverlayConstants.pinTap),
        duration: const Duration(seconds: 1),
      );
      state = state.copyWith(hasError: false);
    } finally {
      _isHandlingPinTap = false;
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setPin() async {
    try {
      final posts =
          ref.read(filteredMapPostsProvider).whenOrNull(data: (v) => v) ??
              const <Posts>[];
      if (posts.isEmpty) {
        _cachedPosts = const <Posts>[];
        _cachedImageKeys = const <String, String>{};
        _dotsLayerReady = false;
        _isDotMode = null;
        await _refreshSearchHighlightOnly();
        return;
      }
      final unique = MapPinData.dedupeByLatLng(posts);
      _cachedPosts = unique;
      final imageTypes = MapPinData.collectImageTypes(unique);
      _cachedImageKeys = await _pinLoader.generatePinImages(
        state.mapController!,
        imageTypes,
        unique,
      );
      await _installPins(state.mapController!, unique, _cachedImageKeys!);
    } on PlatformException catch (_) {
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }

  /// 赤点レイヤー + ズームに応じた Annotation カスタムピン
  Future<void> _installPins(
    MapLibreMapController controller,
    List<Posts> posts,
    Map<String, String> imageKeys,
  ) async {
    final result = await MapRuntimeLayer.setupDots(controller, posts);
    _dotsLayerReady = result.dotsReady;

    final zoom =
        controller.cameraPosition?.zoom ?? MapOverlayConstants.localeFallback;
    final wantDots = zoom < MapOverlayConstants.smallDotZoomThreshold;
    _isDotMode = null; // force 適用させる
    await _applyPinMode(
      controller,
      wantDots: wantDots,
      posts: posts,
      imageKeys: imageKeys,
    );
  }

  /// 赤点 visibility と Annotation ピンを排他で切り替える
  Future<void> _applyPinMode(
    MapLibreMapController controller, {
    required bool wantDots,
    required List<Posts> posts,
    required Map<String, String> imageKeys,
  }) async {
    _isDotMode = wantDots;

    if (_dotsLayerReady) {
      await MapRuntimeLayer.setDotsVisible(controller, visible: wantDots);
    }

    if (wantDots) {
      // 広域: Annotation ピンは消して赤点だけ
      if (_dotsLayerReady) {
        await _refreshSearchHighlightOnly();
      } else {
        // Circle がダメなら Annotation の赤点で代用
        await _addSmallRedDotSymbols(controller, posts);
      }
    } else {
      // 近景: カスタムピン（Annotation）を出す
      await _addNormalPinSymbols(controller, posts, imageKeys);
    }
  }

  Future<void> _addSmallRedDotSymbols(
    MapLibreMapController controller,
    List<Posts> posts,
  ) async {
    const key = 'small_red_dot';
    if (!_pinLoader.cache.containsKey(key)) {
      await _pinLoader.preload();
    }
    final bytes = _pinLoader.cache[key];
    if (bytes == null) {
      // 赤点が作れないときだけ通常ピン（何も出さないよりマシ）
      if (_cachedImageKeys != null) {
        await _addNormalPinSymbols(controller, posts, _cachedImageKeys!);
      }
      return;
    }
    if (!_pinLoader.registeredKeys.contains(key)) {
      await _pinLoader.registerImage(controller, key, bytes);
    }
    final zoom =
        controller.cameraPosition?.zoom ?? MapOverlayConstants.localeFallback;
    final symbols = MapPinStyle.smallRedDotSymbols(posts);
    final append = _searchHighlightSymbolOptions(zoom);
    if (symbols.isNotEmpty || append != null) {
      await MapPinStyle.addSymbolsToMap(
        controller,
        symbols,
        appendSymbol: append,
      );
    }
  }

  Future<void> moveToCurrentLocation() async {
    await ref.read(locationProvider).whenOrNull(
          data: (loc) async => state.mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(loc.latitude, loc.longitude),
              MapOverlayConstants.currentLocation,
            ),
          ),
        );
  }

  void setNearbySearchCenterFromCamera() {
    final ctrl = state.mapController;
    if (ctrl == null) {
      return;
    }
    final target = ctrl.cameraPosition?.target;
    if (target == null) {
      return;
    }
    state = state.copyWith(cameraCenterLatLng: target);
  }

  void setNearbySearchCenterFromLatLng({
    required double lat,
    required double lng,
  }) {
    state = state.copyWith(cameraCenterLatLng: LatLng(lat, lng));
  }

  Future<void> animateToLatLng({
    required double lat,
    required double lng,
    double zoom = MapOverlayConstants.pinTap,
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    await state.mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), zoom),
      duration: duration,
    );
  }

  Future<void> resetBearing() async {
    final ctrl = state.mapController;
    if (ctrl == null) {
      return;
    }
    final pos = ctrl.cameraPosition;
    await ctrl.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: pos?.target ?? const LatLng(0, 0),
          zoom: pos?.zoom ?? 0,
          tilt: pos?.tilt ?? 0,
        ),
      ),
    );
  }

  void handleStyleChange() {
    state.mapController?.clearSymbols();
    _pinLoader.clearRegisteredKeys();
    _tapHandlerRegistered = false;
    _searchResultPinLatLng = null;
    _dotsLayerReady = false;
    _isDotMode = null;
  }

  Future<void> setSearchResultPin(double lat, double lng) async {
    _searchResultPinLatLng = LatLng(lat, lng);
    await _refreshSearchHighlightOnly();
  }

  Future<void> clearSearchResultPin() async {
    if (_searchResultPinLatLng == null) {
      return;
    }
    _searchResultPinLatLng = null;
    await _refreshSearchHighlightOnly();
  }

  SymbolOptions? _searchHighlightSymbolOptions(double zoom) {
    final g = _searchResultPinLatLng;
    if (g == null) {
      return null;
    }
    return SymbolOptions(
      geometry: g,
      iconImage: MapOverlayConstants.styleDefaultMarkerIconId,
      iconSize: math.max(1.2, MapPinStyle.interpolatedIconSize(zoom) * 2.6),
      iconAnchor: 'bottom',
    );
  }

  Future<void> _refreshSearchHighlightOnly() async {
    final ctrl = state.mapController;
    if (ctrl == null) {
      return;
    }
    final zoom =
        ctrl.cameraPosition?.zoom ?? MapOverlayConstants.localeFallback;
    final opt = _searchHighlightSymbolOptions(zoom);
    await ctrl.clearSymbols();
    if (opt == null) {
      return;
    }
    await ctrl.addSymbol(opt);
    await ctrl.setSymbolIconIgnorePlacement(true);
    await ctrl.setSymbolIconAllowOverlap(true);
  }

  void onStyleLoaded() {
    if (state.mapController == null) {
      return;
    }
    unawaited(_handleStyleLoaded());
  }

  Future<void> _handleStyleLoaded() async {
    _pinLoader.clearRegisteredKeys();
    _heatmapLayerAdded = false;
    _dotsLayerReady = false;
    _isDotMode = null;
    _registerTapHandlers(state.mapController!);

    if (_cachedPosts != null &&
        _cachedPosts!.isNotEmpty &&
        _cachedImageKeys != null) {
      for (final entry in _cachedImageKeys!.entries) {
        final bytes = _pinLoader.cache[entry.key];
        if (bytes != null) {
          await _pinLoader.registerImage(
            state.mapController!,
            entry.value,
            bytes,
          );
        }
      }
      await _installPins(
        state.mapController!,
        _cachedPosts!,
        _cachedImageKeys!,
      );
    } else {
      await setPin();
    }
  }

  /// ジェスチャ中のズーム変化で、閾値を跨いだら即時切替する。
  void onCameraMove(CameraPosition position) {
    unawaited(_syncPinModeForZoom(position.zoom));
  }

  /// カメラ停止後: 表示モードを再同期 + ヒートマップはデバウンス。
  void scheduleUpdateAfterCameraIdle() {
    final zoom = state.mapController?.cameraPosition?.zoom ??
        MapOverlayConstants.localeFallback;
    unawaited(_syncPinModeForZoom(zoom));

    _cameraIdleDebounceTimer?.cancel();
    _cameraIdleDebounceTimer = Timer(_cameraIdleDebounceDuration, () {
      _cameraIdleDebounceTimer = null;
      unawaited(_updateHeatmapIfNeeded());
    });
  }

  /// ズームから bool を決め、赤点 / カスタムピンを切り替える。
  Future<void> _syncPinModeForZoom(double zoom) async {
    final ctrl = state.mapController;
    if (ctrl == null) {
      return;
    }
    final wantDots = zoom < MapOverlayConstants.smallDotZoomThreshold;
    if (_isDotMode == wantDots) {
      return;
    }
    if (_cachedPosts == null ||
        _cachedPosts!.isEmpty ||
        _cachedImageKeys == null) {
      return;
    }
    await _applyPinMode(
      ctrl,
      wantDots: wantDots,
      posts: _cachedPosts!,
      imageKeys: _cachedImageKeys!,
    );
  }

  /// 互換のため残す（カテゴリ変更などから呼ばれる）
  Future<void> updateVisibleMealsCount() async {
    await _updateHeatmapIfNeeded();
  }

  Future<void> _updateHeatmapIfNeeded() async {
    final ctrl = state.mapController;
    if (ctrl == null || _cachedPosts == null || _cachedPosts!.isEmpty) {
      return;
    }
    final zoom =
        ctrl.cameraPosition?.zoom ?? MapOverlayConstants.localeFallback;
    if (zoom <= MapOverlayConstants.heatmapZoomThreshold) {
      if (_heatmapLayerAdded) {
        return;
      }
      if (_dotsLayerReady) {
        await MapRuntimeLayer.setDotsVisible(ctrl, visible: false);
      }
      await ctrl.clearSymbols();
      if (await MapHeatmapLayer.add(ctrl, _cachedPosts!)) {
        _heatmapLayerAdded = true;
      }
      await _refreshSearchHighlightOnly();
    } else if (_heatmapLayerAdded) {
      await MapHeatmapLayer.remove(ctrl);
      _heatmapLayerAdded = false;
      _isDotMode = null;
      final z =
          ctrl.cameraPosition?.zoom ?? MapOverlayConstants.localeFallback;
      if (_cachedImageKeys != null) {
        await _syncPinModeForZoom(z);
      } else {
        await _refreshSearchHighlightOnly();
      }
    }
  }

  Future<void> refreshPinsForCategoryFilter() async {
    if (state.mapController == null) {
      return;
    }
    _pinLoader.clearRegisteredKeys();
    _heatmapLayerAdded = false;
    _dotsLayerReady = false;
    _isDotMode = null;
    await setPin();
  }

  Future<void> _addNormalPinSymbols(
    MapLibreMapController controller,
    List<Posts> posts,
    Map<String, String> imageKeys,
  ) async {
    final zoom =
        controller.cameraPosition?.zoom ?? MapOverlayConstants.localeFallback;
    final symbols = MapPinStyle.normalPinSymbols(posts, imageKeys, zoom);
    final append = _searchHighlightSymbolOptions(zoom);
    if (symbols.isNotEmpty || append != null) {
      await MapPinStyle.addSymbolsToMap(
        controller,
        symbols,
        appendSymbol: append,
      );
    }
  }
}
