import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'map_state.freezed.dart';

@freezed
class MapState with _$MapState {
  const factory MapState({
    MapLibreMapController? mapController,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    int? visibleMealsCount,
  }) = _MapState;
}
