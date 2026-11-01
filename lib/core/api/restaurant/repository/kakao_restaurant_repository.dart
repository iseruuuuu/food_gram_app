import 'dart:core';

import 'package:food_gram_app/core/api/restaurant/services/kakao_restaurant_service.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/utils/geo_distance.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kakao_restaurant_repository.g.dart';

typedef PaginationList<T> = List<T>;

/// 検索中の await で Ref が dispose されないよう keepAlive。
@Riverpod(keepAlive: true)
Future<PaginationList<Restaurant>> kakaoRestaurantRepository(
  Ref ref,
  String keyword,
) async {
  if (keyword.isEmpty) {
    return [];
  }
  final logger = Logger();
  try {
    final currentLocation = await ref.read(locationProvider.future);
    if (!ref.mounted) {
      return [];
    }
    final restaurants = <Restaurant>[];
    final addedLocations = <String>{};
    final kakao =
        await ref.read(kakaoRestaurantServicesProvider(keyword).future);
    if (!ref.mounted) {
      return [];
    }
    void addUniqueRestaurants(List<Restaurant> source) {
      for (final restaurant in source) {
        final locationKey = '${restaurant.lat},${restaurant.lng}';
        if (!addedLocations.contains(locationKey)) {
          addedLocations.add(locationKey);
          restaurants.add(restaurant);
        }
      }
    }

    addUniqueRestaurants(kakao);
    restaurants.sort((a, b) {
      final lat1 = currentLocation.latitude;
      final lon1 = currentLocation.longitude;
      final distanceA =
          geoKilometers(lat1: lat1, lon1: lon1, lat2: a.lat, lon2: a.lng);
      final distanceB =
          geoKilometers(lat1: lat1, lon1: lon1, lat2: b.lat, lon2: b.lng);
      return distanceA.compareTo(distanceB);
    });
    return restaurants;
  } on Exception catch (e, st) {
    logger.e(
      'kakaoRestaurantRepository failed: $e',
      error: e,
      stackTrace: st,
    );
    rethrow;
  }
}
