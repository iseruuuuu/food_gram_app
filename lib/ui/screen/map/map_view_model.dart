import 'package:flutter/services.dart';
import 'package:food_gram_app/core/config/constants/map_overlay_constants.dart';
import 'package:food_gram_app/core/model/posts.dart';
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

  Future<void> setMapController(
    MapLibreMapController controller, {
    required void Function(List<Posts> posts) onPinTap,
    required double iconSize,
  }) async {
    state = state.copyWith(mapController: controller);
    await setPin(onPinTap: onPinTap, iconSize: iconSize);
    await updateVisibleMealsCount();
  }

  Future<void> setPin({
    required void Function(List<Posts> posts) onPinTap,
    required double iconSize,
  }) async {
    try {
      final posts = ref.read(mapRepositoryProvider).whenOrNull(data: (v) => v);
      if (posts == null || posts.isEmpty) {
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
          result.whenOrNull(success: onPinTap);
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

  Future<void> updateVisibleMealsCount() async {
    final ctrl = state.mapController;
    if (ctrl == null) {
      return;
    }
    final zoom = ctrl.cameraPosition?.zoom ?? 14.0;
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

    final posts = ref.read(mapRepositoryProvider).whenOrNull(data: (v) => v);
    if (posts == null || posts.isEmpty) {
      state = state.copyWith(visibleMealsCount: 0);
      return;
    }
    try {
      final bounds = await ctrl.getVisibleRegion();
      final count =
          posts.where((p) => bounds.contains(LatLng(p.lat, p.lng))).length;
      state = state.copyWith(visibleMealsCount: count);
    } on Exception catch (_) {}
  }

  Future<void> _updateDisplayMode(double zoom) async {
    if (state.mapController == null || _cachedPosts == null) {
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
      if (symbols.isNotEmpty) {
        await MapPinStyle.addSymbolsToMap(state.mapController!, symbols);
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
    if (symbols.isNotEmpty) {
      await MapPinStyle.addSymbolsToMap(state.mapController!, symbols);
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
    final posts = ref.read(mapRepositoryProvider).whenOrNull(data: (v) => v);
    if (posts == null || posts.isEmpty) {
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

  Future<void> _addNormalPinSymbols(
    MapLibreMapController controller,
    List<Posts> posts,
    Map<String, String> imageKeys,
  ) async {
    final zoom = controller.cameraPosition?.zoom ?? 14.0;
    final symbols = MapPinStyle.normalPinSymbols(posts, imageKeys, zoom);
    if (symbols.isNotEmpty) {
      await MapPinStyle.addSymbolsToMap(controller, symbols);
    }
  }
}
