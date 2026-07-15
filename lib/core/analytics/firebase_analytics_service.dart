import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/analytics_screen.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_analytics_service.g.dart';

@Riverpod(keepAlive: true)
FirebaseAnalytics firebaseAnalytics(Ref ref) {
  return FirebaseAnalytics.instance;
}

/// FoodGram Analytics v1.0
///
/// 使い方:
/// ```dart
/// final analytics = ref.read(firebaseAnalyticsServiceProvider);
/// analytics.logScreen(AnalyticsScreen.map);
/// analytics.logEvent(name: AnalyticsEvent.postSuccess);
/// ```
class FirebaseAnalyticsService {
  FirebaseAnalyticsService._(this._analytics);

  /// アプリ全体で共有する唯一のインスタンス
  static final FirebaseAnalyticsService instance =
      FirebaseAnalyticsService._(FirebaseAnalytics.instance);

  /// Riverpod 外（FCM / ATT 等）から使うエイリアス
  static FirebaseAnalyticsService get shared => instance;

  final FirebaseAnalytics _analytics;
  final Logger _logger = Logger();
  bool _collectionEnabled = false;
  FirebaseAnalyticsObserver? _navigatorObserver;

  bool get isCollectionEnabled => _collectionEnabled;

  /// 画面遷移の自動計測用 Observer（GoRouter に渡す）
  FirebaseAnalyticsObserver get navigatorObserver {
    return _navigatorObserver ??= FirebaseAnalyticsObserver(
      analytics: _analytics,
      nameExtractor: AnalyticsScreen.nameExtractor,
    );
  }

  /// ATT（iOS）に合わせて収集可否を同期し、有効時のみ app_open を送る
  Future<void> initialize() async {
    await syncCollectionWithAppTracking();
    if (_collectionEnabled) {
      await _runSafe('logAppOpen', _analytics.logAppOpen);
    }
    _logger.i(
      'Firebase Analytics を初期化しました (collection=$_collectionEnabled)',
    );
  }

