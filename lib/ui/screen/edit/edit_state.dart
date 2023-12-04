import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_state.freezed.dart';

@freezed
class EditState with _$EditState {
  const factory EditState({
    @Default('') String status,
    @Default(1) number,
  }) = _EditState;
}
