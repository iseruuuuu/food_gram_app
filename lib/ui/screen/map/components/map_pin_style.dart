import 'dart:math' as math;

import 'package:food_gram_app/core/config/constants/map_overlay_constants.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/ui/screen/map/components/map_pin_data.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// ピンの見た目（アイコンサイズ補間・シンボルリスト生成）
class MapPinStyle {
  MapPinStyle._();

  /// JSONレイヤーの icon-size と同等の線形補間（Annotation用フォールバック）
  static double interpolatedIconSize(double zoom) {
    final anchors = <double, double>{
      3.5: 0.17,
      5.0: 0.21,
      7.0: 0.25,
      9.0: 0.31,
      10.5: 0.35,
      12.0: 0.41,
      13.0: 0.47,
      14.0: 0.53,
      15.0: 0.57,
      16.0: 0.61,
      17.0: 0.61,
      22.0: 0.61,
    };
    final keys = anchors.keys.toList()..sort();
    final z = zoom.clamp(keys.first, keys.last);
    for (var i = 0; i < keys.length - 1; i++) {
      final z0 = keys[i];
      final z1 = keys[i + 1];
      if (z >= z0 && z <= z1) {
        final s0 = anchors[z0]!;
        final s1 = anchors[z1]!;
        final t = (z - z0) / (z1 - z0);
        return s0 + (s1 - s0) * t;
      }
    }
    return anchors.values.last;
  }

  /// 小さな赤ドット用のシンボルリスト
  static List<SymbolOptions> smallRedDotSymbols(List<Posts> posts) {
    const redDotKey = 'small_red_dot';
    return posts
        .map(
          (post) => SymbolOptions(
            geometry: LatLng(post.lat, post.lng),
            iconImage: redDotKey,
            iconSize: MapOverlayConstants.smallRedDotIconSize,
          ),
        )
        .toList();
  }

  /// 通常ピン用のシンボルリスト
  static List<SymbolOptions> normalPinSymbols(
    List<Posts> posts,
    Map<String, String> imageKeys,
    double zoom,
  ) {
    return posts.map((post) {
      final imageType = MapPinData.imageTypeFor(post);
      return SymbolOptions(
        geometry: LatLng(post.lat, post.lng),
        iconImage: imageKeys[imageType],
        iconSize: interpolatedIconSize(zoom),
      );
    }).toList();
  }

  /// シンボルをマップに追加（クリア→チャンク追加→[appendSymbol]→オーバーラップ設定）
  static Future<void> addSymbolsToMap(
    MapLibreMapController controller,
    List<SymbolOptions> symbols, {
    int chunkSize = 250,
    SymbolOptions? appendSymbol,
  }) async {
    if (symbols.isEmpty && appendSymbol == null) {
      return;
    }
    await controller.clearSymbols();
    if (symbols.isNotEmpty) {
      final total = symbols.length;
      for (var start = 0; start < total; start += chunkSize) {
        final end = math.min(start + chunkSize, total);
        await controller.addSymbols(symbols.sublist(start, end));
      }
    }
    if (appendSymbol != null) {
      await controller.addSymbol(appendSymbol);
    }
    await controller.setSymbolIconIgnorePlacement(true);
    await controller.setSymbolIconAllowOverlap(true);
  }
}
