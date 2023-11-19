import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_profile_state.freezed.dart';

part 'my_profile_state.g.dart';

@freezed
abstract class MyProfileState with _$MyProfileState {
  const factory MyProfileState({
    required String name,
    required String userName,
    required String selfIntroduce,
    required String image,
  }) = _MyProfileState;

  factory MyProfileState.fromJson(Map<String, dynamic> json) =>
      _$MyProfileStateFromJson(json);
}
