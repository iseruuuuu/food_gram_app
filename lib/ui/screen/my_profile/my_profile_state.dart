import 'package:flutter/foundation.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_profile_state.freezed.dart';

@freezed
abstract class MyProfileState with _$MyProfileState {
  const factory MyProfileState.loading() = MyProfileStateLoading;

  const factory MyProfileState.data({
    required Users users,
    required int length,
    required int heartAmount,
  }) = _MyProfileStateData;

  const factory MyProfileState.error() = MyProfileStateError;
}
