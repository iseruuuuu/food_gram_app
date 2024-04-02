import 'package:dio/dio.dart';
import 'package:food_gram_app/constants/api_key.dart';
import 'package:food_gram_app/core/data/api/dio.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:xml/xml.dart' as xml;

part 'restaurant_api.g.dart';

typedef PaginationList<T> = (List<T> list,);

@riverpod
Future<List<Restaurant>> restaurant(
  RestaurantRef ref,
  String keyword,
) async {
  final dio = ref.watch(dioProvider);
  try {
    final url = 'http://webservice.recruit.co.jp/hotpepper/gourmet/v1/';
    final currentLocation = await _getCurrentLocation();
    if (currentLocation == LatLng(0, 0)) {
      return [];
    }
    final response = await dio.get(
      url,
      queryParameters: {
        'key': RecruitApiKey.apikey,
        'lat': currentLocation.latitude,
        'lng': currentLocation.longitude,
        'keyword': keyword,
        'range': 5,
      },
    );
    final data = response.data;
    final document = xml.XmlDocument.parse(data);
    final shopNodes = document.findAllElements('shop');
    final restaurants = <Restaurant>[];
    for (final shopNode in shopNodes) {
      final restaurant = Restaurant(
        name: shopNode.getElement('name')!.innerText,
        address: shopNode.getElement('address')!.innerText,
        lat: double.parse(shopNode.getElement('lat')!.innerText),
        lng: double.parse(shopNode.getElement('lng')!.innerText),
      );
      restaurants.add(restaurant);
    }
    return restaurants;
  } on DioException catch (error) {
    print(error);
    return throw UnimplementedError();
  }
}

Future<LatLng> _getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return LatLng(0, 0);
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return LatLng(0, 0);
    }
  }
  if (permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always) {
    final position = await Geolocator.getCurrentPosition();
    final latitude = position.latitude;
    final longitude = position.longitude;
    return LatLng(latitude, longitude);
  }
  return LatLng(0, 0);
}
