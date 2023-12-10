import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant.freezed.dart';

part 'restaurant.g.dart';

@freezed
abstract class Restaurant with _$Restaurant {
  const factory Restaurant({
    required String restaurant,
    required double lat,
    required double lng,
  }) = _Restaurant;

  factory Restaurant.fromJson(Map<String, dynamic> json) =>
      _$RestaurantFromJson(json);
}
