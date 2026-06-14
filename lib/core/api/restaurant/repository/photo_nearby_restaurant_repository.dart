import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/api/restaurant/services/google_nearby_restaurant_service.dart';
import 'package:food_gram_app/core/api/restaurant/services/google_photo_text_search_service.dart';
import 'package:food_gram_app/core/model/photo_restaurant_candidate.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_nearby_restaurant_repository.g.dart';

const _maxCandidates = 10;

/// Nearby Search の検索半径
const _searchRadiiMeters = [50, 100, 150];

/// 表示する距離の段階（近い順に埋める）
const _displayDistanceTiersMeters = [30.0, 60.0, 100.0];

/// 写真の撮影位置から近くのレストラン候補を取得する。
///
/// - Nearby Search（飲食店 type 網羅・距離順）
/// - Text Search（日本語クエリ・常に併用）
/// - 最終的に距離が近い順に最大10件
@riverpod
Future<List<PhotoRestaurantCandidate>> photoNearbyRestaurant(
  Ref ref, {
  required double latitude,
  required double longitude,
}) async {
  final nearby = await _fetchNearbyCandidates(
    ref,
    latitude: latitude,
    longitude: longitude,
  );

  final textSearch = await ref.read(
    googlePhotoTextSearchServiceProvider(
      latitude: latitude,
      longitude: longitude,
    ).future,
  );

  return _pickClosest(_mergeCandidates([...nearby, ...textSearch]));
}

Future<List<PhotoRestaurantCandidate>> _fetchNearbyCandidates(
  Ref ref, {
  required double latitude,
  required double longitude,
}) async {
  var lastResult = <PhotoRestaurantCandidate>[];
  for (final radius in _searchRadiiMeters) {
    lastResult = await ref.read(
      googleNearbyRestaurantServiceProvider(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radius,
      ).future,
    );
    if (lastResult.isNotEmpty || radius == _searchRadiiMeters.last) {
      return lastResult;
    }
  }
  return lastResult;
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
    final key =
        '${candidate.name}_${candidate.lat.toStringAsFixed(4)}_${candidate.lng.toStringAsFixed(4)}';
    if (seen.add(key)) {
      unique.add(candidate);
    }
  }
  return unique;
}

/// 近い距離帯から優先して最大10件（純粋に距離順）
List<PhotoRestaurantCandidate> _pickClosest(
  List<PhotoRestaurantCandidate> candidates,
) {
  final sorted = [...candidates]
    ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

  for (final maxDist in _displayDistanceTiersMeters) {
    final tier = sorted.where((c) => c.distanceMeters <= maxDist).toList();
    if (tier.length >= _maxCandidates ||
        maxDist == _displayDistanceTiersMeters.last) {
      return tier.take(_maxCandidates).toList();
    }
  }

  return sorted.take(_maxCandidates).toList();
}
