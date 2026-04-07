import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'my_map_state.freezed.dart';

@freezed
class MyMapState with _$MyMapState {
  const factory MyMapState({
    MapLibreMapController? mapController,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    @Default(0) int visitedCitiesCount,
    @Default(0) int postsCount,
    @Default(0.0) double completionPercentage,
    @Default(MapViewType.detail) MapViewType viewType,
    @Default(0) int visitedPrefecturesCount,
    @Default(0) int visitedCountriesCount,
    @Default(0) int visitedAreasCount,
    @Default(0) int activityDays,
    /// `users.streak_weeks`（`last_post_date` が14日超古い場合は途切れとして 0）
    @Default(0) int postingStreakWeeks,
  }) = _MyMapState;
}
