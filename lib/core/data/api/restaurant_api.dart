import 'dart:core';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:food_gram_app/core/data/api/restaurant_search/google_restaurant_api.dart';
import 'package:food_gram_app/core/data/api/restaurant_search/hotpepper_restaurant_api.dart';
import 'package:food_gram_app/core/data/api/restaurant_search/mapbox_restaurant_api.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/utils/location.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'restaurant_api.g.dart';

typedef PaginationList<T> = List<T>;

@riverpod
Future<PaginationList<Restaurant>> restaurantApi(
  RestaurantApiRef ref,
  String keyword,
) async {
  final currentLocationFuture = ref.read(locationProvider.future);
  final currentLocation = await currentLocationFuture;
  if (keyword.isEmpty) {
    return [];
  }
  try {
    final restaurants = <Restaurant>[];
    final mapbox = await ref.read(mapboxRestaurantApiProvider(keyword).future);
    final google = await ref.read(googleRestaurantApiProvider(keyword).future);
    final hotpepper =
        await ref.read(hotPepperRestaurantProvider(keyword).future);
    restaurants
      ..addAll(mapbox)
      ..addAll(google)
      ..addAll(hotpepper);
    final filteredRestaurants = removeDuplicateRestaurants(restaurants)
      ..sort((a, b) {
        final lat1 = currentLocation.latitude;
        final lon1 = currentLocation.longitude;
        final distanceA = calculateDistance(lat1, lon1, a.lat, a.lng);
        final distanceB = calculateDistance(lat1, lon1, b.lat, b.lng);
        return distanceA.compareTo(distanceB);
      });
    return filteredRestaurants;
  } on DioException catch (_) {
    return [];
  }
}

/// 重複を除外する関数
List<Restaurant> removeDuplicateRestaurants(
  List<Restaurant> restaurants, {
  double thresholdInMeters = 100,
}) {
  final uniqueRestaurants = <Restaurant>[];

  for (final restaurant in restaurants) {
    var isDuplicate = false;
    for (final uniqueRestaurant in uniqueRestaurants) {
      final distance = calculateDistance(
        restaurant.lat,
        restaurant.lng,
        uniqueRestaurant.lat,
        uniqueRestaurant.lng,
      );
      if (distance <= thresholdInMeters) {
        isDuplicate = true;
        break;
      }
    }

    if (!isDuplicate) {
      uniqueRestaurants.add(restaurant);
    }
  }

  return uniqueRestaurants;
}

/// ハバーサインの公式で2つの緯度・経度の距離を計算
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371000; // 地球の半径（メートル）

  final dLat = _degreesToRadians(lat2 - lat1);
  final dLon = _degreesToRadians(lon2 - lon1);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(lat1)) *
          cos(_degreesToRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c; // 距離（メートル）
}

/// 度をラジアンに変換
double _degreesToRadians(double degrees) {
  return degrees * pi / 180;
}
