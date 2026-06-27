import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/admob/services/admob_interstitial.dart';
import 'package:food_gram_app/core/admob/services/admob_open.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
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

  @override
  TabState build({
    TabState initState = const TabState(),
  }) {
    ref.read(admobInterstitialNotifierProvider).createAd();
    ref.read(admobOpenNotifierProvider).loadAd();
    return initState;
  }

  List<Widget> pageList = [
    const MapScreen(),
    const TimeLineScreen(),
    const RecordScreen(),
    const MyProfileScreen(),
    const SettingScreen(),
  ];

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

      if (index == 2) {
        final hasShownAd = await Preference().getBool(
          PreferenceKey.recordTabInterstitialShown,
        );
        if (!hasShownAd) {
          await Preference().setBool(PreferenceKey.recordTabInterstitialShown);
          appOpen.registerTabSwitchAndShouldShow();
          final adInterstitial = ref.read(admobInterstitialNotifierProvider);
          adInterstitial.createAd();
          await adInterstitial.showAd(onAdClosed: switchTab);
          return;
        }
      }

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
    final analytics = ref.read(firebaseAnalyticsServiceProvider);
    switch (index) {
      case 0:
        unawaited(analytics.logEvent(name: AnalyticsEvent.mapOpen));
      case 1:
        unawaited(analytics.logEvent(name: AnalyticsEvent.timelineOpen));
      case 2:
        unawaited(analytics.logEvent(name: AnalyticsEvent.myMapOpen));
      case 3:
        unawaited(analytics.logEvent(name: AnalyticsEvent.profileOpen));
    }
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
