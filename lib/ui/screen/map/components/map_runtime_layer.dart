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
/// 切替は minzoom / maxzoom のみ（Dart で付け外ししない）
class MapRuntimeLayer {
  MapRuntimeLayer._();

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

      // --- 低ズーム: 赤い点（必ず載せる） ---
      dotsReady = await _addDotsLayer(controller);

      // --- 高ズーム: カテゴリーピン（常に minzoom 付き） ---
      // 赤点が失敗しても、低ズームで画像ピンを出さない
      const pinMinZoom = MapOverlayConstants.smallDotZoomThreshold;

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
                9,
                0.31,
                14,
                0.53,
                16,
                0.61,
              ],
          iconOpacity: pinLayout['icon-opacity'] ?? 0.85,
        ),
        minzoom: pinMinZoom,
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
          iconOpacity: selectedLayout['icon-opacity'] ?? 1.0,
        ),
        minzoom: pinMinZoom,
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

  /// 赤い円を追加。複雑な expression がダメなら単純な円でリトライする
  static Future<bool> _addDotsLayer(MapLibreMapController controller) async {
    // 1) JSON の見た目を試す
    try {
      final paint = await _loadDotsPaint();
      await controller.addCircleLayer(
        MapOverlayConstants.runtimeSourceId,
        MapOverlayConstants.runtimeDotsLayerId,
        CircleLayerProperties(
          circleRadius: paint['circle-radius'] ?? 4.0,
          circleColor: paint['circle-color'] ?? '#E53935',
          circleStrokeWidth: paint['circle-stroke-width'] ?? 1.2,
          circleStrokeColor: paint['circle-stroke-color'] ?? '#FFFFFF',
          circleOpacity: paint['circle-opacity'] ?? 0.92,
        ),
        maxzoom: MapOverlayConstants.smallDotZoomThreshold,
      );
      return true;
    } on Exception catch (_) {}

    // 2) 単純な円で必ず載せる
    try {
      try {
        await controller.removeLayer(MapOverlayConstants.runtimeDotsLayerId);
      } on Exception catch (_) {}
      await controller.addCircleLayer(
        MapOverlayConstants.runtimeSourceId,
        MapOverlayConstants.runtimeDotsLayerId,
        const CircleLayerProperties(
          circleRadius: 4.0,
          circleColor: '#E53935',
          circleStrokeWidth: 1.2,
          circleStrokeColor: '#FFFFFF',
          circleOpacity: 0.92,
        ),
        maxzoom: MapOverlayConstants.smallDotZoomThreshold,
      );
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> _loadDotsPaint() async {
    try {
      final raw =
          await rootBundle.loadString(Assets.map.overlayPostsDotsLayer);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final paint = json['paint'];
      if (paint is Map<String, dynamic>) {
        return paint;
      }
    } on Exception catch (_) {}
    return {
      'circle-radius': 4.0,
      'circle-color': '#E53935',
      'circle-stroke-width': 1.2,
      'circle-stroke-color': '#FFFFFF',
      'circle-opacity': 0.92,
    };
  }

  static Future<Map<String, dynamic>> _loadSymbolLayout(String assetPath) async {
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
