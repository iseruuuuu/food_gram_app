import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_ui_state.freezed.dart';

@freezed
class ProfileUiState with _$ProfileUiState {
  const factory ProfileUiState({
    @Default(0) int length,
    @Default(0) int heartAmount,
  }) = _PostUiState;
}
