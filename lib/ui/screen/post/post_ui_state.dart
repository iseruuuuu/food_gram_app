import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_ui_state.freezed.dart';

@freezed
class PostUiState with _$PostUiState {
  const factory PostUiState({
    @Default('') String foodImage,
    @Default('場所を追加') String restaurant,
    @Default('') String status,
    @Default(false) isSuccess,
    @Default(0.0) lat,
    @Default(0.0) lng,
  }) = _PostUiState;
}
