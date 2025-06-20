import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_state.freezed.dart';

@freezed
class UserProfileState with _$UserProfileState {
  const factory UserProfileState({
    @Default(0) int length,
    @Default(0) int heartAmount,
  }) = _UserProfileState;
}
