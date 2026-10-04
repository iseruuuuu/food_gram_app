import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/assets.gen.dart';

/// シェア画像用に間引いた都道府県・国の輪郭。
class ShareOutlineRegion {
  const ShareOutlineRegion({
    required this.id,
    required this.rings,
    required this.centroidLat,
    required this.centroidLng,
  });

  final String id;
  final List<List<List<double>>> rings;
  final double centroidLat;
  final double centroidLng;
}

/// 日本と世界の輪郭セット。
class ShareOutlineSet {
  const ShareOutlineSet({
    required this.japan,
    required this.world,
    required this.worldById,
  });

  factory ShareOutlineSet.parse({
    required String japanJson,
    required String worldJson,
  }) {
    final japan = _decodeRegions(japanJson);
    final world = _decodeRegions(worldJson);
    return ShareOutlineSet(
      japan: japan,
      world: world,
      worldById: {for (final region in world) region.id: region},
    );
  }

  static const empty = ShareOutlineSet(
    japan: [],
    world: [],
    worldById: {},
  );

  final List<ShareOutlineRegion> japan;
  final List<ShareOutlineRegion> world;
  final Map<String, ShareOutlineRegion> worldById;
}

/// シェアカードがキャプチャされる前に読んでおく輪郭キャッシュ。
class ShareOutlineLibrary {
  ShareOutlineLibrary._();

  static ShareOutlineSet? current;
  static Future<ShareOutlineSet>? _loading;

  static Future<ShareOutlineSet> ensureLoaded() {
    final cached = current;
    if (cached != null) {
      return Future<ShareOutlineSet>.value(cached);
    }
    return _loading ??= _load();
  }

  static Future<ShareOutlineSet> _load() async {
    try {
      final japanJson = await rootBundle.loadString(
        Assets.map.shareJapanOutline,
      );
      final worldJson = await rootBundle.loadString(
        Assets.map.shareWorldOutline,
      );
      final set = ShareOutlineSet.parse(
        japanJson: japanJson,
        worldJson: worldJson,
      );
      current = set;
      return set;
    } on Object {
      _loading = null;
      rethrow;
    }
  }
}

List<ShareOutlineRegion> _decodeRegions(String source) {
  final decoded = jsonDecode(source);
  if (decoded is! Map) {
    return const [];
  }
  final regions = decoded['regions'];
  if (regions is! List) {
    return const [];
  }
  final result = <ShareOutlineRegion>[];
  for (final raw in regions) {
    if (raw is! Map) {
      continue;
    }
    final id = raw['id'];
    final rings = raw['rings'];
    if (id is! String || rings is! List) {
      continue;
    }
    final parsedRings = <List<List<double>>>[];
    for (final ring in rings) {
      if (ring is! List) {
        continue;
      }
      final points = <List<double>>[];
      for (final point in ring) {
        if (point is! List || point.length < 2) {
          continue;
        }
        final lng = point[0];
        final lat = point[1];
        if (lng is num && lat is num) {
          points.add([lng.toDouble(), lat.toDouble()]);
        }
      }
      if (points.length >= 4) {
        parsedRings.add(points);
      }
    }
    if (parsedRings.isEmpty) {
      continue;
    }
    final centroid = _centroid(parsedRings.first);
    result.add(
      ShareOutlineRegion(
        id: id,
        rings: parsedRings,
        centroidLat: centroid.$1,
        centroidLng: centroid.$2,
      ),
    );
  }
  return result;
}

(double, double) _centroid(List<List<double>> ring) {
  var lat = 0.0;
  var lng = 0.0;
  final count = ring.length;
  for (final point in ring) {
    lng += point[0];
    lat += point[1];
  }
  return (lat / count, lng / count);
}

/// シェア画像の日本地図の一辺。1 が横幅いっぱい。
/// 小さくすると正方形だけが縮み、カードの高さもそれに合わせて縮む。
const japanShareMapScale = 1;

/// シェア画像の日本地図のズーム。1 が列島全体が見える大きさ。
/// 大きくすると中央を保ったまま拡大され、端は枠で切れる。
const japanShareMapZoom = 1.12;

/// シェア画像の世界地図の縦の伸び。1 が地理どおりの横長。
/// 大きくすると縦に伸びて、正方形の中で普通の世界地図に近づく。
const worldShareMapHeightScale = 1.45;

/// シェア画像の世界地図のズーム。1 が全体が見える大きさ。
/// 大きくすると中央を保ったまま拡大され、端は枠で切れる。
const worldShareMapZoom = 1.06;

/// 世界地図を切る経度。-30 は大西洋で、アメリカが右、ほかの大陸が左。
/// -180 にすると、アメリカが左の一般的な配置に戻る。
const worldShareCutLng = -30.0;

/// 訪れた面を塗った、キャプチャできる静的な地図。
class ShareFillMap extends StatelessWidget {
  const ShareFillMap({
    required this.regions,
    required this.visitedIds,
    required this.japan,
    super.key,
  });

