import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/admob/services/admob_open.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/analytics_screen.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/utils/helpers/haptic_feedback_helper.dart';
import 'package:food_gram_app/ui/screen/map/map_screen.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/my_profile_screen.dart';
import 'package:food_gram_app/ui/screen/record/record_screen.dart';
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
    // タブ表示中にアプリオープンを先読みする。表示は前面復帰側で行う。
    ref.read(admobOpenNotifierProvider);
    // 初回表示タブの ScreenView（Observer では取れない）
    Future.microtask(_logInitialTabIfNeeded);
    return initState;
  }

  List<Widget> pageList = [
    const MapScreen(),
    const TimeLineScreen(),
    const RecordScreen(),
    const MyProfileScreen(),
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
    HapticFeedbackHelper.selection();
    _isHandlingTap = true;
    try {
      if (index == state.selectedIndex) {
        if (index != TabIndex.map) {
          final current = ref.read(scrollToTopForTabProvider);
          ref.read(scrollToTopForTabProvider.notifier).state = (
            tabIndex: index,
            trigger: (current?.trigger ?? -1) + 1,
          );
        }
        return;
      }

      _switchToTab(index);
    } finally {
      _isHandlingTap = false;
    }
  }

  void _switchToTab(int index) {
    _logTabAnalytics(index);
    state = TabState(selectedIndex: index);
  }

  void _logTabAnalytics(int index) {
    final analytics = ref.read(firebaseAnalyticsServiceProvider);
    analytics.logScreen(AnalyticsScreen.forTabIndex(index));
    switch (index) {
      case TabIndex.home:
        analytics.logEventUnawaited(name: AnalyticsEvent.timelineOpen);
      case TabIndex.map:
        analytics.logEventUnawaited(name: AnalyticsEvent.mapOpen);
      case TabIndex.myMap:
        analytics.logEventUnawaited(name: AnalyticsEvent.myMapOpen);
      case TabIndex.myPage:
        analytics.logEventUnawaited(name: AnalyticsEvent.profileOpen);
    }
  }
}
