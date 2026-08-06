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

      try {
        await controller.removeLayer(MapOverlayConstants.heatmapLayerId);
      } on Exception catch (_) {}
      try {
        await controller.removeSource(MapOverlayConstants.heatmapSourceId);
      } on Exception catch (_) {}

      await controller.addSource(
        MapOverlayConstants.heatmapSourceId,
        GeojsonSourceProperties(
          data: {
            'type': 'FeatureCollection',
            'features': features,
          },
        ),
      );

      const heat = MapOverlayConstants.heatmapZoomThreshold;
      await controller.addHeatmapLayer(
        MapOverlayConstants.heatmapSourceId,
        MapOverlayConstants.heatmapLayerId,
        HeatmapLayerProperties(
          heatmapWeight: [
            'interpolate',
            ['linear'],
            ['get', 'weight'],
            0,
            0,
            1,
            1,
          ],
          heatmapIntensity: [
            'interpolate',
            ['linear'],
            ['zoom'],
            0,
            1,
            heat,
            3,
          ],
          heatmapColor: [
            'interpolate',
            ['linear'],
            ['heatmap-density'],
            0,
            'rgba(33,102,172,0)',
            0.2,
            'rgb(103,169,207)',
            0.4,
            'rgb(209,229,240)',
            0.6,
            'rgb(253,219,199)',
            0.8,
            'rgb(239,138,98)',
            1,
            'rgb(178,24,43)',
          ],
          heatmapRadius: [
            'interpolate',
            ['linear'],
            ['zoom'],
            0,
            2,
            heat,
            20,
          ],
          heatmapOpacity: [
            'interpolate',
            ['linear'],
            ['zoom'],
            0,
            0.8,
            heat,
            0.6,
          ],
        ),
        maxzoom: heat,
      );
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  /// ヒートマップレイヤーを削除する
  static Future<void> remove(MapLibreMapController controller) async {
    try {
      await controller.removeLayer(MapOverlayConstants.heatmapLayerId);
    } on Exception catch (_) {}
    try {
      await controller.removeSource(MapOverlayConstants.heatmapSourceId);
    } on Exception catch (_) {}
  }

  /// 赤点レイヤーの表示を切り替える（ヒートマップ表示時に非表示にする用）
  static Future<void> setRuntimeLayersVisible(
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
}
