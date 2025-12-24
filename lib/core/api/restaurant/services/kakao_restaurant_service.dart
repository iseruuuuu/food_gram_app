import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kakao_restaurant_service.g.dart';

typedef PaginationList<T> = List<T>;

@riverpod
Future<PaginationList<Restaurant>> kakaoRestaurantServices(
  Ref ref,
  String keyword,
) async {
  final restaurants = <Restaurant>[];
  final kakaoRestaurants = await _search(ref, keyword);
  restaurants.addAll(kakaoRestaurants);
  return restaurants;
}

Future<List<Restaurant>> _search(
  Ref ref,
  String keyword,
) async {
  final logger = Logger();
  try {
    // 現在地を取得（Kakao Local APIは y=緯度(lat), x=経度(lon) で指定）
    final currentLocation = await ref.read(locationProvider.future);
    final supabase = ref.read(supabaseProvider);
    final response = await supabase.functions.invoke(
      // 注意: 関数名は大文字小文字まで一致が必要
      'Kakao-Restaurant-Search-',
      body: {
        'query': keyword,
        'size': 15,
        'x': currentLocation.longitude,
        'y': currentLocation.latitude,
        'radius': 2000,
      },
    );

    if (response.status == 200) {
      final data = response.data as Map<String, dynamic>;
      final documents = data['documents'] as List<dynamic>;
      final list = documents.map(
        (value) {
          return Restaurant.fromKakaoJson(value as Map<String, dynamic>);
        },
      ).toList();
      // 検索結果の件数を記録（0件ならクエリや半径の調整を検討）
      Logger().i('Kakao Edge OK: count=${list.length}, query="$keyword"');
      return list;
    } else {
      logger.w(
        'Kakao Edge Function returned non-200: '
        'status=${response.status}, data=${response.data}',
      );
      return [];
    }
  } on Exception catch (e) {
    logger.e('Kakao API Error: $e');
    return [];
  }
}
