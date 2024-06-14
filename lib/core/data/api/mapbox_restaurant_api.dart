import 'package:dio/dio.dart';
import 'package:food_gram_app/core/data/api/dio.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/utils/location.dart';
import 'package:food_gram_app/env.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  if (currentLocation == LatLng(0, 0)) {
    return [];
  }
  final queries = [
    keyword,
    '$keyword restaurant',
    '$keyword food',
    'restaurant near $keyword',
  ];
  const resultsPerPage = 10;
  const maxPages = 1;
  final restaurants = <Restaurant>[];
  final restaurantNamesSet = <String>{};
  try {
    restaurants.clear();
    for (final query in queries) {
      var hasMoreData = true;
      var currentPage = 0;
      while (hasMoreData && currentPage < maxPages) {
        final response = await dio.get(
          'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json',
          queryParameters: {
            'proximity':
                '${currentLocation!.longitude},${currentLocation.latitude}',
            'access_token': Env.mapbox,
            'limit': resultsPerPage,
            'offset': (currentPage * resultsPerPage).toString(),
            'types': 'poi',
          },
        );
        if (response.statusCode == 200) {
          final data = response.data;
          final features = data['features'] as List<dynamic>;
          if (features.isEmpty) {
            hasMoreData = false;
          } else {
            for (final feature in features) {
              final placeName = feature['text'] as String;
              if (!restaurantNamesSet.contains(placeName)) {
                final address = feature['place_name'] as String;
                final geometry =
                    feature['geometry']['coordinates'] as List<dynamic>;
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
            currentPage++;
          }
        } else {
          hasMoreData = false;
        }
      }
    }
    restaurants.sort((a, b) {
      final distanceA = (a.lat - currentLocation!.latitude).abs() +
          (a.lng - currentLocation.longitude).abs();
      final distanceB = (b.lat - currentLocation.latitude).abs() +
          (b.lng - currentLocation.longitude).abs();
      return distanceA.compareTo(distanceB);
    });
    return restaurants;
  } on DioException catch (_) {
    return throw UnimplementedError();
  }
}
