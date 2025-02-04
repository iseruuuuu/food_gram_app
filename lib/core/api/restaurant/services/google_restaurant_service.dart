import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/api/client/dio_client.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/env.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'google_restaurant_service.g.dart';

typedef PaginationList<T> = List<T>;

@riverpod
Future<PaginationList<Restaurant>> googleRestaurantServices(
  Ref ref,
  String keyword,
) async {
  final dio = ref.watch(dioClientProvider);
  final restaurants = <Restaurant>[];
  final googleRestaurants = await _search(dio, ref, keyword);
  restaurants.addAll(googleRestaurants);
  return restaurants;
}

Future<List<Restaurant>> _search(
  Dio dio,
  Ref ref,
  String keyword,
) async {
  final currentLocationFuture = ref.read(locationProvider.future);
  final currentLocation = await currentLocationFuture;
  final response = await dio.get(
    'https://maps.googleapis.com/maps/api/place/textsearch/json',
    queryParameters: {
      'query': keyword,
      'key': Platform.isIOS ? Env.iOSGoogleApikey : Env.androidGoogleApikey,
      'language': 'ja',
      'location': '${currentLocation.latitude},${currentLocation.longitude}',
    },
  );
  if (response.statusCode == 200) {
    final data = response.data;
    return List<Restaurant>.from(
      data['results'].map(
        (restaurant) => Restaurant(
          name: restaurant['name'],
          address: restaurant['formatted_address'],
          lat: restaurant['geometry']['location']['lat'],
          lng: restaurant['geometry']['location']['lng'],
        ),
      ),
    );
  } else {
    return [];
  }
}
