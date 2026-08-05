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
/// - 基本の見た目切替は minzoom / maxzoom（ジェスチャ中はネイティブ側）
/// - カメラ停止後にズームを1回だけ読み、閾値を跨いだときだけ Dart で同期
/// - 連続ポーリングはしない（負荷を抑える）
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
  bool _runtimeReady = false;
  bool _tapHandlerRegistered = false;
  bool _isHandlingPinTap = false;
  void Function(List<Posts> posts)? _onPinTapHandler;

  /// 地名検索で選んだ地点（スプライト marker_11）
  LatLng? _searchResultPinLatLng;

  /// null = 未同期。閾値跨ぎ検知用（true=赤点モード）
  bool? _isDotMode;

  /// camera idle 後のデバウンス（ジェスチャ中は何もしない）
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

    // ランタイムレイヤー（赤点 / カテゴリーピン）のタップ
    controller.onFeatureTapped.add((point, latLng, id, layerId, annotation) {
      if (layerId != MapOverlayConstants.runtimeLayerId &&
          layerId != MapOverlayConstants.runtimeDotsLayerId &&
          layerId != '${MapOverlayConstants.runtimeLayerId}_selected') {
        return;
      }
      unawaited(_handlePinTap(latLng));
    });

    // Annotation フォールバック時のタップ
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
        _runtimeReady = false;
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

  /// ランタイム優先。失敗時のみ Annotation で表示（安定フォールバック）
  Future<void> _installPins(
    MapLibreMapController controller,
    List<Posts> posts,
    Map<String, String> imageKeys,
  ) async {
    final result = await MapRuntimeLayer.setup(controller, imageKeys, posts);
    _runtimeReady = result.pinsReady;

    final zoom =
        controller.cameraPosition?.zoom ?? MapOverlayConstants.localeFallback;
    final wantDots = zoom < MapOverlayConstants.smallDotZoomThreshold;
    _isDotMode = wantDots;

    if (_runtimeReady) {
      // ランタイムは zoom 式で切替。Annotation の画像ピンは残さない
      await _refreshSearchHighlightOnly();
      return;
    }

    // ランタイム全体が失敗したときだけ Annotation フォールバック
    if (wantDots) {
      await _addSmallRedDotSymbols(controller, posts);
    } else {
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
    _runtimeReady = false;
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
    _runtimeReady = false;
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

  /// カメラ停止後: ズームを1回読み、閾値跨ぎ時のみピン表示を同期。
  void scheduleUpdateAfterCameraIdle() {
    _cameraIdleDebounceTimer?.cancel();
    _cameraIdleDebounceTimer = Timer(_cameraIdleDebounceDuration, () {
      _cameraIdleDebounceTimer = null;
      unawaited(_onCameraIdleSettled());
    });
  }

  Future<void> _onCameraIdleSettled() async {
    await _syncPinModeForCurrentZoom();
    await _updateHeatmapIfNeeded();
  }

  /// 閾値を跨いだとき／ピンモード時は赤点を確実に消す。
  Future<void> _syncPinModeForCurrentZoom() async {
    final ctrl = state.mapController;
    if (ctrl == null) {
      return;
    }
    final zoom =
        ctrl.cameraPosition?.zoom ?? MapOverlayConstants.localeFallback;
    final wantDots = zoom < MapOverlayConstants.smallDotZoomThreshold;

    if (_runtimeReady) {
      return;
    }

    if (_isDotMode == wantDots) {
      return;
    }
    _isDotMode = wantDots;

    // Annotation フォールバック時のみシンボルを付け替え
    if (_cachedPosts == null || _cachedPosts!.isEmpty) {
      return;
    }
    await ctrl.clearSymbols();
    if (wantDots) {
      await _addSmallRedDotSymbols(ctrl, _cachedPosts!);
    } else if (_cachedImageKeys != null) {
      await _addNormalPinSymbols(ctrl, _cachedPosts!, _cachedImageKeys!);
    } else {
      await _refreshSearchHighlightOnly();
    }
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
      await MapHeatmapLayer.setRuntimeLayersVisible(ctrl, visible: false);
      if (_runtimeReady) {
        // 検索ピン以外の Annotation は元々無い想定
      } else {
        await ctrl.clearSymbols();
      }
      if (await MapHeatmapLayer.add(ctrl, _cachedPosts!)) {
        _heatmapLayerAdded = true;
      }
      await _refreshSearchHighlightOnly();
    } else if (_heatmapLayerAdded) {
      await MapHeatmapLayer.remove(ctrl);
      _heatmapLayerAdded = false;
      if (_runtimeReady) {
        await _refreshSearchHighlightOnly();
      } else if (_cachedPosts != null && _cachedImageKeys != null) {
        await MapHeatmapLayer.setRuntimeLayersVisible(ctrl, visible: true);
        await _addNormalPinSymbols(
          ctrl,
          _cachedPosts!,
          _cachedImageKeys!,
        );
      } else {
        await MapHeatmapLayer.setRuntimeLayersVisible(ctrl, visible: true);
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
    _runtimeReady = false;
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
