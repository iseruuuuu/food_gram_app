import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'google_restaurant_service.g.dart';

typedef PaginationList<T> = List<T>;

@riverpod
Future<PaginationList<Restaurant>> googleRestaurantServices(
  Ref ref,
  String keyword,
) async {
  final restaurants = <Restaurant>[];
  final googleRestaurants = await _search(ref, keyword);
  restaurants.addAll(googleRestaurants);
  return restaurants;
}

Future<List<Restaurant>> _search(Ref ref, String keyword) async {
  final logger = Logger();
  try {
    String? location;
    try {
      final currentLocationFuture = ref.read(locationProvider.future);
      final currentLocation = await currentLocationFuture;
      location = '${currentLocation.latitude},${currentLocation.longitude}';
    } on Exception catch (e) {
      logger.w('Google location fetch failed, fallback without location: $e');
    }
    final supabase = ref.read(supabaseProvider);
    // Text Searchに現在地を付与（Edge側がGoogleに転送）
    final response = await supabase.functions.invoke(
      'Google-Place-Restaurant-Search-',
      body: {
        'query': keyword,
        'language': 'ja',
        if (location != null) 'location': location,
        // 端末別キー利用のため、Edge側で分岐できるようにplatformを送る
        'platform': Platform.isIOS ? 'ios' : 'android',
      },
    );
    if (response.status == 200) {
      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map(
        (value) {
          return Restaurant.fromJson(value as Map<String, dynamic>);
        },
      ).toList();
    } else {
      logger.w(
        'Google Edge Function returned non-200: '
        'status=${response.status}, data=${response.data}, '
        'query="$keyword"',
      );
      return [];
    }
  } on Exception catch (e) {
    logger.e(
      'Google API Error via Edge Function: $e',
    );
    return [];
  }
}
