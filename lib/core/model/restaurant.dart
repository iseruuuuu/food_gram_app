import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant.freezed.dart';

/// DB・検索で使う「店舗不明」の番兵。表示時は翻訳せずローカライズ文言を使う。
const unknownRestaurantName = '不明';

bool isUnknownRestaurantName(String name) =>
    name.trim() == unknownRestaurantName;

@freezed
class Restaurant with _$Restaurant {
  const factory Restaurant({
    required String name,
    required String address,
    required double lat,
    required double lng,
  }) = _Restaurant;

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>;
    final location = geometry['location'] as Map<String, dynamic>;
    return Restaurant(
      name: json['name'] as String,
      address: json['formatted_address'] as String,
      lat: location['lat'] as double,
      lng: location['lng'] as double,
    );
  }

  factory Restaurant.fromKakaoJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['place_name'] as String,
      address: json['address_name'] as String,
      lat: double.parse(json['y'] as String),
      lng: double.parse(json['x'] as String),
    );
  }
}
