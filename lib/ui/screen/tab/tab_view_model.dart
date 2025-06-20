import 'package:flutter/material.dart';
import 'package:food_gram_app/ui/screen/map/map_screen.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/my_profile_screen.dart';
import 'package:food_gram_app/ui/screen/search/search_screen.dart';
import 'package:food_gram_app/ui/screen/setting/setting_screen.dart';
import 'package:food_gram_app/ui/screen/tab/tab_state.dart';
import 'package:food_gram_app/ui/screen/time_line/time_line_screen.dart';
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
    const MapScreen(),
    const TimeLineScreen(),
    const SearchScreen(),
    const MyProfileScreen(),
    const SettingScreen(),
  ];

  void onTap(int index) {
    state = TabState(selectedIndex: index);
  }
}
