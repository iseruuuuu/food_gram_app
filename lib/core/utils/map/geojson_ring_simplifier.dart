/// 頂点を間引いた GeoJSON。短い輪郭は残し、潰れた輪郭は捨てる。
/// 壊れた輪郭を MapLibre に渡すと、塗りの内側と外側が入れ替わる。
List<Map<String, dynamic>> simplifyGeoJsonFeatures(
  List<Map<String, dynamic>> features,
) {
  return [
    for (final feature in features)
      if (_simplifiedGeometry(feature) case final geometry?)
        <String, dynamic>{
          ...feature,
          'geometry': geometry,
        },
  ];
}

const int _thinStep = 12;

Map<String, dynamic>? _simplifiedGeometry(Map<String, dynamic> feature) {
  final geometry = feature['geometry'];
  if (geometry is! Map) {
    return null;
  }
  final source = geometry.cast<String, dynamic>();
  final type = source['type'] as String?;
  final coordinates = _dropBrokenRings(
    type,
    _thinCoordinates(source['coordinates']),
  );
  if (coordinates == null) {
    return null;
  }
  return <String, dynamic>{
    ...source,
    'coordinates': coordinates,
  };
}

Object? _dropBrokenRings(String? type, Object? coordinates) {
  if (coordinates is! List) {
    return null;
  }
  if (type == 'Polygon') {
    final rings = _validRings(coordinates);
    return rings.isEmpty ? null : rings;
  }
  if (type == 'MultiPolygon') {
    final polygons = <List<Object?>>[];
    for (final polygon in coordinates) {
      if (polygon is! List) {
        continue;
      }
      final rings = _validRings(polygon);
      if (rings.isNotEmpty) {
        polygons.add(rings);
      }
    }
    return polygons.isEmpty ? null : polygons;
  }
  return coordinates;
}

List<Object?> _validRings(List<dynamic> rings) {
  return [
    for (final ring in rings)
      if (ring is List && ring.length >= 4) ring,
  ];
}

Object? _thinCoordinates(Object? node) {
  if (node is! List || node.isEmpty) {
    return node;
  }
  final first = node.first;
  if (first is num) {
    return node;
  }
  if (first is List && first.isNotEmpty && first.first is num) {
    if (node.length <= _thinStep * 4) {
      return node;
    }
    final kept = <Object?>[
      for (var i = 0; i < node.length; i += _thinStep) node[i],
    ];
    if (kept.last != node.last) {
      kept.add(node.last);
    }
    return kept;
  }
  return [
    for (final child in node) _thinCoordinates(child),
  ];
}
