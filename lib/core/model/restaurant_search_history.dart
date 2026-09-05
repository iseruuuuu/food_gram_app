import 'dart:convert';

import 'package:food_gram_app/core/model/restaurant.dart';

/// 投稿時のレストラン検索で選択した店舗の履歴。
class RestaurantSearchHistoryStore {
  const RestaurantSearchHistoryStore(this.items);

  factory RestaurantSearchHistoryStore.fromJsonString(String raw) {
    if (raw.isEmpty) {
      return const RestaurantSearchHistoryStore([]);
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const RestaurantSearchHistoryStore([]);
      }
      final items = <Restaurant>[];
      for (final e in decoded) {
        final restaurant = _restaurantFromJson(e);
        if (restaurant != null) {
          items.add(restaurant);
        }
      }
      return RestaurantSearchHistoryStore(items);
    } on Object {
      return const RestaurantSearchHistoryStore([]);
    }
  }

  static const int maxItems = 20;

  final List<Restaurant> items;

  String toJsonString() => jsonEncode(items.map(_restaurantToJson).toList());

  /// 直近の選択を先頭に追加する。同一店舗は重複させず、件数は [maxItems] まで。
  RestaurantSearchHistoryStore add(Restaurant restaurant) {
    if (!_isSavable(restaurant)) {
      return this;
    }
    final key = identityKey(restaurant);
    final next = [
      restaurant,
      ...items.where((e) => identityKey(e) != key),
    ];
    if (next.length > maxItems) {
      return RestaurantSearchHistoryStore(next.take(maxItems).toList());
    }
    return RestaurantSearchHistoryStore(next);
  }

  RestaurantSearchHistoryStore remove(Restaurant restaurant) {
    final key = identityKey(restaurant);
    return RestaurantSearchHistoryStore(
      items.where((e) => identityKey(e) != key).toList(),
    );
  }

  static String identityKey(Restaurant restaurant) {
    return '${restaurant.name.trim()}@'
        '${restaurant.lat.toStringAsFixed(6)},'
        '${restaurant.lng.toStringAsFixed(6)}';
  }

  static bool _isSavable(Restaurant restaurant) {
    if (restaurant.name.trim().isEmpty) {
      return false;
    }
    return !isUnknownRestaurant(restaurant);
  }

  /// 検索画面の「不明」チップで渡す店舗。
  static bool isUnknownRestaurant(Restaurant restaurant) {
    return restaurant.name == unknownRestaurantName &&
        restaurant.address.isEmpty &&
        restaurant.lat == 0 &&
        restaurant.lng == 0;
  }
}

Map<String, dynamic> _restaurantToJson(Restaurant restaurant) => {
      'name': restaurant.name,
      'address': restaurant.address,
      'lat': restaurant.lat,
      'lng': restaurant.lng,
    };

Restaurant? _restaurantFromJson(Object? json) {
  if (json is! Map) {
    return null;
  }
  final map = Map<String, dynamic>.from(json);
  final name = (map['name'] as String? ?? '').trim();
  if (name.isEmpty) {
    return null;
  }
  return Restaurant(
    name: name,
    address: map['address'] as String? ?? '',
    lat: (map['lat'] as num?)?.toDouble() ?? 0,
    lng: (map['lng'] as num?)?.toDouble() ?? 0,
  );
}
