import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/api/restaurant/photo_nearby_food_types.dart';
import 'package:food_gram_app/core/model/photo_restaurant_candidate.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/utils/geo_distance.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'google_nearby_restaurant_service.g.dart';

const _mallLikeTypes = {
  'shopping_mall',
  'transit_station',
  'subway_station',
  'train_station',
  'department_store',
  'food_court',
};

@riverpod
Future<List<PhotoRestaurantCandidate>> googleNearbyRestaurantService(
  Ref ref, {
  required double latitude,
  required double longitude,
  required int radiusMeters,
}) async {
  final logger = Logger();
  try {
    final supabase = ref.read(supabaseProvider);
    final response = await supabase.functions.invoke(
      'google-place-nearby-search',
      body: {
        'latitude': latitude,
        'longitude': longitude,
        'radiusMeters': radiusMeters,
        'maxResultCount': 20,
        'includedTypes': photoNearbyFoodPlaceTypes,
        'language': 'ja',
        'platform': Platform.isIOS ? 'ios' : 'android',
      },
    );

    if (response.status != 200) {
      logger.w(
        'Nearby search non-200: status=${response.status}, data=${response.data}',
      );
      return [];
    }

    final data = response.data as Map<String, dynamic>;
    if (data.containsKey('error')) {
      logger.w('Nearby search API error: ${data['error']}');
      return [];
    }

    final places = data['places'] as List<dynamic>? ?? [];
    if (places.isEmpty) {
      logger.i(
        'Nearby search empty: lat=$latitude, lng=$longitude, radius=$radiusMeters',
      );
    }

    return places
        .map(
          (raw) => _parsePlace(
            json: raw as Map<String, dynamic>,
            photoLat: latitude,
            photoLng: longitude,
          ),
        )
        .whereType<PhotoRestaurantCandidate>()
        .toList();
  } on Exception catch (e, st) {
    logger.w('Nearby search error', error: e, stackTrace: st);
    return [];
  }
}

PhotoRestaurantCandidate? _parsePlace({
  required Map<String, dynamic> json,
  required double photoLat,
  required double photoLng,
}) {
  final businessStatus = json['businessStatus'] as String?;
  if (businessStatus == 'CLOSED_PERMANENTLY') {
    return null;
  }

  final location = json['location'] as Map<String, dynamic>?;
  if (location == null) {
    return null;
  }
  final lat = (location['latitude'] as num).toDouble();
  final lng = (location['longitude'] as num).toDouble();
  final distanceMeters = geoMeters(
    lat1: photoLat,
    lon1: photoLng,
    lat2: lat,
    lon2: lng,
  );

  final openingHours = json['currentOpeningHours'] as Map<String, dynamic>?;
  final isOpenNow = openingHours?['openNow'] as bool?;

  final types = (json['types'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      [];

  final displayName = json['displayName'] as Map<String, dynamic>?;
  final name = displayName?['text'] as String? ?? '';
  if (name.trim().isEmpty) {
    return null;
  }

  return PhotoRestaurantCandidate(
    name: name,
    address: json['formattedAddress'] as String? ?? '',
    lat: lat,
    lng: lng,
    distanceMeters: distanceMeters,
    source: PhotoRestaurantSource.google,
    rating: (json['rating'] as num?)?.toDouble(),
    isOpenNow: isOpenNow,
    hint: _mallHint(types, distanceMeters),
  );
}

String? _mallHint(List<String> types, double distanceMeters) {
  final hasMallLike = types.any(_mallLikeTypes.contains);
  if (!hasMallLike && distanceMeters <= 50) {
    return null;
  }
  if (hasMallLike) {
    return 'mall_hint';
  }
  if (distanceMeters > 50) {
    return 'distance_hint';
  }
  return null;
}
