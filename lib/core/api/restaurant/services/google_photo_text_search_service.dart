import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/api/restaurant/photo_nearby_food_types.dart';
import 'package:food_gram_app/core/model/photo_restaurant_candidate.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/utils/geo_distance.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'google_photo_text_search_service.g.dart';

/// Text Search で拾う最大距離（屋内GPSのズレを考慮）
const photoNearbyTextSearchMaxMeters = 100.0;

/// 写真の撮影位置を基準に、Google Text Search で飲食店を検索する。
@riverpod
Future<List<PhotoRestaurantCandidate>> googlePhotoTextSearchService(
  Ref ref, {
  required double latitude,
  required double longitude,
}) async {
  final logger = Logger();
  final location = '$latitude,$longitude';
  final merged = <PhotoRestaurantCandidate>[];

  for (final query in photoNearbyTextSearchQueries) {
    try {
      final supabase = ref.read(supabaseProvider);
      final response = await supabase.functions.invoke(
        'Google-Place-Restaurant-Search-',
        body: {
          'query': query,
          'language': 'ja',
          'location': location,
          'platform': Platform.isIOS ? 'ios' : 'android',
        },
      );

      if (response.status != 200) {
        logger.w(
          'Photo text search non-200: query=$query, '
          'status=${response.status}, data=${response.data}',
        );
        continue;
      }

      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];

      for (final raw in results) {
        final candidate = _fromLegacyResult(
          json: raw as Map<String, dynamic>,
          photoLat: latitude,
          photoLng: longitude,
        );
        if (candidate != null &&
            candidate.distanceMeters <= photoNearbyTextSearchMaxMeters) {
          merged.add(candidate);
        }
      }
    } on Exception catch (e, st) {
      logger.w(
        'Photo text search error: query=$query',
        error: e,
        stackTrace: st,
      );
    }
  }

  return _dedupeByLocation(merged)
    ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
}

List<PhotoRestaurantCandidate> _dedupeByLocation(
  List<PhotoRestaurantCandidate> candidates,
) {
  final seen = <String>{};
  final unique = <PhotoRestaurantCandidate>[];
  for (final candidate in candidates) {
    final key =
        '${candidate.name}_${candidate.lat.toStringAsFixed(4)}_${candidate.lng.toStringAsFixed(4)}';
    if (seen.add(key)) {
      unique.add(candidate);
    }
  }
  return unique;
}

PhotoRestaurantCandidate? _fromLegacyResult({
  required Map<String, dynamic> json,
  required double photoLat,
  required double photoLng,
}) {
  try {
    final restaurant = Restaurant.fromJson(json);
    if (restaurant.name.trim().isEmpty) {
      return null;
    }
    final distanceMeters = geoMeters(
      lat1: photoLat,
      lon1: photoLng,
      lat2: restaurant.lat,
      lon2: restaurant.lng,
    );
    return PhotoRestaurantCandidate(
      name: restaurant.name,
      address: restaurant.address,
      lat: restaurant.lat,
      lng: restaurant.lng,
      distanceMeters: distanceMeters,
      source: PhotoRestaurantSource.google,
    );
  } on Object {
    return null;
  }
}
