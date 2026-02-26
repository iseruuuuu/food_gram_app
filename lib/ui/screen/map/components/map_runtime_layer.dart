import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:food_gram_app/core/config/constants/map_overlay_constants.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/ui/screen/map/components/map_pin_data.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// ランタイムの Symbol レイヤー（通常ピン用）の追加・更新
class MapRuntimeLayer {
  MapRuntimeLayer._();

  /// ソースとレイヤーを追加。失敗時は false を返す（Annotation フォールバック用）
  static Future<bool> setup(
    MapLibreMapController controller,
    Map<String, String> imageKeys,
    List<Posts> posts,
  ) async {
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

      final source = {
        'type': 'geojson',
        'data': {'type': 'FeatureCollection', 'features': features},
      };

      final layerJson =
          await rootBundle.loadString(Assets.map.overlayPostsLayer);
      final layer = jsonDecode(layerJson) as Map<String, dynamic>
        ..['id'] = MapOverlayConstants.runtimeLayerId
        ..['source'] = MapOverlayConstants.runtimeSourceId;

      final selectedJson =
          await rootBundle.loadString(Assets.map.overlayPostsSelectedLayer);
      final selectedLayer = jsonDecode(selectedJson) as Map<String, dynamic>
        ..['id'] = '${MapOverlayConstants.runtimeLayerId}_selected'
        ..['source'] = MapOverlayConstants.runtimeSourceId;

      final dynamic c = controller;
      try {
        await c.removeLayer(MapOverlayConstants.runtimeLayerId);
      } on Exception catch (_) {}
      try {
        await c.removeSource(MapOverlayConstants.runtimeSourceId);
      } on Exception catch (_) {}

      await c.addSource(MapOverlayConstants.runtimeSourceId, source);
      await c.addLayer(layer);
      await c.addLayer(selectedLayer);
      return true;
    } on Exception catch (_) {
      return false;
    }
  }
}
