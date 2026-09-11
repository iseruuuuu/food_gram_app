import 'package:food_gram_app/core/utils/geo_distance.dart';

/// 店名＋座標の近さで「同じ店」とみなす閾値（約 30m）
const nearbyRestaurantCoordThreshold = 0.0003;

/// カメラ中心から近い順に返す店舗数
const nearbyRestaurantLimit = 20;

/// [centerLat] / [centerLng] から近いレストラン順に投稿を並べ、上位 [limit] 店の投稿を返す。
List<Map<String, dynamic>> pickClosestRestaurantPosts({
  required List<Map<String, dynamic>> posts,
  required double centerLat,
  required double centerLng,
  int limit = nearbyRestaurantLimit,
}) {
  final groups = <_RestaurantPostGroup>[];
  for (final post in posts) {
    final name = (post['restaurant'] as String? ?? '').trim();
    final lat = _readCoord(post['lat']);
    final lng = _readCoord(post['lng']);
    final existingIndex = groups.indexWhere(
      (g) =>
          g.name == name &&
          (lat - g.lat).abs() <= nearbyRestaurantCoordThreshold &&
          (lng - g.lng).abs() <= nearbyRestaurantCoordThreshold,
    );
    if (existingIndex == -1) {
      groups.add(
        _RestaurantPostGroup(
          name: name,
          lat: lat,
          lng: lng,
          posts: [post],
        ),
      );
    } else {
      groups[existingIndex].posts.add(post);
    }
  }

  groups.sort(
    (a, b) => a
        .minDistanceKm(centerLat, centerLng)
        .compareTo(b.minDistanceKm(centerLat, centerLng)),
  );

  final result = <Map<String, dynamic>>[];
  for (final group in groups.take(limit)) {
    final newestFirst = [...group.posts]..sort((a, b) {
        final aCreated = a['created_at']?.toString() ?? '';
        final bCreated = b['created_at']?.toString() ?? '';
        return bCreated.compareTo(aCreated);
      });
    result.addAll(newestFirst);
  }
  return result;
}

double _readCoord(dynamic value) => double.parse(value.toString());

class _RestaurantPostGroup {
  _RestaurantPostGroup({
    required this.name,
    required this.lat,
    required this.lng,
    required this.posts,
  });

  final String name;
  final double lat;
  final double lng;
  final List<Map<String, dynamic>> posts;

  double minDistanceKm(double centerLat, double centerLng) {
    var minDistance = double.infinity;
    for (final post in posts) {
      final distance = geoKilometers(
        lat1: centerLat,
        lon1: centerLng,
        lat2: _readCoord(post['lat']),
        lon2: _readCoord(post['lng']),
      );
      if (distance < minDistance) {
        minDistance = distance;
      }
    }
    return minDistance;
  }
}
