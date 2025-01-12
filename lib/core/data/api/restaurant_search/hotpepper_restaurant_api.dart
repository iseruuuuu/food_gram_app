import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/data/api/dio.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/utils/location.dart';
import 'package:food_gram_app/env.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:xml/xml.dart' as xml;

part 'hotpepper_restaurant_api.g.dart';

typedef PaginationList<T> = (List<T> list,);

@riverpod
Future<List<Restaurant>> hotPepperRestaurant(
  Ref ref,
  String keyword,
) async {
  final dio = ref.watch(dioProvider);
  try {
    final url = 'http://webservice.recruit.co.jp/hotpepper/gourmet/v1/';
    final currentLocationFuture = ref.read(locationProvider.future);
    final currentLocation = await currentLocationFuture;
    if (currentLocation == LatLng(0, 0) || keyword == '') {
      return [];
    }
    final response = await dio.get(
      url,
      queryParameters: {
        'key': Env.hotPepper,
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
  } on DioException catch (_) {
    return throw UnimplementedError();
  }
}
