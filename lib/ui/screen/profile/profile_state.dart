import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(0) int length,
    @Default(0) int heartAmount,
  }) = _ProfileState;
}
