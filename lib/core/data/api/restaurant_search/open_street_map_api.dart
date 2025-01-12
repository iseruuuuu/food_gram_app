import 'dart:core';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/data/api/dio.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/utils/location.dart';
import 'package:geocoding/geocoding.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'open_street_map_api.g.dart';

typedef PaginationList<T> = List<T>;

/// nominatim.openstreetmap.org
@riverpod
Future<PaginationList<Restaurant>> openStreetMapApi(
  Ref ref,
  String keyword,
) async {
  final currentLocationFuture = ref.read(locationProvider.future);
  final currentLocation = await currentLocationFuture;

  if (currentLocation == LatLng(0, 0) || keyword.isEmpty) {
    return [];
  }

  final restaurants = <Restaurant>{};

  try {
    restaurants.addAll(await search(ref, keyword));
    final sortedRestaurants = restaurants.toList()
      ..sort((a, b) {
        final distanceA = calculateDistance(
          currentLocation.latitude,
          currentLocation.longitude,
          a.lat,
          a.lng,
        );
        final distanceB = calculateDistance(
          currentLocation.latitude,
          currentLocation.longitude,
          b.lat,
          b.lng,
        );
        return distanceA.compareTo(distanceB);
      });

    return sortedRestaurants;
  } on DioException catch (e) {
    print('Failed to fetch restaurant data: ${e.message}');
    return [];
  }
}

Future<List<Restaurant>> search(
  Ref ref,
  String keyword,
) async {
  final dio = ref.watch(dioProvider);
  final currentLocationFuture = ref.read(locationProvider.future);
  final currentLocation = await currentLocationFuture;

  if (currentLocation == LatLng(0, 0) || keyword.isEmpty) {
    return [];
  }

  const resultsPerPage = 10;
  final restaurants = <Restaurant>[];

  try {
    final response = await dio.get(
      'https://nominatim.openstreetmap.org/search',
      queryParameters: {
        'q': keyword,
        'format': 'json',
        'addressdetails': 1,
        'limit': resultsPerPage,
      },
    );
    if (response.statusCode == 200) {
      final data = response.data as List<dynamic>;
      for (final item in data) {
        final displayName = item['name'] as String?;
        final lat = double.tryParse(item['lat'] as String? ?? '');
        final lng = double.tryParse(item['lon'] as String? ?? '');
        final placeMark = await placemarkFromCoordinates(lat!, lng!);
        final address = placeMark[0].name;
        final restaurant = Restaurant(
          name: displayName!,
          address: address!,
          lat: lat,
          lng: lng,
        );
        restaurants.add(restaurant);
      }
    } else {
      print('Failed to fetch suggestions: ${response.statusCode}');
    }
  } on DioException catch (e) {
    print('DioException occurred: ${e.message}');
  } catch (e) {
    print('Unexpected error: $e');
  }
  return restaurants;
}

/// Haversine Formulaを用いた距離計算
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371; // km
  final dLat = _degToRad(lat2 - lat1);
  final dLon = _degToRad(lon2 - lon1);

  final a = (sin(dLat / 2) * sin(dLat / 2)) +
      cos(_degToRad(lat1)) *
          cos(_degToRad(lat2)) *
          (sin(dLon / 2) * sin(dLon / 2));
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

double _degToRad(double deg) => deg * (pi / 180);

// void main() async {
//   final dio = Dio();
//   final api = OpenStreetMapApi(dio);
//
//   // 検索クエリを指定
//   final query = 'ガスト';
//   final results = await api.searchPlaces(query);
//
//   for (var result in results) {
//     print('Name: ${result.displayName}');
//     print('Lat: ${result.lat}');
//     print('Lon: ${result.lon}');
//     print('Address: ${result.address}');
//     print('---');
//   }
// }
