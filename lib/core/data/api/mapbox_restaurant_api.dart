import 'package:dio/dio.dart';
import 'package:food_gram_app/core/data/api/dio.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/utils/location.dart';
import 'package:food_gram_app/env.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mapbox_restaurant_api.g.dart';

typedef PaginationList<T> = (List<T> list,);

@riverpod
Future<List<Restaurant>> mapboxRestaurant(
  MapboxRestaurantRef ref,
  String keyword,
) async {
  final dio = ref.watch(dioProvider);
  //TODO 検索の方法をもう少し安易検索でも引っかかるようにしたい
  final url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/$keyword.json';
  final currentLocation = ref.read(locationProvider).value;

  if (currentLocation == LatLng(0, 0)) {
    return [];
  }

  const resultsPerPage = 20;
  const maxPages = 6; // 取得する最大ページ数
  var hasMoreData = true;
  var currentPage = 0; // 現在のページ数
  final restaurants = <Restaurant>[];
  final restaurantNamesSet = <String>{};

  try {
    restaurants.clear();
    while (hasMoreData && currentPage < maxPages) {
      final response = await dio.get(
        url,
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