  /// iOS は ATT 許可時のみ収集。Android は収集 ON。
  Future<void> syncCollectionWithAppTracking() async {
    var enabled = true;
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      enabled = status == TrackingStatus.authorized;
    }
    await _setCollectionEnabled(enabled);
  }

  Future<void> _setCollectionEnabled(bool enabled) async {
    _collectionEnabled = enabled;
    await _runSafe(
      'setAnalyticsCollectionEnabled',
      () => _analytics.setAnalyticsCollectionEnabled(enabled),
    );
  }

  /// ログインユーザー ID（ログアウト時は null）
  Future<void> setUserId(String? userId) async {
    if (!_collectionEnabled) {
      return;
    }
    await _runSafe(
      'setUserId',
      () => _analytics.setUserId(id: userId),
    );
  }

  /// 画面表示（推奨 API）
  void logScreen(String screenName, {String? screenClass}) {
    unawaited(
      logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      ),
    );
  }

  /// 画面表示（await が必要な場合）
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_collectionEnabled) {
      return;
    }
    if (kDebugMode) {
      _logger.d('Analytics screen: $screenName');
    }
    await _runSafe(
      'logScreenView',
      () => _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      ),
    );
  }

  /// UI / 購入フローをブロックしない計測
  void logEventUnawaited({
    required String name,
    Map<String, Object>? parameters,
  }) {
    unawaited(logEvent(name: name, parameters: parameters));
  }

  /// カスタムイベント（失敗しても呼び出し元には伝播しない）
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!_collectionEnabled) {
      return;
    }
    if (kDebugMode) {
      _logger.d('Analytics event: $name params=$parameters');
    }
    await _runSafe(
      name,
      () => _analytics.logEvent(name: name, parameters: parameters),
    );
  }

  Future<void> logPostStart({String? source}) => logEvent(
        name: AnalyticsEvent.postStart,
        parameters: source != null ? {AnalyticsParam.source: source} : null,
      );

  Future<void> logPostSuccess({
    bool fromDraft = false,
    bool hasComment = false,
    bool hasRestaurant = false,
  }) async {
    await logEvent(name: AnalyticsEvent.postSuccess);
    if (hasComment) {
      await logEvent(name: AnalyticsEvent.postCompleteWithComment);
      await logOnceEvent(
        key: PreferenceKey.analyticsFirstPostWithComment,
        name: AnalyticsEvent.firstPostWithComment,
      );
    } else {
      await logEvent(name: AnalyticsEvent.postCompleteWithoutComment);
    }
    if (hasRestaurant) {
      await logOnceEvent(
        key: PreferenceKey.analyticsFirstPostWithRestaurant,
        name: AnalyticsEvent.firstPostWithRestaurant,
      );
    }
    if (fromDraft) {
      await logEvent(name: AnalyticsEvent.draftPost);
    }
  }

  Future<void> logPostFailed({String? reason}) => logEvent(
        name: AnalyticsEvent.postFailed,
        parameters:
            reason != null ? {AnalyticsParam.errorReason: reason} : null,
      );

  Future<void> logMapPinTap({required String source}) => logEvent(
        name: AnalyticsEvent.mapPinTap,
        parameters: {AnalyticsParam.source: source},
      );

  Future<void> logMapSearch(String query) => logEvent(
        name: AnalyticsEvent.mapSearch,
        parameters: {AnalyticsParam.query: query},
      );

  Future<void> logMapSearchResultTap(String query) => logEvent(
        name: AnalyticsEvent.mapSearchResultTap,
        parameters: {AnalyticsParam.query: query},
      );

  Future<void> logPostDetailOpen(int postId) => logEvent(
        name: AnalyticsEvent.postDetailOpen,
        parameters: {AnalyticsParam.postId: postId},
      );

  Future<void> logPostSave(int postId) => logEvent(
        name: AnalyticsEvent.postSave,
        parameters: {AnalyticsParam.postId: postId},
      );

  Future<void> logPostShare(int postId, {required String shareType}) =>
      logEvent(
        name: AnalyticsEvent.postShare,
        parameters: {
          AnalyticsParam.postId: postId,
          AnalyticsParam.shareType: shareType,
        },
      );

  Future<void> logMyMapRegionTap({
    required String eventName,
    required String regionName,
  }) =>
      logEvent(
        name: eventName,
        parameters: {AnalyticsParam.regionName: regionName},
      );

  Future<void> logAlbumAddPost(int postId) => logEvent(
        name: AnalyticsEvent.albumAddPost,
        parameters: {AnalyticsParam.postId: postId},
      );

  Future<void> logPushOpen({String? type}) => logEvent(
        name: AnalyticsEvent.pushOpen,
        parameters: type != null ? {AnalyticsParam.pushType: type} : null,
      );

  Future<void> logPushReceive({String? type}) => logEvent(
        name: AnalyticsEvent.pushReceive,
        parameters: type != null ? {AnalyticsParam.pushType: type} : null,
      );

  /// 初回のみ送信するイベント
  Future<void> logOnceEvent({
    required PreferenceKey key,
    required String name,
    Map<String, Object>? parameters,
  }) async {
    final pref = Preference();
    if (await pref.getBool(key)) {
      return;
    }
    await logEvent(name: name, parameters: parameters);
    await pref.setBool(key);
  }

  /// 投稿数マイルストーン（10 / 50 / 100 / 500）
  Future<void> logPostCountMilestones(int postCount) async {
    final pref = Preference();
    final logged =
        await pref.getInt(PreferenceKey.analyticsHighestPostMilestone);
    const milestones = <int, String>{
      10: AnalyticsEvent.user10Posts,
      50: AnalyticsEvent.user50Posts,
      100: AnalyticsEvent.user100Posts,
      500: AnalyticsEvent.user500Posts,
    };
    var highest = logged;
    for (final entry in milestones.entries) {
      if (postCount >= entry.key && logged < entry.key) {
        await logEvent(name: entry.value);
        if (entry.key > highest) {
          highest = entry.key;
        }
      }
    }
    if (highest > logged) {
      await pref.setInt(PreferenceKey.analyticsHighestPostMilestone, highest);
    }
  }

  /// 都道府県・国コンプリートの初回マイルストーン
  Future<void> logRegionCompleteMilestones({
    required int visitedPrefectures,
    required int visitedCountries,
  }) async {
    const prefectureCap = 47;
    const countryCap = 195;
    if (visitedPrefectures >= prefectureCap) {
      await logEvent(name: AnalyticsEvent.prefectureComplete);
      await logOnceEvent(
        key: PreferenceKey.analyticsFirstPrefectureComplete,
        name: AnalyticsEvent.userFirstPrefectureComplete,
      );
    }
    if (visitedCountries >= countryCap) {
      await logEvent(name: AnalyticsEvent.countryComplete);
      await logOnceEvent(
        key: PreferenceKey.analyticsFirstCountryComplete,
        name: AnalyticsEvent.userFirstCountryComplete,
      );
    }
  }

  void logPremiumFeatureTap(String featureEvent) {
    logEventUnawaited(
      name: AnalyticsEvent.premiumFeatureTap,
      parameters: {
        AnalyticsParam.premiumFeature: featureEvent,
      },
    );
    logEventUnawaited(
      name: featureEvent,
    );
  }

  Future<void> _runSafe(String label, Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (e, st) {
      _logger.w('Analytics $label failed: $e', stackTrace: st);
    }
  }
}

@Riverpod(keepAlive: true)
FirebaseAnalyticsService firebaseAnalyticsService(Ref ref) {
  return FirebaseAnalyticsService.instance;
}

/// アプリ起動時の初期化（main から呼ぶ）。必ず Singleton を初期化する。
Future<void> initializeFirebaseAnalytics() async {
  await FirebaseAnalyticsService.instance.initialize();
}
