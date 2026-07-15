import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/admob/services/admob_open.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/analytics_screen.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/ui/screen/map/map_screen.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/my_profile_screen.dart';
import 'package:food_gram_app/ui/screen/record/record_screen.dart';
import 'package:food_gram_app/ui/screen/setting/setting_screen.dart';
import 'package:food_gram_app/ui/screen/tab/tab_state.dart';
import 'package:food_gram_app/ui/screen/time_line/time_line_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_view_model.g.dart';

final scrollToTopForTabProvider =
    StateProvider<({int tabIndex, int trigger})?>((ref) => null);

@riverpod
class TabViewModel extends _$TabViewModel {
  bool _isHandlingTap = false;
  bool _didLogInitialTab = false;

  @override
  TabState build({
    TabState initState = const TabState(),
  }) {
    ref.read(admobOpenNotifierProvider).loadAd();
    // 初回表示タブの ScreenView（Observer では取れない）
    Future.microtask(_logInitialTabIfNeeded);
    return initState;
  }

  List<Widget> pageList = [
    const MapScreen(),
    const TimeLineScreen(),
    const RecordScreen(),
    const MyProfileScreen(),
    const SettingScreen(),
  ];

  void _logInitialTabIfNeeded() {
    if (_didLogInitialTab) {
      return;
    }
    _didLogInitialTab = true;
    _logTabAnalytics(state.selectedIndex);
  }

  Future<void> onTap(int index) async {
    if (_isHandlingTap) {
      return;
    }
    _isHandlingTap = true;
    try {
      if (index == state.selectedIndex) {
        if (index == 1 || index == 3) {
          final current = ref.read(scrollToTopForTabProvider);
          ref.read(scrollToTopForTabProvider.notifier).state = (
            tabIndex: index,
            trigger: (current?.trigger ?? -1) + 1,
          );
        }
        return;
      }

      void switchTab() => _switchToTab(index);

      final appOpen = ref.read(admobOpenNotifierProvider);
      appOpen.loadAd();

      if (appOpen.registerTabSwitchAndShouldShow()) {
        await appOpen.ensureAdReady(resetAttempts: true);
        await appOpen.showAdIfAvailable(onAdClosed: switchTab);
        return;
      }

      switchTab();
    } finally {
      _isHandlingTap = false;
    }
  }

  void _switchToTab(int index) {
    _logTabAnalytics(index);
    if (index == 1 || index == 3) {
      final current = ref.read(scrollToTopForTabProvider);
      ref.read(scrollToTopForTabProvider.notifier).state = (
        tabIndex: index,
        trigger: (current?.trigger ?? -1) + 1,
      );
    }
    state = TabState(selectedIndex: index);
  }

  void _logTabAnalytics(int index) {
    final analytics = ref.read(firebaseAnalyticsServiceProvider);
    analytics.logScreen(AnalyticsScreen.forTabIndex(index));
    switch (index) {
      case 0:
        analytics.logEventUnawaited(name: AnalyticsEvent.mapOpen);
      case 1:
        analytics.logEventUnawaited(name: AnalyticsEvent.timelineOpen);
      case 2:
        analytics.logEventUnawaited(name: AnalyticsEvent.myMapOpen);
      case 3:
        analytics.logEventUnawaited(name: AnalyticsEvent.profileOpen);
      case 4:
        analytics.logEventUnawaited(name: AnalyticsEvent.settingOpen);
    }
  }
}
