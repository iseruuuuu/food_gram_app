import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant.freezed.dart';

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
}
