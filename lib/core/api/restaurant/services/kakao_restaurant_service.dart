import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kakao_restaurant_service.g.dart';

typedef PaginationList<T> = List<T>;

/// 検索中の await で Ref が dispose されないよう keepAlive。
@Riverpod(keepAlive: true)
Future<PaginationList<Restaurant>> kakaoRestaurantServices(
  Ref ref,
  String keyword,
) async {
  if (keyword.trim().isEmpty) {
    return <Restaurant>[];
  }
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
  final supabase = ref.read(supabaseProvider);
  try {
    // 現在地を取得（Kakao Local APIは y=緯度(lat), x=経度(lon) で指定）
    final currentLocation = await ref.read(locationProvider.future);
    if (!ref.mounted) {
      return <Restaurant>[];
    }
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
    if (!ref.mounted) {
      return <Restaurant>[];
    }

    if (response.status == 200) {
      final raw = response.data;
      final data = raw is Map
          ? Map<String, dynamic>.from(raw)
          : <String, dynamic>{};
      final documents = data['documents'];
      if (documents is! List) {
        logger.w(
          'Kakao Edge Function missing documents: '
          'status=${response.status}, data=${response.data}',
        );
        return <Restaurant>[];
      }
      final list = <Restaurant>[];
      for (final value in documents) {
        if (value is! Map) {
          continue;
        }
        try {
          list.add(
            Restaurant.fromKakaoJson(Map<String, dynamic>.from(value)),
          );
        } on Object catch (err, st) {
          logger.w(
            'Skip invalid Kakao restaurant row',
            error: err,
            stackTrace: st,
          );
        }
      }
      // 検索結果の件数を記録（0件ならクエリや半径の調整を検討）
      logger.i('Kakao Edge OK: count=${list.length}, query="$keyword"');
      return list;
    } else {
      logger.w(
        'Kakao Edge Function returned non-200: '
        'status=${response.status}, data=${response.data}',
      );
      return <Restaurant>[];
    }
  } on Object catch (e, st) {
    logger.e('Kakao API Error: $e', error: e, stackTrace: st);
    rethrow;
  }
}
