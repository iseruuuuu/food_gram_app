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
  double? _currentZoom;
  bool _heatmapLayerAdded = false;
  bool _symbolTapHandlerRegistered = false;
  void Function(List<Posts> posts)? _onPinTapHandler;

  /// 地名検索で選んだ地点（スタイル標準の marker_11 を重ねる）
  LatLng? _searchResultPinLatLng;

  /// マップ移動後、この時間経過してから表示を更新
  static const Duration _cameraIdleDebounceDuration = Duration(seconds: 1);
  Timer? _cameraIdleDebounceTimer;

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
    await setPin();
    await updateVisibleMealsCount();
  }

  Future<void> setPin() async {
    try {
      final posts =
          ref.read(filteredMapPostsProvider).whenOrNull(data: (v) => v) ??
              const <Posts>[];

      if (posts.isEmpty) {
        _cachedPosts = const <Posts>[];
        _cachedImageKeys = const <String, String>{};
        await _refreshPinsKeepingZoom();
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
      await _addNormalPinSymbols(
        state.mapController!,
        unique,
        _cachedImageKeys!,
      );
      if (!_symbolTapHandlerRegistered) {
        state.mapController?.onSymbolTapped.add((symbol) async {
          state = state.copyWith(isLoading: true);
          final latLng = symbol.options.geometry;
          if (latLng == null) {
            state = state.copyWith(isLoading: false);
            return;
          }
          final result = await ref
              .read(mapPostRepositoryProvider.notifier)
              .getRestaurantPosts(lat: latLng.latitude, lng: latLng.longitude);
          final handler = _onPinTapHandler;
          if (handler != null) {
            result.whenOrNull(success: handler);
          }
          await state.mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(latLng, 16),
            duration: const Duration(seconds: 1),
          );
          state = state.copyWith(isLoading: false, hasError: false);
        });
        _symbolTapHandlerRegistered = true;
      }
    } on PlatformException catch (_) {
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }

  Future<void> moveToCurrentLocation() async {
    await ref.read(locationProvider).whenOrNull(
          data: (loc) async => state.mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(loc.latitude, loc.longitude), 16),
          ),
        );
  }

  /// 現在のカメラ中心を「近くの場所を検索」の基準にし、APIを1回だけ呼ぶ
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

  /// 外部（例: 検索結果タップ）から指定座標を「近くの場所を検索」の基準にする
  void setNearbySearchCenterFromLatLng({
    required double lat,
    required double lng,
  }) {
    state = state.copyWith(cameraCenterLatLng: LatLng(lat, lng));
  }

  Future<void> animateToLatLng({
    required double lat,
    required double lng,
    double zoom = 16,
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
    _symbolTapHandlerRegistered = false;
    _searchResultPinLatLng = null;
  }

  /// 検索で選んだ場所に一時ピン（スプライト `marker_11`）を表示
  Future<void> setSearchResultPin(double lat, double lng) async {
    _searchResultPinLatLng = LatLng(lat, lng);
    await _refreshPinsKeepingZoom();
  }

  /// 検索ピンを消す（モーダルを閉じた・ピン選択に切り替えたときなど）
  Future<void> clearSearchResultPin() async {
    if (_searchResultPinLatLng == null) {
      return;
    }
    _searchResultPinLatLng = null;
    await _refreshPinsKeepingZoom();
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

  Future<void> _refreshPinsKeepingZoom() async {
    final zoom = state.mapController?.cameraPosition?.zoom ?? 14.0;
    await _updateDisplayMode(zoom);
  }

  Future<void> _showSearchHighlightOnly() async {
    final ctrl = state.mapController;
    if (ctrl == null) {
      return;
    }
    final zoom = ctrl.cameraPosition?.zoom ?? 14.0;
    final opt = _searchHighlightSymbolOptions(zoom);
    if (opt == null) {
      await ctrl.clearSymbols();
      return;
    }
    await ctrl.clearSymbols();
    await ctrl.addSymbol(opt);
    await ctrl.setSymbolIconIgnorePlacement(true);
    await ctrl.setSymbolIconAllowOverlap(true);
  }

  void onStyleLoaded() {
    if (state.mapController == null) {
      return;
    }
    _heatmapLayerAdded = false;
    if (_cachedPosts != null && _cachedImageKeys != null) {
      _restorePinsFromCache();
    } else {
      _addPinsToMap();
    }
    updateVisibleMealsCount();
  }

  /// 1秒待ってから中心座標・近くの投稿を更新し、DB呼び出しを抑える
  void scheduleUpdateAfterCameraIdle() {
    _cameraIdleDebounceTimer?.cancel();
    _cameraIdleDebounceTimer = Timer(_cameraIdleDebounceDuration, () {
      _cameraIdleDebounceTimer = null;
      updateVisibleMealsCount();
    });
  }

  Future<void> updateVisibleMealsCount() async {
    final ctrl = state.mapController;
    if (ctrl == null) {
      return;
    }
    final position = ctrl.cameraPosition;
    final zoom = position?.zoom ?? 14.0;
    const heat = MapOverlayConstants.heatmapZoomThreshold;
    const dot = MapOverlayConstants.smallDotZoomThreshold;
    final zoomChanged = _currentZoom == null ||
        (_currentZoom! <= heat && zoom > heat) ||
        (_currentZoom! > heat && zoom <= heat) ||
        (_currentZoom! <= dot && zoom > dot) ||
        (_currentZoom! > dot && zoom <= dot);
    _currentZoom = zoom;
    if (zoomChanged) {
      await _updateDisplayMode(zoom);
    }
  }

  Future<void> _updateDisplayMode(double zoom) async {
    if (state.mapController == null) {
      return;
    }
    if (_cachedPosts == null || _cachedPosts!.isEmpty) {
      await _showSearchHighlightOnly();
      return;
    }
    try {
      if (zoom <= MapOverlayConstants.heatmapZoomThreshold) {
        await _showHeatmap();
      } else {
        await _hideHeatmap();
        if (zoom <= MapOverlayConstants.smallDotZoomThreshold) {
          await _showSmallRedDots();
        } else {
          await _showNormalPins();
        }
      }
    } on Exception catch (_) {}
  }

  Future<void> _showHeatmap() async {
    if (state.mapController == null ||
        _cachedPosts == null ||
        _heatmapLayerAdded) {
      return;
    }
    try {
      await MapHeatmapLayer.setRuntimeLayersVisible(
        state.mapController!,
        visible: false,
      );
      await state.mapController!.clearSymbols();
      if (await MapHeatmapLayer.add(state.mapController!, _cachedPosts!)) {
        _heatmapLayerAdded = true;
      }
      final heatZoom = state.mapController!.cameraPosition?.zoom ?? 10.0;
      final highlight = _searchHighlightSymbolOptions(heatZoom);
      if (highlight != null) {
        await state.mapController!.addSymbol(highlight);
        await state.mapController!.setSymbolIconIgnorePlacement(true);
        await state.mapController!.setSymbolIconAllowOverlap(true);
      }
    } on Exception catch (_) {}
  }

  Future<void> _hideHeatmap() async {
    if (state.mapController == null || !_heatmapLayerAdded) {
      return;
    }
    try {
      await MapHeatmapLayer.remove(state.mapController!);
      _heatmapLayerAdded = false;
      await MapHeatmapLayer.setRuntimeLayersVisible(
        state.mapController!,
        visible: true,
      );
    } on Exception catch (_) {}
  }

  Future<void> _showSmallRedDots() async {
    if (state.mapController == null || _cachedPosts == null) {
      return;
    }
    try {
      const key = 'small_red_dot';
      if (!_pinLoader.registeredKeys.contains(key) &&
          _pinLoader.cache.containsKey(key)) {
        await _pinLoader.registerImage(
          state.mapController!,
          key,
          _pinLoader.cache[key]!,
        );
      }
      final symbols = MapPinStyle.smallRedDotSymbols(_cachedPosts!);
      final zoom = state.mapController!.cameraPosition?.zoom ?? 14.0;
      final append = _searchHighlightSymbolOptions(zoom);
      if (symbols.isNotEmpty || append != null) {
        await MapPinStyle.addSymbolsToMap(
          state.mapController!,
          symbols,
          appendSymbol: append,
        );
      }
    } on Exception catch (_) {
      await _showNormalPins();
    }
  }

  Future<void> _showNormalPins() async {
    if (state.mapController == null ||
        _cachedPosts == null ||
        _cachedImageKeys == null) {
      return;
    }
    final zoom = state.mapController?.cameraPosition?.zoom ?? 14.0;
    final symbols =
        MapPinStyle.normalPinSymbols(_cachedPosts!, _cachedImageKeys!, zoom);
    final append = _searchHighlightSymbolOptions(zoom);
    if (symbols.isNotEmpty || append != null) {
      await MapPinStyle.addSymbolsToMap(
        state.mapController!,
        symbols,
        appendSymbol: append,
      );
    }
  }

  Future<void> _restorePinsFromCache() async {
    final ctrl = state.mapController;
    if (ctrl == null || _cachedPosts == null || _cachedImageKeys == null) {
      return;
    }

    await ctrl.clearSymbols();
    for (final entry in _cachedImageKeys!.entries) {
      final bytes = _pinLoader.cache[entry.key];
      if (bytes != null) {
        await _pinLoader.registerImage(ctrl, entry.value, bytes);
      }
    }
    if (_pinLoader.cache.containsKey('small_red_dot')) {
      await _pinLoader.registerImage(
        ctrl,
        'small_red_dot',
        _pinLoader.cache['small_red_dot']!,
      );
    }

    _currentZoom = ctrl.cameraPosition?.zoom ?? 14.0;
    await _updateDisplayMode(_currentZoom!);
  }

  Future<void> _addPinsToMap() async {
    final ctrl = state.mapController;
    if (ctrl == null) {
      return;
    }
    final posts =
        ref.read(filteredMapPostsProvider).whenOrNull(data: (v) => v) ??
            const <Posts>[];
    if (posts.isEmpty) {
      _cachedPosts = const <Posts>[];
      _cachedImageKeys = const <String, String>{};
      await _showSearchHighlightOnly();
      return;
    }

    final unique = MapPinData.dedupeByLatLng(posts);
    _cachedPosts = unique;
    final imageTypes = MapPinData.collectImageTypes(unique);
    _cachedImageKeys =
        await _pinLoader.generatePinImages(ctrl, imageTypes, unique);

    final ok = await MapRuntimeLayer.setup(ctrl, _cachedImageKeys!, unique);
    if (!ok) {
      await _addNormalPinSymbols(ctrl, unique, _cachedImageKeys!);
    }
  }

  /// カテゴリーフィルター変更時に、カメラ状態を維持したままピンのみ更新する
  Future<void> refreshPinsForCategoryFilter() async {
    if (state.mapController == null) {
      return;
    }
    _pinLoader.clearRegisteredKeys();
    _symbolTapHandlerRegistered = false;
    _heatmapLayerAdded = false;
    await setPin();
    await updateVisibleMealsCount();
  }

  Future<void> _addNormalPinSymbols(
    MapLibreMapController controller,
    List<Posts> posts,
    Map<String, String> imageKeys,
  ) async {
    final zoom = controller.cameraPosition?.zoom ?? 14.0;
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
