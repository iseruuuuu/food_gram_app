import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_profile_state.freezed.dart';

@freezed
abstract class MyProfileState with _$MyProfileState {
  const factory MyProfileState.loading() = MyProfileStateLoading;

  const factory MyProfileState.data({
    //TODO これをあとでUsersのモデルに変更する
    required String name,
    required String userName,
    required String selfIntroduce,
    required String image,
    required int exchangedPoint,
    required int length,
  }) = _MyProfileStateData;

  const factory MyProfileState.error() = MyProfileStateError;
}
