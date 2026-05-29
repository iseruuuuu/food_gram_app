import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_analytics_service.g.dart';

@Riverpod(keepAlive: true)
FirebaseAnalytics firebaseAnalytics(Ref ref) {
  return FirebaseAnalytics.instance;
}

/// Firebase Analytics の計測を担当
class FirebaseAnalyticsService {
  FirebaseAnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;
  final Logger _logger = Logger();

  /// 画面遷移の自動計測用 Observer（GoRouter に渡す）
  FirebaseAnalyticsObserver get navigatorObserver {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  /// Analytics を有効化し、アプリ起動を記録
  Future<void> initialize() async {
    await _analytics.setAnalyticsCollectionEnabled(true);
    await _analytics.logAppOpen();
    _logger.i('Firebase Analytics を初期化しました');
  }

  /// ログインユーザー ID（ログアウト時は null）
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Riverpod 外（FCM 等）から使う共有インスタンス
  static final FirebaseAnalyticsService shared =
      FirebaseAnalyticsService(FirebaseAnalytics.instance);

  /// カスタムイベント
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (kDebugMode) {
      _logger.d('Analytics event: $name params=$parameters');
    }
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> logPostStart({String? source}) => logEvent(
        name: AnalyticsEvent.postStart,
        parameters: source != null ? {AnalyticsParam.source: source} : null,
      );

  Future<void> logPostSuccess({bool fromDraft = false}) async {
    await logEvent(name: AnalyticsEvent.postSuccess);
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

  /// 画面表示（手動計測が必要な場合）
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }
}

@Riverpod(keepAlive: true)
FirebaseAnalyticsService firebaseAnalyticsService(Ref ref) {
  return FirebaseAnalyticsService(ref.read(firebaseAnalyticsProvider));
}

/// アプリ起動時の初期化（main から呼ぶ）
Future<void> initializeFirebaseAnalytics() async {
  await FirebaseAnalyticsService(FirebaseAnalytics.instance).initialize();
}
