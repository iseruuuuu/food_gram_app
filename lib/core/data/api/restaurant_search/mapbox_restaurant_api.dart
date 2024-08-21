import 'dart:core';

import 'package:dio/dio.dart';
import 'package:food_gram_app/core/data/api/dio.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/utils/location.dart';
import 'package:food_gram_app/env.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mapbox_restaurant_api.g.dart';

typedef PaginationList<T> = List<T>;

@riverpod
Future<PaginationList<Restaurant>> mapboxRestaurantApi(
  MapboxRestaurantApiRef ref,
  String keyword,
) async {
  final dio = ref.watch(dioProvider);
  final currentLocationFuture = ref.read(locationProvider.future);
  final currentLocation = await currentLocationFuture;
  if (currentLocation == LatLng(0, 0) || keyword == '') {
    return [];
  }
  const resultsPerPage = 10;
  final restaurants = <Restaurant>[];
  final restaurantNamesSet = <String>{};
  try {
    final response = await dio.get(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$keyword.json',
      queryParameters: {
        'proximity': '${currentLocation.longitude},${currentLocation.latitude}',
        'access_token': Env.mapbox,
        'limit': resultsPerPage,
      },
    );
    if (response.statusCode == 200) {
      final data = response.data;
      final features = data['features'] as List<dynamic>;
      for (final feature in features) {
        final placeName = feature['text'] as String;
        final isCategoryMatched = category.any(
          (category) => placeName.toLowerCase().contains(category),
        );

        ///TODO ひとまずちゃんと検索が出るようにするために一度全部みれるようにする
        ///TODO このあとしっかりと調査をする必要がありそう
        final placeType =
            (feature['place_type'] as List<dynamic>).contains('poi');
        if (isCategoryMatched || placeType) {
          final address = feature['place_name'] as String;
          final geometry = feature['geometry']['coordinates'] as List<dynamic>;
          final lat = geometry[1] as double;
          final lng = geometry[0] as double;
          final restaurant = Restaurant(
            name: placeName,
            address: address,
            lat: lat,
            lng: lng,
          );
          restaurants.add(restaurant);
          restaurantNamesSet.add(placeName);
        }
      }
    }
    restaurants.sort((a, b) {
      final distanceA = (a.lat - currentLocation.latitude).abs() +
          (a.lng - currentLocation.longitude).abs();
      final distanceB = (b.lat - currentLocation.latitude).abs() +
          (b.lng - currentLocation.longitude).abs();
      return distanceA.compareTo(distanceB);
    });
    return restaurants;
  } on DioException catch (e) {
    print('Failed to fetch restaurant data: ${e.message}');
    return [];
  }
}

final category = [
  'japanese food',
  'food',
  'bar',
  'sake',
  'alcohol',
  'fast food',
  'diner',
  'steakhouse',
  'steak',
  'yoshoku',
  'sweets',
  'italian restaurant',
  'chinese restaurant',
  'cafe',
  'coffee',
  'bakery',
  'tea',
  'snack',
  'burger joint',
  'fast-food',
];