  final List<ShareOutlineRegion> regions;
  final Set<String> visitedIds;
  final bool japan;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShareFillMapPainter(
        regions: regions,
        visitedIds: visitedIds,
        japan: japan,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _MapBounds {
  const _MapBounds({
    required this.west,
    required this.east,
    required this.south,
    required this.north,
  });

  final double west;
  final double east;
  final double south;
  final double north;

  double get aspect {
    final midLat = ((north + south) / 2) * math.pi / 180;
    final width = (east - west) * math.cos(midLat);
    final height = north - south;
    if (height == 0) {
      return 1;
    }
    return width / height;
  }
}

class _ShareFillMapPainter extends CustomPainter {
  const _ShareFillMapPainter({
    required this.regions,
    required this.visitedIds,
    required this.japan,
  });

  final List<ShareOutlineRegion> regions;
  final Set<String> visitedIds;
  final bool japan;

  /// 本州の中央（中部あたり）が画面中央に来る範囲。
  /// 沖縄と北海道は端に残し、列島の重心が南西に寄らないようにする。
  static const _japanBounds = _MapBounds(
    west: 125.2,
    east: 149.2,
    south: 25.6,
    north: 47.6,
  );
  static const _worldBounds = _MapBounds(
    west: -180,
    east: 180,
    south: -56,
    north: 78,
  );

  static const _blank = Color(0xFFF6E6D4);
  static const _blankStroke = Color(0xFFE7D3C0);
  static const _visited = AppTheme.primaryOrange;
  static const _visitedStroke = AppTheme.orangeDark;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = japan ? _japanBounds : _worldBounds;
    final dest = _fit(size, bounds.aspect);
    final blank = Paint()..color = _blank;
    final blankLine = Paint()
      ..color = _blankStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    final filled = Paint()..color = _visited;
    final filledLine = Paint()
      ..color = _visitedStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    void draw({required bool visitedOnly}) {
      for (final region in regions) {
        final visited = visitedIds.contains(region.id);
        if (visited != visitedOnly) {
          continue;
        }
        final path = Path();
        for (final ring in _drawRings(region.rings)) {
          for (var i = 0; i < ring.length; i++) {
            final point = _project(ring[i], bounds, dest);
            if (i == 0) {
              path.moveTo(point.dx, point.dy);
            } else {
              path.lineTo(point.dx, point.dy);
            }
          }
          path.close();
        }
        canvas.drawPath(path, visited ? filled : blank);
        canvas.drawPath(path, visited ? filledLine : blankLine);
      }
    }

    draw(visitedOnly: false);
    draw(visitedOnly: true);
  }

  Rect _fit(Size size, double aspect) {
    final pad = japan ? 0.0 : 4.0;
    final availW = math.max(0, size.width - pad * 2);
    final availH = math.max(0, size.height - pad * 2);
    final boxAspect = availH == 0 ? aspect : availW / availH;
    late double width;
    late double height;
    if (boxAspect > aspect) {
      height = availH.toDouble();
      width = height * aspect;
    } else {
      width = availW.toDouble();
      height = aspect == 0 ? availH.toDouble() : width / aspect;
    }
    final rect = Rect.fromLTWH(
      (size.width - width) / 2,
      (size.height - height) / 2,
      width,
      height,
    );
    if (!japan) {
      final fittedHeight = math.min(
        availH.toDouble(),
        rect.height * worldShareMapHeightScale,
      );
      return Rect.fromCenter(
        center: rect.center,
        width: rect.width * worldShareMapZoom,
        height: fittedHeight * worldShareMapZoom,
      );
    }
    if (japanShareMapZoom == 1) {
      return rect;
    }
    return Rect.fromCenter(
      center: rect.center,
      width: rect.width * japanShareMapZoom,
      height: rect.height * japanShareMapZoom,
    );
  }

  Offset _project(List<double> lngLat, _MapBounds bounds, Rect dest) {
    final x = japan
        ? (lngLat[0] - bounds.west) / (bounds.east - bounds.west)
        : _worldX(lngLat[0]);
    final y = (bounds.north - lngLat[1]) / (bounds.north - bounds.south);
    return Offset(
      dest.left + x * dest.width,
      dest.top + y * dest.height,
    );
  }

  /// 切れ目からの東向き位置。0 が左端、1 が右端。
  double _worldX(double lng) {
    var shifted = (lng - worldShareCutLng) % 360;
    if (shifted < 0) {
      shifted += 360;
    }
    return shifted / 360;
  }

  /// 切れ目をまたぐ輪郭は、地図を横断する線にならないよう分ける。
  Iterable<List<List<double>>> _drawRings(
      List<List<List<double>>> rings) sync* {
    for (final ring in rings) {
      if (japan || ring.length < 2) {
        yield ring;
        continue;
      }
      var current = <List<double>>[ring.first];
      for (var i = 0; i < ring.length - 1; i++) {
        final jump = _worldX(ring[i + 1][0]) - _worldX(ring[i][0]);
        if (jump > 0.5 || jump < -0.5) {
          if (current.length >= 3) {
            yield current;
          }
          current = <List<double>>[ring[i + 1]];
        } else {
          current.add(ring[i + 1]);
        }
      }
      if (current.length >= 3) {
        yield current;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ShareFillMapPainter oldDelegate) {
    return oldDelegate.regions != regions ||
        oldDelegate.visitedIds != visitedIds ||
        oldDelegate.japan != japan;
  }
}
