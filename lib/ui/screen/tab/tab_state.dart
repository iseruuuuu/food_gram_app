import 'package:freezed_annotation/freezed_annotation.dart';

part 'tab_state.freezed.dart';

@freezed
class TabState with _$TabState {
  const factory TabState({
    @Default(0) int selectedIndex,
  }) = _TabState;
}
