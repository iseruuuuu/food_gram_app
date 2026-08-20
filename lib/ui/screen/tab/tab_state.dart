import 'package:freezed_annotation/freezed_annotation.dart';

part 'tab_state.freezed.dart';

/// ボトムナビのタブ index。左から マップ / フード / 記録 / マイページ。
abstract final class TabIndex {
  static const map = 0;
  static const home = 1;
  static const myMap = 2;
  static const myPage = 3;
}

@freezed
class TabState with _$TabState {
  const factory TabState({
    /// 起動時はマップ（左端）。未表示の他タブは遅延構築する。
    @Default(TabIndex.map) int selectedIndex,
  }) = _TabState;
}
