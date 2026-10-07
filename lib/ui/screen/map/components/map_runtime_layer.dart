import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:food_gram_app/core/config/constants/map_overlay_constants.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/utils/map/map_geojson_support.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/ui/screen/map/components/map_pin_data.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// ランタイムの投稿レイヤーを載せた結果
class MapRuntimeSetupResult {
  const MapRuntimeSetupResult({
    required this.dotsReady,
    required this.pinsReady,
  });

  final bool dotsReady;
  final bool pinsReady;
}

/// 投稿地点は1つの GeoJSON ソースにまとめる。
/// ズーム 8 未満は赤点、8 以上はカテゴリピン。ズームではソースを作り直さない。
class MapRuntimeLayer {
  MapRuntimeLayer._();

  static const _emptyCollection = <String, dynamic>{
    'type': 'FeatureCollection',
    'features': <Map<String, dynamic>>[],
  };

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

  /// カテゴリピンの表示 / 非表示
  static Future<void> setPinsVisible(
    MapLibreMapController controller, {
    required bool visible,
  }) async {
    try {
      await controller.setLayerVisibility(
        MapOverlayConstants.runtimeLayerId,
        visible,
      );
    } on Exception catch (_) {}
  }

  /// 投稿が無いとき、既存ソースだけ空にする。
  static Future<void> clearPosts(MapLibreMapController controller) async {
    if (!MapGeoJsonSupport.allowsRuntimeGeoJson) {
      return;
    }
    final exists = await _sourceExists(
      controller,
      MapOverlayConstants.runtimeSourceId,
    );
    if (exists != true) {
      return;
    }
    try {
      await controller.setGeoJsonSource(
        MapOverlayConstants.runtimeSourceId,
        _emptyCollection,
      );
    } on Object catch (_) {}
  }

  /// 全地点を1ソースにし、赤点とカテゴリピンの両レイヤーを載せる。
  /// 画像は呼び出し側が先に addImage しておく。
  static Future<MapRuntimeSetupResult> setupPosts(
    MapLibreMapController controller,
    List<Posts> posts,
    Map<String, String> imageKeys, {
    Set<String> ownLatLngKeys = const {},
  }) async {
    if (!MapGeoJsonSupport.allowsRuntimeGeoJson) {
      return const MapRuntimeSetupResult(dotsReady: false, pinsReady: false);
    }
    try {
      final data = _featureCollection(posts, imageKeys, ownLatLngKeys);
      await _upsertGeoJsonSource(
        controller,
        MapOverlayConstants.runtimeSourceId,
        data,
      );
      final dotsReady = await _hasLayer(
            controller,
            MapOverlayConstants.runtimeDotsLayerId,
          ) ||
          await _addDotsLayer(controller);
      final pinsReady = await _hasLayer(
            controller,
            MapOverlayConstants.runtimeLayerId,
          ) ||
          await _addPinsLayer(controller);
      return MapRuntimeSetupResult(dotsReady: dotsReady, pinsReady: pinsReady);
    } on Object catch (_) {
      return const MapRuntimeSetupResult(dotsReady: false, pinsReady: false);
    }
  }

  static Map<String, dynamic> _featureCollection(
    List<Posts> posts,
    Map<String, String> imageKeys,
    Set<String> ownLatLngKeys,
  ) {
    final features = posts.map((post) {
      final isOwn = MapPinData.isOwnLocation(post, ownLatLngKeys);
      return {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [post.lng, post.lat],
        },
        'properties': {
          'lat': post.lat,
          'lng': post.lng,
          'icon': MapPinData.iconImageFor(post, imageKeys, ownLatLngKeys),
          'own': isOwn,
        },
      };
    }).toList();
    return {
      'type': 'FeatureCollection',
      'features': features,
    };
  }

  /// setGeoJsonSource はソース欠落時の戻りがプラットフォームで違う。
  /// Android は null 参照、iOS は sourceNotFound、web は TypeError。
  static Future<void> _upsertGeoJsonSource(
    MapLibreMapController controller,
    String sourceId,
    Map<String, dynamic> data,
  ) async {
    final exists = await _sourceExists(controller, sourceId);
    switch (exists) {
      case true:
        await controller.setGeoJsonSource(sourceId, data);
      case false:
        await controller.addSource(
          sourceId,
          GeojsonSourceProperties(data: data),
        );
      case null:
        try {
          await controller.setGeoJsonSource(sourceId, data);
        } on Object {
          await controller.addSource(
            sourceId,
            GeojsonSourceProperties(data: data),
          );
        }
    }
  }

  static Future<bool?> _sourceExists(
    MapLibreMapController controller,
    String sourceId,
  ) async {
    try {
      final ids = await controller.getSourceIds();
      return ids.contains(sourceId);
    } on Object {
      return null;
    }
  }

  static Future<bool> _hasLayer(
    MapLibreMapController controller,
    String layerId,
  ) async {
    try {
      final ids = await controller.getLayerIds();
      return ids.map((id) => id.toString()).contains(layerId);
    } on Object {
      return false;
    }
  }

  static Future<bool> _addDotsLayer(MapLibreMapController controller) async {
    final paint = await _loadDotsPaint();
    final others = paint['circle-color'] is String
        ? paint['circle-color'] as String
        : '#E53935';
    final props = CircleLayerProperties(
      circleRadius: _asDouble(paint['circle-radius'], 4),
      circleColor: [
        'case',
        [
          '==',
          ['get', 'own'],
          true,
        ],
        '#E88932',
        others,
      ],
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
        maxzoom: MapOverlayConstants.smallDotZoomThreshold,
      );
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  static Future<bool> _addPinsLayer(MapLibreMapController controller) async {
    final layout = await _loadPinLayout();
    final props = SymbolLayerProperties(
      iconImage: layout['icon-image'] ?? ['get', 'icon'],
      iconAllowOverlap: layout['icon-allow-overlap'] ?? true,
      iconIgnorePlacement: layout['icon-ignore-placement'] ?? true,
      iconSize: layout['icon-size'] ?? _defaultIconSize,
      iconOpacity: layout['icon-opacity'] ?? 1,
    );
    try {
      await controller.addSymbolLayer(
        MapOverlayConstants.runtimeSourceId,
        MapOverlayConstants.runtimeLayerId,
        props,
        minzoom: MapOverlayConstants.smallDotZoomThreshold,
      );
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  static const List<Object> _defaultIconSize = [
    'interpolate',
    ['linear'],
    ['zoom'],
    8,
    0.28,
    9,
    0.30,
    10.5,
    0.33,
    12,
    0.37,
    13,
    0.42,
    14,
    0.47,
    15,
    0.52,
    16,
    0.56,
    22,
    0.56,
  ];

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

  static Future<Map<String, dynamic>> _loadPinLayout() async {
    try {
      final raw = await rootBundle.loadString(Assets.map.overlayPostsLayer);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final layout = json['layout'];
      if (layout is Map<String, dynamic>) {
        return Map<String, dynamic>.from(layout);
      }
    } on Exception catch (_) {}
    return {};
  }
}
