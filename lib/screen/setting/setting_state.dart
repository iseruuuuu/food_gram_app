import 'package:freezed_annotation/freezed_annotation.dart';

part 'setting_state.freezed.dart';

part 'setting_state.g.dart';

@freezed
abstract class SettingState with _$SettingState {
  const factory SettingState({
    @Default('') String status,
  }) = _SettingState;

  factory SettingState.fromJson(Map<String, dynamic> json) =>
      _$SettingStateFromJson(json);
}
