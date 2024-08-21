import 'dart:io';

import 'package:dio/dio.dart';
import 'package:food_gram_app/core/data/api/dio.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/utils/location.dart';
import 'package:food_gram_app/env.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'google_restaurant_api.g.dart';

typedef PaginationList<T> = List<T>;

@riverpod
Future<PaginationList<Restaurant>> googleRestaurantApi(
  GoogleRestaurantApiRef ref,
  String keyword,
) async {
  final dio = ref.watch(dioProvider);
  final currentLocationFuture = ref.read(locationProvider.future);
  final currentLocation = await currentLocationFuture;
  if (currentLocation == LatLng(0, 0) || keyword.isEmpty) {
    return [];
  }
  final restaurants = <Restaurant>[];
  final googleRestaurants =
      await _fetchFromGoogleMapsApi(dio, currentLocation, keyword);
  restaurants.addAll(googleRestaurants);
  return restaurants;
}

Future<List<Restaurant>> _fetchFromGoogleMapsApi(
  Dio dio,
  LatLng location,
  String keyword,
) async {
  final response = await dio.get(
    'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
    queryParameters: {
      'location': '${location.latitude},${location.longitude}',
      'radius': '50000',
      'type': 'restaurant',
      'keyword': keyword,
      'key': Platform.isIOS ? Env.iOSGoogleApikey : Env.androidGoogleApikey,
    },
  );
  if (response.statusCode == 200) {
    final data = response.data;
    return List<Restaurant>.from(
      data['results'].map(
        (restaurant) => Restaurant(
          name: restaurant['name'],
          address: restaurant['vicinity'],
          lat: restaurant['geometry']['location']['lat'],
          lng: restaurant['geometry']['location']['lng'],
        ),
      ),
    );
  } else {
    return [];
  }
}
