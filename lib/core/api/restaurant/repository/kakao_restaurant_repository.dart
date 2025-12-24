import 'dart:core';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/api/restaurant/services/kakao_restaurant_service.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/utils/geo_distance.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kakao_restaurant_repository.g.dart';

typedef PaginationList<T> = List<T>;

@riverpod
Future<PaginationList<Restaurant>> kakaoRestaurantRepository(
  Ref ref,
  String keyword,
) async {
  if (keyword.isEmpty) {
    return [];
  }
  try {
    final currentLocationFuture = ref.read(locationProvider.future);
    final currentLocation = await currentLocationFuture;
    final restaurants = <Restaurant>[];
    final addedLocations = <String>{};
    final kakao =
        await ref.read(kakaoRestaurantServicesProvider(keyword).future);
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
  } on Exception catch (_) {
    return [];
  }
}
