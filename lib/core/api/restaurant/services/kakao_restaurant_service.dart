import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/api/client/dio_client.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/env.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kakao_restaurant_service.g.dart';

typedef PaginationList<T> = List<T>;

@riverpod
Future<PaginationList<Restaurant>> kakaoRestaurantServices(
  Ref ref,
  String keyword,
) async {
  final dio = ref.watch(dioClientProvider);
  final restaurants = <Restaurant>[];
  final kakaoRestaurants = await _search(dio, ref, keyword);
  restaurants.addAll(kakaoRestaurants);
  return restaurants;
}

Future<List<Restaurant>> _search(
  Dio dio,
  Ref ref,
  String keyword,
) async {
  final logger = Logger();
  try {
    final response = await dio.get<Map<String, dynamic>>(
      'https://dapi.kakao.com/v2/local/search/keyword.json',
      options: Options(
        headers: {
          'Authorization': 'KakaoAK ${Env.kakaoRestApiKey}',
        },
      ),
      queryParameters: {
        'query': keyword,
        'size': '15',
      },
    );
    if (response.statusCode == 200) {
      final data = response.data!;
      final documents = data['documents'] as List<dynamic>;

      return documents.map(
        (value) {
          return Restaurant.fromKakaoJson(value as Map<String, dynamic>);
        },
      ).toList();
    } else {
      return [];
    }
  } on DioException catch (e) {
    logger.e('Kakao API Error: Status ${e.response?.statusCode}');
    return [];
  }
}
