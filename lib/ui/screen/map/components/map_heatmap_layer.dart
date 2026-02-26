import 'package:food_gram_app/core/config/constants/map_overlay_constants.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// ヒートマップレイヤーの追加・削除
class MapHeatmapLayer {
  MapHeatmapLayer._();

  /// ヒートマップレイヤーを追加する
  static Future<bool> add(
    MapLibreMapController controller,
    List<Posts> posts,
  ) async {
    try {
      final features = posts.map((post) {
        return {
          'type': 'Feature',
          'geometry': {
            'type': 'Point',
            'coordinates': [post.lng, post.lat],
          },
          'properties': {'weight': 1.0},
        };
      }).toList();

      final source = {
        'type': 'geojson',
        'data': {
          'type': 'FeatureCollection',
          'features': features,
        },
      };

      final dynamic ctrl = controller;
      try {
        await ctrl.removeLayer(MapOverlayConstants.heatmapLayerId);
      } on Exception catch (_) {}
      try {
        await ctrl.removeSource(MapOverlayConstants.heatmapSourceId);
      } on Exception catch (_) {}

      await ctrl.addSource(MapOverlayConstants.heatmapSourceId, source);
      await ctrl.addLayer(_heatmapLayerDefinition);
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  /// ヒートマップレイヤーを削除する
  static Future<void> remove(MapLibreMapController controller) async {
    final dynamic ctrl = controller;
    try {
      await ctrl.removeLayer(MapOverlayConstants.heatmapLayerId);
    } on Exception catch (_) {}
    try {
      await ctrl.removeSource(MapOverlayConstants.heatmapSourceId);
    } on Exception catch (_) {}
  }

  /// 通常ピン用ランタイムレイヤーの表示を切り替える（ヒートマップ表示時に非表示にする用）
  static Future<void> setRuntimeLayersVisible(
    MapLibreMapController controller, {
    required bool visible,
  }) async {
    final value = visible ? 'visible' : 'none';
    final dynamic ctrl = controller;
    try {
      await ctrl.setLayoutProperty(
        MapOverlayConstants.runtimeLayerId,
        'visibility',
        value,
      );
      await ctrl.setLayoutProperty(
        '${MapOverlayConstants.runtimeLayerId}_selected',
        'visibility',
        value,
      );
    } on Exception catch (_) {}
  }

  static final Map<String, dynamic> _heatmapLayerDefinition = {
    'id': MapOverlayConstants.heatmapLayerId,
    'type': 'heatmap',
    'source': MapOverlayConstants.heatmapSourceId,
    'maxzoom': 10,
    'paint': {
      'heatmap-weight': [
        'interpolate', ['linear'], ['get', 'weight'],
        0, 0,
        1, 1,
      ],
      'heatmap-intensity': [
        'interpolate', ['linear'], ['zoom'],
        0, 1,
        10, 3,
      ],
      'heatmap-color': [
        'interpolate', ['linear'], ['heatmap-density'],
        0, 'rgba(33,102,172,0)',
        0.2, 'rgb(103,169,207)',
        0.4, 'rgb(209,229,240)',
        0.6, 'rgb(253,219,199)',
        0.8, 'rgb(239,138,98)',
        1, 'rgb(178,24,43)',
      ],
      'heatmap-radius': [
        'interpolate', ['linear'], ['zoom'],
        0, 2,
        10, 20,
      ],
      'heatmap-opacity': [
        'interpolate', ['linear'], ['zoom'],
        0, 0.8,
        10, 0.6,
      ],
    },
  };
}
