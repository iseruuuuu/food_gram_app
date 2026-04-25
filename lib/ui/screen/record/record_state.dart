import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'record_state.freezed.dart';

@freezed
class RecordState with _$RecordState {
  const factory RecordState({
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
    @Default(0) int postingStreakWeeks,
  }) = _RecordState;
}

/// 投稿一覧から算出したマップ用統計
@freezed
class RecordMapStats with _$RecordMapStats {
  const factory RecordMapStats({
    required int visitedCitiesCount,
    required int postsCount,
    required double completionPercentage,
    required int visitedPrefecturesCount,
    required int visitedCountriesCount,
    required int visitedAreasCount,
    required int activityDays,
  }) = _RecordMapStats;
}
