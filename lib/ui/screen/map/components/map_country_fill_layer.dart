import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// 訪れた国ポリゴンの塗りつぶしレイヤーを管理する。
class MapCountryFillLayer {
  MapCountryFillLayer._();

  static const String _sourceId = 'fg_country_fill_source';
  static const String _fillLayerId = 'fg_country_fill_layer';
  static const String _lineLayerId = 'fg_country_border_layer';
  static const String _geoJsonAssetPath = 'assets/map/world_countries.geojson';
  static List<Map<String, dynamic>>? _baseFeatures;

  static Future<void> render(
    MapLibreMapController controller, {
    required Map<String, int> countryPostCounts,
  }) async {
    try {
      final features = await _loadFeatures();

      final updatedFeatures = features.map((feature) {
        final featureMap = Map<String, dynamic>.from(feature);
        final properties =
            Map<String, dynamic>.from(featureMap['properties'] as Map);
        final code = properties['iso_a2'] as String?;
        final postCount = code == null ? 0 : (countryPostCounts[code] ?? 0);
        properties['postCount'] = postCount;
        properties['visited'] = postCount > 0;
        featureMap['properties'] = properties;
        return featureMap;
      }).toList();

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
        GeojsonSourceProperties(
          data: {
            'type': 'FeatureCollection',
            'features': updatedFeatures,
          },
        ),
      );
      await controller.addLayer(
        _sourceId,
        _fillLayerId,
        const FillLayerProperties(
          fillColor: [
            'interpolate',
            ['linear'],
            ['get', 'postCount'],
            1,
            '#86EFAC',
            5,
            '#4ADE80',
            20,
            '#22C55E',
            50,
            '#16A34A',
            100,
            '#15803D',
          ],
          fillOpacity: [
            'case',
            [
              '==',
              ['get', 'visited'],
              true,
            ],
            [
              'interpolate',
              ['linear'],
              ['get', 'postCount'],
              1,
              0.45,
              5,
              0.55,
              20,
              0.7,
              50,
              0.8,
              100,
              0.88,
            ],
            0.0,
          ],
        ),
      );
      await controller.addLayer(
        _sourceId,
        _lineLayerId,
        const LineLayerProperties(
          lineColor: '#166534',
          lineWidth: 0.8,
          lineOpacity: [
            'case',
            [
              '==',
              ['get', 'visited'],
              true,
            ],
            0.85,
            0.0,
          ],
        ),
      );
    } on Exception catch (e, st) {
      debugPrint('MapCountryFillLayer.render failed: $e');
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
