import 'dart:convert';
import 'dart:math' as math;

/// GeoJSON の国ポリゴンから、点の所属国を求める。
class CountryPolygonIndex {
  CountryPolygonIndex(this._parts);

  final List<_CountryPolygonPart> _parts;

  factory CountryPolygonIndex.parse(String geoJson) {
    final decoded = jsonDecode(geoJson) as Map<String, dynamic>;
    final features =
        (decoded['features'] as List<dynamic>).cast<Map<String, dynamic>>();
    final parts = <_CountryPolygonPart>[];
    for (final feature in features) {
      final properties =
          Map<String, dynamic>.from(feature['properties'] as Map);
      final code = properties['iso_a2'] as String?;
      if (code == null || code.length != 2) {
        continue;
      }
      final nameEn = (properties['name_en'] as String?) ?? code;
      final geometry = feature['geometry'] as Map<String, dynamic>?;
      if (geometry == null) {
        continue;
      }
      parts.addAll(
          _partsFromGeometry(code: code, nameEn: nameEn, geometry: geometry));
    }
    return CountryPolygonIndex(parts);
  }

  /// ポリゴン内、または海岸線にごく近い点なら ISO コードと英語名。
  ({String code, String nameEn})? find(double lat, double lng) {
    for (final part in _parts) {
      if (part.contains(lat, lng)) {
        return (code: part.code, nameEn: part.nameEn);
      }
    }
    return _nearestCoastalCountry(lat, lng);
  }

  /// 簡略化した海岸線の外側に落ちた都市を、近い国境に割り当てる。
  ({String code, String nameEn})? _nearestCoastalCountry(
    double lat,
    double lng,
  ) {
    const maxDistanceDeg = 0.25;
    _CountryPolygonPart? best;
    var bestDistance = maxDistanceDeg;
    for (final part in _parts) {
      if (!part.isNearBounds(lat, lng, maxDistanceDeg)) {
        continue;
      }
      final distance = part.distanceToOuterRing(lat, lng);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = part;
      }
    }
    if (best == null) {
      return null;
    }
    return (code: best.code, nameEn: best.nameEn);
  }
}

class _CountryPolygonPart {
  const _CountryPolygonPart({
    required this.code,
    required this.nameEn,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
    required this.rings,
  });

  final String code;
  final String nameEn;
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;
  final List<List<List<double>>> rings;

  bool contains(double lat, double lng) {
    if (lat < minLat || lat > maxLat || lng < minLng || lng > maxLng) {
      return false;
    }
    if (rings.isEmpty) {
      return false;
    }
    if (!_pointInRing(lng, lat, rings.first)) {
      return false;
    }
    for (var i = 1; i < rings.length; i++) {
      if (_pointInRing(lng, lat, rings[i])) {
        return false;
      }
    }
    return true;
  }

  bool isNearBounds(double lat, double lng, double padDeg) {
    return lat >= minLat - padDeg &&
        lat <= maxLat + padDeg &&
        lng >= minLng - padDeg &&
        lng <= maxLng + padDeg;
  }

  double distanceToOuterRing(double lat, double lng) {
    if (rings.isEmpty) {
      return double.infinity;
    }
    return _distanceToRing(lng, lat, rings.first);
  }
}

List<_CountryPolygonPart> _partsFromGeometry({
  required String code,
  required String nameEn,
  required Map<String, dynamic> geometry,
}) {
  final type = geometry['type'] as String?;
  final coordinates = geometry['coordinates'];
  if (type == 'Polygon' && coordinates is List) {
    final polygon = coordinates.cast<dynamic>();
    final part = _partFromPolygon(code: code, nameEn: nameEn, polygon: polygon);
    return part == null ? const [] : [part];
  }
  if (type == 'MultiPolygon' && coordinates is List) {
    final parts = <_CountryPolygonPart>[];
    for (final polygon in coordinates) {
      if (polygon is! List) {
        continue;
      }
      final part =
          _partFromPolygon(code: code, nameEn: nameEn, polygon: polygon);
      if (part != null) {
        parts.add(part);
      }
    }
    return parts;
  }
  return const [];
}

_CountryPolygonPart? _partFromPolygon({
  required String code,
  required String nameEn,
  required List<dynamic> polygon,
}) {
  final rings = <List<List<double>>>[];
  var minLat = 90.0;
  var maxLat = -90.0;
  var minLng = 180.0;
  var maxLng = -180.0;
  for (final rawRing in polygon) {
    if (rawRing is! List) {
      continue;
    }
    final ring = <List<double>>[];
    for (final point in rawRing) {
      if (point is! List || point.length < 2) {
        continue;
      }
      final lng = (point[0] as num).toDouble();
      final lat = (point[1] as num).toDouble();
      ring.add([lng, lat]);
      minLat = math.min(minLat, lat);
      maxLat = math.max(maxLat, lat);
      minLng = math.min(minLng, lng);
      maxLng = math.max(maxLng, lng);
    }
    if (ring.length >= 4) {
      rings.add(ring);
    }
  }
  if (rings.isEmpty) {
    return null;
  }
  return _CountryPolygonPart(
    code: code,
    nameEn: nameEn,
    minLat: minLat,
    maxLat: maxLat,
    minLng: minLng,
    maxLng: maxLng,
    rings: rings,
  );
}

bool _pointInRing(double lng, double lat, List<List<double>> ring) {
  var inside = false;
  final n = ring.length;
  if (n < 4) {
    return false;
  }
  var j = n - 1;
  for (var i = 0; i < n; i++) {
    final xi = ring[i][0];
    final yi = ring[i][1];
    final xj = ring[j][0];
    final yj = ring[j][1];
    final intersect = ((yi > lat) != (yj > lat)) &&
        (lng < (xj - xi) * (lat - yi) / (yj - yi) + xi);
    if (intersect) {
      inside = !inside;
    }
    j = i;
  }
  return inside;
}

double _distanceToRing(double lng, double lat, List<List<double>> ring) {
  var minDistance = double.infinity;
  for (var i = 1; i < ring.length; i++) {
    minDistance = math.min(
      minDistance,
      _distanceToSegment(lng, lat, ring[i - 1], ring[i]),
    );
  }
  return minDistance;
}

double _distanceToSegment(
  double lng,
  double lat,
  List<double> start,
  List<double> end,
) {
  final x1 = start[0];
  final y1 = start[1];
  final x2 = end[0];
  final y2 = end[1];
  final dx = x2 - x1;
  final dy = y2 - y1;
  if (dx == 0 && dy == 0) {
    return math.sqrt((lng - x1) * (lng - x1) + (lat - y1) * (lat - y1));
  }
  final t = ((lng - x1) * dx + (lat - y1) * dy) / (dx * dx + dy * dy);
  final clamped = t.clamp(0.0, 1.0);
  final px = x1 + dx * clamped;
  final py = y1 + dy * clamped;
  return math.sqrt((lng - px) * (lng - px) + (lat - py) * (lat - py));
}
