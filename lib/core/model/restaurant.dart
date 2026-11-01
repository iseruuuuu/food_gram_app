import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant.freezed.dart';

/// DB・検索で使う「店舗不明」の番兵。表示時は翻訳せずローカライズ文言を使う。
const unknownRestaurantName = '不明';

bool isUnknownRestaurantName(String name) =>
    name.trim() == unknownRestaurantName;

@freezed
abstract class Restaurant with _$Restaurant {
  const factory Restaurant({
    required String name,
    required String address,
    required double lat,
    required double lng,
  }) = _Restaurant;

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final geometry = Map<String, dynamic>.from(json['geometry'] as Map);
    final location = Map<String, dynamic>.from(geometry['location'] as Map);
    return Restaurant(
      name: json['name'] as String,
      address: (json['formatted_address'] as String?) ?? '',
      lat: (location['lat'] as num).toDouble(),
      lng: (location['lng'] as num).toDouble(),
    );
  }

  factory Restaurant.fromKakaoJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['place_name'] as String,
      address: (json['address_name'] as String?) ?? '',
      lat: double.parse(json['y'] as String),
      lng: double.parse(json['x'] as String),
    );
  }
}
