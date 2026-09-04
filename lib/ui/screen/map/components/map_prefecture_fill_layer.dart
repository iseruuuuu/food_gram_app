import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// 都道府県ポリゴンの塗りつぶし見た目
enum MapPrefectureFillPalette {
  /// 投稿数に応じた赤のヒートマップ（従来の日本マップ）
  heat,

  /// 投稿あり / 未開拓 の2段階（記録タブ日本ビュー）
  atlas,
}

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
    MapPrefectureFillPalette palette = MapPrefectureFillPalette.heat,
    bool isDark = false,
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
        _fillProperties(palette: palette, isDark: isDark),
      );
      await controller.addLayer(
        _sourceId,
        _lineLayerId,
        _lineProperties(palette: palette, isDark: isDark),
      );
    } on Exception catch (e, st) {
      // 地図の本体表示を止めないため、オーバーレイ描画失敗は握りつぶす。
      debugPrint('MapPrefectureFillLayer.render failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  static FillLayerProperties _fillProperties({
    required MapPrefectureFillPalette palette,
    required bool isDark,
  }) {
    if (palette == MapPrefectureFillPalette.atlas) {
      final unexplored = isDark ? '#3A3632' : '#E8E2D8';
      final hasPosts = isDark ? '#3D9B64' : '#2F8F57';
      return FillLayerProperties(
        fillColor: [
          'case',
          [
            '==',
            ['get', 'visited'],
            true,
          ],
          hasPosts,
          unexplored,
        ],
        fillOpacity: 1.0,
      );
    }
    return const FillLayerProperties(
      fillColor: '#FF6B6B',
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
        0.0,
      ],
    );
  }

  static LineLayerProperties _lineProperties({
    required MapPrefectureFillPalette palette,
    required bool isDark,
  }) {
    if (palette == MapPrefectureFillPalette.atlas) {
      return LineLayerProperties(
        lineColor: isDark ? '#5A544C' : '#C9C2B6',
        lineWidth: 0.8,
        lineOpacity: 1.0,
      );
    }
    return const LineLayerProperties(
      lineColor: '#CCCCCC',
      lineWidth: 1.0,
      lineOpacity: 0.9,
    );
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
