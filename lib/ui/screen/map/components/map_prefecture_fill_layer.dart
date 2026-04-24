import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// 都道府県ポリゴンの塗りつぶしレイヤーを管理する。
class MapPrefectureFillLayer {
  MapPrefectureFillLayer._();

  static const String _sourceId = 'fg_prefecture_fill_source';
  static const String _fillLayerId = 'fg_prefecture_fill_layer';
  static const String _lineLayerId = 'fg_prefecture_border_layer';
  static const String _geoJsonAssetPath =
      'assets/map/japan_prefectures.geojson';
  static List<Map<String, dynamic>>? _baseFeatures;

  static Future<void> render(
    MapLibreMapController controller, {
    required Map<String, int> prefecturePostCounts,
  }) async {
    try {
      final features = await _loadFeatures();

      final updatedFeatures = features.map((feature) {
        final featureMap = Map<String, dynamic>.from(feature);
        final properties =
            Map<String, dynamic>.from(featureMap['properties'] as Map);
        final name = properties['nam_ja'] as String?;
        final postCount = name == null ? 0 : (prefecturePostCounts[name] ?? 0);
        properties['postCount'] = postCount;
        properties['visited'] = postCount > 0;
        featureMap['properties'] = properties;
        return featureMap;
      }).toList();

      final source = {
        'type': 'geojson',
        'data': {
          'type': 'FeatureCollection',
          'features': updatedFeatures,
        },
      };

      try {
        await controller.removeLayer(_lineLayerId);
      } on Exception catch (_) {}
      try {
        await controller.removeLayer(_fillLayerId);
      } on Exception catch (_) {}
      try {
        await controller.removeSource(_sourceId);
      } on Exception catch (_) {}

      await controller.addSource(
        _sourceId,
        GeojsonSourceProperties(data: source['data']),
      );
      await controller.addLayer(
        _sourceId,
        _fillLayerId,
        const FillLayerProperties(
          fillColor: '#FF6B6B',
          fillOpacity: [
            'interpolate',
            ['linear'],
            ['get', 'postCount'],
            0,
            0.05,
            1,
            0.15,
            3,
            0.25,
            5,
            0.35,
            10,
            0.45,
            15,
            0.55,
            20,
            0.65,
          ],
        ),
      );
      await controller.addLayer(
        _sourceId,
        _lineLayerId,
        const LineLayerProperties(
          lineColor: '#CCCCCC',
          lineWidth: 1.0,
          lineOpacity: 0.9,
        ),
      );
    } on Exception catch (e, st) {
      // 地図の本体表示を止めないため、オーバーレイ描画失敗は握りつぶす。
      debugPrint('MapPrefectureFillLayer.render failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  static Future<List<Map<String, dynamic>>> _loadFeatures() async {
    if (_baseFeatures != null) {
      return _baseFeatures!;
    }
    final geoJson = await rootBundle.loadString(_geoJsonAssetPath);
    final decoded = jsonDecode(geoJson) as Map<String, dynamic>;
    _baseFeatures =
        (decoded['features'] as List<dynamic>).cast<Map<String, dynamic>>();
    return _baseFeatures!;
  }
}
