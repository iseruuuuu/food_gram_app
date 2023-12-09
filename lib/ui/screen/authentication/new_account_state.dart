import 'package:freezed_annotation/freezed_annotation.dart';

part 'new_account_state.freezed.dart';

@freezed
class NewAccountState with _$NewAccountState {
  const factory NewAccountState({
    @Default('') loginStatus,
    @Default(1) number,
    @Default(false) isSuccess,
  }) = _NewAccountState;
}
