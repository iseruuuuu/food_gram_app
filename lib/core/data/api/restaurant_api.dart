import 'package:dio/dio.dart';
import 'package:food_gram_app/constants/api_key.dart';
import 'package:food_gram_app/core/data/api/dio.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/utils/location.dart';
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
  final url = 'http://webservice.recruit.co.jp/hotpepper/gourmet/v1/';
  final currentLocation = ref.read(locationProvider).value;

  if (currentLocation == LatLng(0, 0)) {
    return [];
  }

  const resultsPerPage = 10;
  const maxPages = 6; // 取得する最大ページ数
  var start = 1;
  var hasMoreData = true;
  var currentPage = 0; // 現在のページ数
  final restaurants = <Restaurant>[];

  try {
    while (hasMoreData && currentPage < maxPages) {
      final response = await dio.get(
        url,
        queryParameters: {
          'key': RecruitApiKey.apikey,
          'lat': currentLocation!.latitude,
          'lng': currentLocation.longitude,
          'keyword': keyword,
          'range': 5,
          'start': start,
          'count': resultsPerPage,
        },
      );

      final data = response.data;
      final document = xml.XmlDocument.parse(data);
      final shopNodes = document.findAllElements('shop');
      if (shopNodes.isEmpty) {
        hasMoreData = false;
      } else {
        for (final shopNode in shopNodes) {
          final restaurant = Restaurant(
            name: shopNode.getElement('name')!.innerText,
            address: shopNode.getElement('address')!.innerText,
            lat: double.parse(shopNode.getElement('lat')!.innerText),
            lng: double.parse(shopNode.getElement('lng')!.innerText),
          );
          restaurants.add(restaurant);
        }
        start += resultsPerPage;
        currentPage++;
      }
    }

    return restaurants;
  } on DioException catch (error) {
    print(error);
    return throw UnimplementedError();
  }
}
