import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant_state.freezed.dart';

part 'restaurant_state.g.dart';

@freezed
abstract class RestaurantState with _$RestaurantState {
  const factory RestaurantState({
    @Default([]) List<String> restaurant,
    @Default([]) List<double> log,
    @Default([]) List<double> lat,
    @Default('') String searchText,
    @Default(true) bool isApproval,
  }) = _RestaurantState;

  factory RestaurantState.fromJson(Map<String, dynamic> json) =>
      _$RestaurantStateFromJson(json);
}
