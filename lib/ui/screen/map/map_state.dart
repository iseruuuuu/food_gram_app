import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'map_state.freezed.dart';

/// エリア内の人気タグ（絵文字 + 投稿数）。最大3件まで表示する。
typedef VisibleAreaTagCount = ({String emoji, int count});

@freezed
class MapState with _$MapState {
  const factory MapState({
    MapLibreMapController? mapController,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    int? visibleMealsCount,
    @Default([]) List<VisibleAreaTagCount> visibleAreaTopTags,
    LatLng? cameraCenterLatLng,
  }) = _MapState;
}
