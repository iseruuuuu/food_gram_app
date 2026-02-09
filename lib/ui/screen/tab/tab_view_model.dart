import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/ui/screen/map/map_screen.dart';
import 'package:food_gram_app/ui/screen/map/my_map/my_map_screen.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/my_profile_screen.dart';
import 'package:food_gram_app/ui/screen/setting/setting_screen.dart';
import 'package:food_gram_app/ui/screen/tab/tab_state.dart';
import 'package:food_gram_app/ui/screen/time_line/time_line_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_view_model.g.dart';

final scrollToTopForTabProvider =
    StateProvider<({int tabIndex, int trigger})?>((ref) => null);

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
    const MyMapScreen(),
    const MyProfileScreen(),
    const SettingScreen(),
  ];

  void onTap(int index) {
    if (index == 1 || index == 3) {
      final current = ref.read(scrollToTopForTabProvider);
      ref.read(scrollToTopForTabProvider.notifier).state = (
        tabIndex: index,
        trigger: (current?.trigger ?? -1) + 1,
      );
    }
    state = TabState(selectedIndex: index);
  }
}
