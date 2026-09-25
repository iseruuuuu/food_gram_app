import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:food_gram_app/core/config/constants/map_overlay_constants.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/utils/map/map_geojson_support.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// ランタイム赤点レイヤーのセットアップ結果
class MapRuntimeSetupResult {
  const MapRuntimeSetupResult({required this.dotsReady});

  final bool dotsReady;
}

/// 広域表示用の赤い点（CircleLayer）のみを担当する。
/// カスタムピンは Annotation（addSymbol）側で出す（安定）。
///
/// `showDots: true`  → 赤点表示
/// `showDots: false` → 赤点非表示
class MapRuntimeLayer {
  MapRuntimeLayer._();

  /// 赤点の表示 / 非表示
  static Future<void> setDotsVisible(
    MapLibreMapController controller, {
    required bool visible,
  }) async {
    try {
      await controller.setLayerVisibility(
        MapOverlayConstants.runtimeDotsLayerId,
        visible,
      );
    } on Exception catch (_) {}
  }

  static Future<void> setDotsMode(
    MapLibreMapController controller, {
    required bool showDots,
  }) =>
      setDotsVisible(controller, visible: showDots);

  /// GeoJSON ソース + 赤点 CircleLayer を載せる（カスタムピン Symbol は載せない）
  static Future<MapRuntimeSetupResult> setupDots(
    MapLibreMapController controller,
    List<Posts> posts,
  ) async {
    if (!MapGeoJsonSupport.allowsRuntimeGeoJson) {
      return const MapRuntimeSetupResult(dotsReady: false);
    }
    try {
      final features = posts
          .map(
            (post) => {
              'type': 'Feature',
              'geometry': {
                'type': 'Point',
                'coordinates': [post.lng, post.lat],
              },
              'properties': {
                'lat': post.lat,
                'lng': post.lng,
              },
            },
          )
          .toList();
      final data = <String, dynamic>{
        'type': 'FeatureCollection',
        'features': features,
      };

      try {
        await controller.setGeoJsonSource(
          MapOverlayConstants.runtimeSourceId,
          data,
        );
        return const MapRuntimeSetupResult(dotsReady: true);
      } on PlatformException {
        await controller.addSource(
          MapOverlayConstants.runtimeSourceId,
          GeojsonSourceProperties(data: data),
        );
        final ok = await _addDotsLayer(controller);
        return MapRuntimeSetupResult(dotsReady: ok);
      }
    } on Exception catch (_) {
      return const MapRuntimeSetupResult(dotsReady: false);
    }
  }

  static Future<bool> _addDotsLayer(MapLibreMapController controller) async {
    final paint = await _loadDotsPaint();
    final props = CircleLayerProperties(
      circleRadius: _asDouble(paint['circle-radius'], 4),
      circleColor: paint['circle-color'] is String
          ? paint['circle-color'] as String
          : '#E53935',
      circleStrokeWidth: _asDouble(paint['circle-stroke-width'], 1.2),
      circleStrokeColor: paint['circle-stroke-color'] is String
          ? paint['circle-stroke-color'] as String
          : '#FFFFFF',
      circleOpacity: _asDouble(paint['circle-opacity'], 0.92),
    );

    try {
      await controller.addCircleLayer(
        MapOverlayConstants.runtimeSourceId,
        MapOverlayConstants.runtimeDotsLayerId,
        props,
      );
      return true;
    } on Exception catch (_) {}

    try {
      await controller.addCircleLayer(
        MapOverlayConstants.runtimeSourceId,
        MapOverlayConstants.runtimeDotsLayerId,
        const CircleLayerProperties(
          circleRadius: 4,
          circleColor: '#E53935',
          circleStrokeWidth: 1.2,
          circleStrokeColor: '#FFFFFF',
          circleOpacity: 0.92,
        ),
      );
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  static double _asDouble(Object? value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }
    return fallback;
  }

  static Future<Map<String, dynamic>> _loadDotsPaint() async {
    try {
      final raw = await rootBundle.loadString(Assets.map.overlayPostsDotsLayer);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final paint = json['paint'];
      if (paint is Map<String, dynamic>) {
        return Map<String, dynamic>.from(paint);
      }
    } on Exception catch (_) {}
    return {};
  }
}
