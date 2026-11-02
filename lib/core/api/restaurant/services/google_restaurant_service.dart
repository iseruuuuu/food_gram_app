import 'dart:io';

import 'package:food_gram_app/core/api/restaurant/google_places_language.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'google_restaurant_service.g.dart';

typedef PaginationList<T> = List<T>;

/// 検索中の await で Ref が dispose されないよう keepAlive。
@Riverpod(keepAlive: true)
Future<PaginationList<Restaurant>> googleRestaurantServices(
  Ref ref,
  String keyword,
) async {
  final trimmed = keyword.trim();
  if (trimmed.isEmpty) {
    return <Restaurant>[];
  }
  final restaurants = <Restaurant>[];
  final googleRestaurants = await _search(ref, trimmed);
  restaurants.addAll(googleRestaurants);
  return restaurants;
}

Future<List<Restaurant>> _search(Ref ref, String keyword) async {
  final logger = Logger();
  // await 前に依存を確保（UnmountedRefException 対策）
  final supabase = ref.read(supabaseProvider);
  try {
    String? location;
    try {
      final currentLocation = await ref.read(locationProvider.future);
      if (!ref.mounted) {
        return <Restaurant>[];
      }
      location = '${currentLocation.latitude},${currentLocation.longitude}';
    } on Object catch (e) {
      logger.w('Google location fetch failed, fallback without location: $e');
    }
    final response = await supabase.functions.invoke(
      'Google-Place-Restaurant-Search-',
      body: {
        'query': keyword,
        'language': googlePlacesLanguageCode(),
        'location': ?location,
        // 端末別キー利用のため、Edge側で分岐できるようにplatformを送る
        'platform': Platform.isIOS ? 'ios' : 'android',
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
      final results = data['results'];
      if (results is! List) {
        logger.w(
          'Google Edge Function missing results: '
          'status=${response.status}, data=${response.data}, '
          'query="$keyword"',
        );
        return <Restaurant>[];
      }
      final restaurants = <Restaurant>[];
      for (final value in results) {
        if (value is! Map) {
          continue;
        }
        try {
          restaurants.add(
            Restaurant.fromJson(Map<String, dynamic>.from(value)),
          );
        } on Object catch (err, st) {
          logger.w(
            'Skip invalid Google restaurant row',
            error: err,
            stackTrace: st,
          );
        }
      }
      return restaurants;
    } else {
      logger.w(
        'Google Edge Function returned non-200: '
        'status=${response.status}, data=${response.data}, '
        'query="$keyword"',
      );
      return <Restaurant>[];
    }
  } on Object catch (e, st) {
    logger.e(
      'Google API Error via Edge Function: $e',
      error: e,
      stackTrace: st,
    );
    rethrow;
  }
}
