import 'package:freezed_annotation/freezed_annotation.dart';

part 'splash_state.freezed.dart';

part 'splash_state.g.dart';

@freezed
abstract class SplashState with _$SplashState {
  const factory SplashState({
    @Default('') String status,
  }) = _SplashState;

  factory SplashState.fromJson(Map<String, dynamic> json) =>
      _$SplashStateFromJson(json);
}
