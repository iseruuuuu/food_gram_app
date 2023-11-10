import 'package:flutter/cupertino.dart';
import 'package:food_gram_app/screen/tab/tab_state.dart';
import 'package:food_gram_app/screen/time_line/time_line_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_view_model.g.dart';

@riverpod
class TabViewModel extends _$TabViewModel {
  @override
  TabState build({
    TabState initState = const TabState(),
  }) {
    return initState;
  }

  List<Widget> pageList = [
    const TimeLineScreen(),
    Container(),
    Container(),
  ];

  void onTap(int index) {
    state = TabState(selectedIndex: index);
  }
}
