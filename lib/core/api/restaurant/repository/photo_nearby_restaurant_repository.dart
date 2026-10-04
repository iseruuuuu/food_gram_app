import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/api/restaurant/services/google_nearby_restaurant_service.dart';
import 'package:food_gram_app/core/model/photo_restaurant_candidate.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_nearby_restaurant_repository.g.dart';

const _maxCandidates = 10;

/// Nearby Search を距離順で1回だけ呼ぶ半径。
const _searchRadiusMeters = 150;

/// 表示する距離の段階（近い順に埋める）
const _displayDistanceTiersMeters = [30.0, 60.0, 100.0];

/// 写真の撮影位置から近くのレストラン候補を取得する。
///
/// Nearby Search を 150m・距離順で1回だけ呼ぶ。
/// 店名の Text Search は投稿画面と地図検索に残し、写真では呼ばない。
@riverpod
Future<List<PhotoRestaurantCandidate>> photoNearbyRestaurant(
  Ref ref, {
  required double latitude,
  required double longitude,
}) async {
  final nearby = await ref.read(
    googleNearbyRestaurantServiceProvider(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: _searchRadiusMeters,
    ).future,
  );

  return _pickClosest(_mergeCandidates(nearby));
}

List<PhotoRestaurantCandidate> _mergeCandidates(
  List<PhotoRestaurantCandidate> candidates,
) {
  final seen = <String>{};
  final unique = <PhotoRestaurantCandidate>[];
  for (final candidate in candidates) {
    if (candidate.name.trim().isEmpty) {
      continue;
    }
    final key = _locationKey(candidate);
    if (seen.add(key)) {
      unique.add(candidate);
    }
  }
  return unique;
}

String _locationKey(PhotoRestaurantCandidate candidate) {
  final lat = candidate.lat.toStringAsFixed(4);
  final lng = candidate.lng.toStringAsFixed(4);
  return '${candidate.name}_${lat}_$lng';
}

/// 近い距離帯から優先して最大10件（純粋に距離順）
List<PhotoRestaurantCandidate> _pickClosest(
  List<PhotoRestaurantCandidate> candidates,
) {
  final sorted = [...candidates]
    ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

  for (final maxDist in _displayDistanceTiersMeters) {
    final tier = sorted.where((c) => c.distanceMeters <= maxDist).toList();
    if (tier.length >= _maxCandidates) {
      return tier.take(_maxCandidates).toList();
    }
  }

  return sorted.take(_maxCandidates).toList();
}
