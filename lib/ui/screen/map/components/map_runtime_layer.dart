import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:food_gram_app/core/config/constants/map_overlay_constants.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/ui/screen/map/components/map_pin_data.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// ランタイム投稿レイヤーのセットアップ結果
class MapRuntimeSetupResult {
  const MapRuntimeSetupResult({
    required this.pinsReady,
    required this.dotsReady,
  });

  final bool pinsReady;
  final bool dotsReady;

  bool get anyReady => pinsReady || dotsReady;
}

/// 投稿ピンのランタイムレイヤー。
/// - ズーム < [MapOverlayConstants.smallDotZoomThreshold] → 赤い円
/// - ズーム >= 同閾値 → カテゴリーピン
///
/// 切替は paint の zoom 式 + minzoom / maxzoom に任せる。
/// camera idle でレイヤーを載せ外ししない（チラつき防止）。
class MapRuntimeLayer {
  MapRuntimeLayer._();

  static const double _threshold = MapOverlayConstants.smallDotZoomThreshold;

  /// zoom < threshold → [below] / zoom >= threshold → [atOrAbove]
  static List<Object> _stepByZoom(num below, num atOrAbove) => [
        'step',
        ['zoom'],
        below,
        _threshold,
        atOrAbove,
      ];

  static Future<MapRuntimeSetupResult> setup(
    MapLibreMapController controller,
    Map<String, String> imageKeys,
    List<Posts> posts,
  ) async {
    var pinsReady = false;
    var dotsReady = false;
    try {
      final features = posts.map((post) {
        final imageType = MapPinData.imageTypeFor(post);
        return {
          'type': 'Feature',
          'geometry': {
            'type': 'Point',
            'coordinates': [post.lng, post.lat],
          },
          'properties': {
            'icon': imageKeys[imageType],
            'lat': post.lat,
            'lng': post.lng,
            'selected': false,
          },
        };
      }).toList();

      for (final id in [
        '${MapOverlayConstants.runtimeLayerId}_selected',
        MapOverlayConstants.runtimeLayerId,
        MapOverlayConstants.runtimeDotsLayerId,
      ]) {
        try {
          await controller.removeLayer(id);
        } on Exception catch (_) {}
      }
      try {
        await controller.removeSource(MapOverlayConstants.runtimeSourceId);
      } on Exception catch (_) {}

      await controller.addSource(
        MapOverlayConstants.runtimeSourceId,
        GeojsonSourceProperties(
          data: {
            'type': 'FeatureCollection',
            'features': features,
          },
        ),
      );

      // 赤点を先に載せ、カテゴリーピンを上に重ねる
      dotsReady = await _addDotsLayer(controller);

      final pinLayout = await _loadSymbolLayout(Assets.map.overlayPostsLayer);
      await controller.addSymbolLayer(
        MapOverlayConstants.runtimeSourceId,
        MapOverlayConstants.runtimeLayerId,
        SymbolLayerProperties(
          iconImage: pinLayout['icon-image'] ?? ['get', 'icon'],
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
          iconSize: pinLayout['icon-size'] ??
              [
                'interpolate',
                ['linear'],
                ['zoom'],
                8,
                0.28,
                9,
                0.31,
                14,
                0.53,
                16,
                0.61,
              ],
          // 薄く見える原因だった zoom 連動 opacity は使わない
          iconOpacity: 1.0,
        ),
        minzoom: _threshold,
        filter: [
          '!=',
          ['get', 'selected'],
          true,
        ],
      );

      final selectedLayout =
          await _loadSymbolLayout(Assets.map.overlayPostsSelectedLayer);
      await controller.addSymbolLayer(
        MapOverlayConstants.runtimeSourceId,
        '${MapOverlayConstants.runtimeLayerId}_selected',
        SymbolLayerProperties(
          iconImage: selectedLayout['icon-image'] ?? ['get', 'icon'],
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
          iconSize: selectedLayout['icon-size'] ?? 0.62,
          iconOpacity: 1.0,
        ),
        minzoom: _threshold,
        filter: [
          '==',
          ['get', 'selected'],
          true,
        ],
      );
      pinsReady = true;

      return MapRuntimeSetupResult(
        pinsReady: pinsReady,
        dotsReady: dotsReady,
      );
    } on Exception catch (_) {
      return MapRuntimeSetupResult(
        pinsReady: pinsReady,
        dotsReady: dotsReady,
      );
    }
  }

  static Future<bool> _addDotsLayer(MapLibreMapController controller) async {
    final paint = await _loadDotsPaint();
    final props = CircleLayerProperties(
      circleRadius: paint['circle-radius'] ?? _stepByZoom(4.0, 0),
      circleColor: paint['circle-color'] ?? '#E53935',
      circleStrokeWidth: paint['circle-stroke-width'] ?? _stepByZoom(1.2, 0),
      circleStrokeColor: paint['circle-stroke-color'] ?? '#FFFFFF',
      circleOpacity: paint['circle-opacity'] ?? _stepByZoom(0.92, 0),
      circleStrokeOpacity:
          paint['circle-stroke-opacity'] ?? _stepByZoom(1.0, 0),
    );

    try {
      await controller.addCircleLayer(
        MapOverlayConstants.runtimeSourceId,
        MapOverlayConstants.runtimeDotsLayerId,
        props,
        maxzoom: _threshold,
      );
      return true;
    } on Exception catch (_) {}

    try {
      try {
        await controller.removeLayer(MapOverlayConstants.runtimeDotsLayerId);
      } on Exception catch (_) {}
      await controller.addCircleLayer(
        MapOverlayConstants.runtimeSourceId,
        MapOverlayConstants.runtimeDotsLayerId,
        CircleLayerProperties(
          circleRadius: _stepByZoom(4.0, 0),
          circleColor: '#E53935',
          circleStrokeWidth: _stepByZoom(1.2, 0),
          circleStrokeColor: '#FFFFFF',
          circleOpacity: _stepByZoom(0.92, 0),
          circleStrokeOpacity: _stepByZoom(1.0, 0),
        ),
        maxzoom: _threshold,
      );
      return true;
    } on Exception catch (_) {
      return false;
    }
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

  static Future<Map<String, dynamic>> _loadSymbolLayout(
    String assetPath,
  ) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final layout = json['layout'];
      if (layout is Map<String, dynamic>) {
        return layout;
      }
    } on Exception catch (_) {}
    return {};
  }
}
