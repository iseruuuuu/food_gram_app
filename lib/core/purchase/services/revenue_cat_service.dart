import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/analytics_screen.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:food_gram_app/core/config/constants/url.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/auth/services/account_service.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/subscribed_users_provider.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/env.dart';
import 'package:logger/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'revenue_cat_service.g.dart';

/// サブスク判定は RevenueCat の entitlement を正とし、DB の `is_subscribe` はその写し。
///
/// DB へ反映するタイミング:
/// - ログインユーザーが決まった時（[build]。ユーザーが変われば再実行）
/// - CustomerInfo の更新通知（プロモーションコード・オファーコードの引き換え、
///   ストア側での更新・期限切れなど、ペイウォール外で起きた変化）
/// - アプリの前面復帰（[refreshOnResume]）
/// - ペイウォールを閉じた後・購入の復元後
///
/// ログイン時と前面復帰時は、未加入なら syncPurchases で端末のストア購入も送る。
@Riverpod(keepAlive: true)
class RevenueCatService extends _$RevenueCatService {
  final _logger = Logger();
  static const _storeSyncInterval = Duration(minutes: 10);

  String? _loggedInUserId;
  String? _lastSyncedUserId;
  bool? _lastSyncedActive;
  var _awaitingCodeRedemption = false;
  DateTime? _lastStoreSyncAt;
  var _databaseWriteTail = Future<void>.value();
  Future<String?>? _loginInFlight;

  @override
  Future<bool> build() {
    final userId = ref.watch(currentUserProvider);
    void listener(CustomerInfo info) => _onCustomerInfoUpdated(userId, info);
    Purchases.addCustomerInfoUpdateListener(listener);
    ref.onDispose(() => Purchases.removeCustomerInfoUpdateListener(listener));
    return initInAppPurchase();
  }

  Future<bool> initInAppPurchase() async {
    final userId = ref.read(currentUserProvider);
    if (userId == null) {
      return false;
    }
    try {
      // Supabase の UID で RevenueCat にログイン（configure は main.dart で済んでいる）
      await Purchases.logIn(userId);
      _loggedInUserId = userId;
      return await _syncCustomerInfo(
        await _fetchCustomerInfoWithStoreSync(),
        userId: userId,
        force: true,
      );
    } on PlatformException catch (e) {
      _logger.e(
        'initInAppPurchase error code=${PurchasesErrorHelper.getErrorCode(e)} '
        'message=${e.message} details=${e.details}',
      );
      return false;
    }
  }

  /// 今のユーザーで RevenueCat にログインできていなければ、やり直す。
  /// 起動時の logIn が通信エラーなどで失敗したまま固まるのを防ぐ。
  /// ログインできなければ null。
  Future<String?> _ensureLoggedIn() {
    final userId = ref.read(currentUserProvider);
    if (userId == null) {
      return Future.value();
    }
    if (_loggedInUserId == userId) {
      return Future.value(userId);
    }
    return _loginInFlight ??= _retryLogIn(
      userId,
    ).whenComplete(() => _loginInFlight = null);
  }

  Future<String?> _retryLogIn(String userId) async {
    try {
      await Purchases.logIn(userId);
    } on PlatformException catch (e) {
      _logger.e(
        'logIn retry error code=${PurchasesErrorHelper.getErrorCode(e)} '
        'message=${e.message}',
      );
      return null;
    }
    if (!ref.mounted || ref.read(currentUserProvider) != userId) {
      return null;
    }
    _loggedInUserId = userId;
    return userId;
  }

  /// 前面復帰時の再確認。ストアでコードを引き換えて戻った時など。
  Future<void> refreshOnResume() async {
    // 初期化中は build 側の logIn と同期に任せる
    if (state.isLoading) {
      return;
    }
    final userId = await _ensureLoggedIn();
    if (userId == null) {
      return;
    }
    try {
      await _syncCustomerInfo(
        await _fetchCustomerInfoWithStoreSync(),
        userId: userId,
      );
    } on PlatformException catch (e) {
      _logger.e(
        'refreshOnResume error code=${PurchasesErrorHelper.getErrorCode(e)} '
        'message=${e.message} details=${e.details}',
      );
    }
  }

  /// 同一ユーザーへの logIn や getCustomerInfo は端末キャッシュを返すため、
  /// ダッシュボードでの付与など SDK に通知が来ない変化を拾えない。
  Future<CustomerInfo> _fetchFreshCustomerInfo() async {
    await Purchases.invalidateCustomerInfoCache();
    return Purchases.getCustomerInfo();
  }

  /// RevenueCat 上で未加入なら、端末のストア購入を送ってから取り直す。
  /// アプリ外でプロモーションコードを引き換えた購入は、
  /// syncPurchases しないと RevenueCat に届かないことがある。
  Future<CustomerInfo> _fetchCustomerInfoWithStoreSync() async {
    final info = await _fetchFreshCustomerInfo();
    if (_isEntitlementActive(info, Env.entitlementId) ||
        !_consumeStoreSyncSlot()) {
      return info;
    }
    try {
      await Purchases.syncPurchases();
    } on PlatformException catch (e) {
      _logger.w(
        'syncPurchases error code=${PurchasesErrorHelper.getErrorCode(e)} '
        'message=${e.message}',
      );
      return info;
    }
    return _fetchFreshCustomerInfo();
  }

  /// 引き換え画面から戻った直後は必ず、それ以外は [_storeSyncInterval] に1回まで。
  bool _consumeStoreSyncSlot() {
    final now = DateTime.now();
    final last = _lastStoreSyncAt;
    if (_awaitingCodeRedemption) {
      _awaitingCodeRedemption = false;
    } else if (last != null && now.difference(last) < _storeSyncInterval) {
      return false;
    }
    _lastStoreSyncAt = now;
    return true;
  }

  /// プロモーションコード（iOS: オファーコード）の入力画面を開く。
  /// 引き換え結果は CustomerInfo の更新通知・前面復帰時の再確認で DB に反映される。
  /// ストアの引き換え画面を開けたら true。
  Future<bool> presentCodeRedemption() async {
    try {
      final opened = await launchUrl(
        Uri.parse(
          Platform.isIOS ? URL.appleOfferCodeRedeem : URL.googlePlayRedeem,
        ),
        mode: LaunchMode.externalApplication,
      );
      _awaitingCodeRedemption = opened;
      return opened;
    } on PlatformException catch (e) {
      _logger.e('presentCodeRedemption error $e');
      return false;
    }
  }

  void _onCustomerInfoUpdated(String? userId, CustomerInfo info) {
    // ユーザー切り替え直後に前ユーザーの情報で DB を書き換えないようにする
    if (!ref.mounted || userId == null || userId != _loggedInUserId) {
      return;
    }
    unawaited(_syncCustomerInfo(info, userId: userId));
  }

  /// [userId] は [info] を取得した時点のログインユーザー。
  /// active なのに DB 反映できなければ購読済み扱いにしない。
  Future<bool> _syncCustomerInfo(
    CustomerInfo info, {
    required String userId,
    bool force = false,
  }) async {
    final active = _isEntitlementActive(info, Env.entitlementId);
    _logger.d(
      'RevenueCat active=$active '
      'activeEntitlements=${info.entitlements.active.keys.toList()}',
    );
    final synced = await _enqueueDatabaseSync(
      userId: userId,
      active: active,
      force: force,
    );
    return active && synced;
  }

  /// DB への書き込みは1件ずつ順に行う。重複判定は受け取った時ではなく実行時に行うので、
  /// 書き込み中に届いた後の状態変化も取りこぼさない。
  Future<bool> _enqueueDatabaseSync({
    required String userId,
    required bool active,
    required bool force,
  }) {
    final run = _databaseWriteTail.then(
      (_) => _runDatabaseSync(userId: userId, active: active, force: force),
    );
    _databaseWriteTail = run.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return run;
  }

  Future<bool> _runDatabaseSync({
    required String userId,
    required bool active,
    required bool force,
  }) async {
    // 待っている間にユーザーが切り替わっていたら、前ユーザーの状態を書き込まない
    if (!ref.mounted ||
        userId != _loggedInUserId ||
        userId != ref.read(currentUserProvider)) {
      return false;
    }
    if (!force && _lastSyncedUserId == userId && _lastSyncedActive == active) {
      return true;
    }
    return _syncSubscriptionToDatabase(userId: userId, active: active);
  }

  /// Paywall表示の前後でエンタイトルメントを比較し、
  /// 非アクティブ→アクティブに変化した時は同期処理を行う。
  /// 年間プランなどで反映が遅れる場合に備え、閉じた直後と少し遅れて2回同期を試す。
  /// 反映中はグローバル Loading でオーバーレイ表示する。
  Future<bool> presentPaywallGuarded({String? source}) async {
    // 未ログインのまま買うと匿名ユーザーに購入が付くので、呼び出し側でエラー表示させる
    if (await _ensureLoggedIn() == null) {
      throw StateError('RevenueCat logIn is not available');
    }
    final entitlementId = Env.entitlementId;
    final beforeInfo = await Purchases.getCustomerInfo();
    final wasActive =
        beforeInfo.entitlements.all[entitlementId]?.isActive ?? false;
    final analytics = ref.read(firebaseAnalyticsServiceProvider);
    final sourceParams = source != null
        ? <String, Object>{AnalyticsParam.source: source}
        : null;
    analytics.logScreen(AnalyticsScreen.paywall);
    analytics.logEventUnawaited(
      name: AnalyticsEvent.paywallOpen,
      parameters: sourceParams,
    );
    if (!wasActive) {
      analytics.logEventUnawaited(
        name: AnalyticsEvent.purchaseStart,
        parameters: sourceParams,
      );
    }

    final latest = await Purchases.getOfferings();
    final offering =
        latest.getOffering(Env.entitlementOffering) ?? latest.current;
    _logger.d(
      'Paywall offerings current=${latest.current?.identifier} '
      'keys=${latest.all.keys.toList()} '
      'selected=${offering?.identifier} '
      'packages=${offering?.availablePackages.length}',
    );
    if (offering == null) {
      _logger.e('No offering available for paywall');
      analytics.logEventUnawaited(
        name: AnalyticsEvent.purchaseFailed,
        parameters: sourceParams,
      );
      return false;
    }

    try {
      await RevenueCatUI.presentPaywall(offering: offering);
    } on PlatformException catch (e) {
      _logger.e('presentPaywall failed: $e');
      analytics.logEventUnawaited(
        name: AnalyticsEvent.purchaseFailed,
        parameters: sourceParams,
      );
      return false;
    }

    final afterInfo = await Purchases.getCustomerInfo();
    final isActiveNow =
        afterInfo.entitlements.all[entitlementId]?.isActive ?? false;

    final loading = ref.read(loadingProvider.notifier);
    try {
      loading.isLoading(value: true);
      if (isActiveNow && !wasActive) {
        final synced = await syncAfterPaywall();
        if (synced) {
          analytics.logEventUnawaited(
            name: AnalyticsEvent.purchaseSuccess,
            parameters: sourceParams,
          );
          return true;
        }
        analytics.logEventUnawaited(
          name: AnalyticsEvent.purchaseFailed,
          parameters: sourceParams,
        );
        return false;
      }
      // 即時には有効になっていなくても、年間プランなどで遅れて反映されることがあるため1回同期
      final synced = await syncAfterPaywall();
      if (!isActiveNow) {
        // まだ有効でなければ少し待って再取得してからもう1回同期
        await Future<void>.delayed(const Duration(seconds: 2));
        final retryActive = await syncAfterPaywall();
        if (retryActive) {
          analytics.logEventUnawaited(
            name: AnalyticsEvent.purchaseSuccess,
            parameters: sourceParams,
          );
          return true;
        }
        analytics.logEventUnawaited(
          name: AnalyticsEvent.purchaseFailed,
          parameters: sourceParams,
        );
        return false;
      }
      // すでに active でも DB 反映に失敗したら成功扱いにしない
      return synced;
    } finally {
      loading.isLoading(value: false);
    }
  }

  /// RevenueCat の購入状態を再取得し、DB の is_subscribe を true/false 両方へ同期する。
  /// active なのに DB 更新が失敗した場合は false を返し、購読済み扱いにしない。
  Future<bool> syncAfterPaywall() async {
    final userId = _loggedInUserId;
    if (userId == null) {
      return false;
    }
    try {
      final info = await Purchases.getCustomerInfo();
      return await _syncCustomerInfo(info, userId: userId, force: true);
    } on PlatformException catch (e) {
      _logger.e('syncAfterPaywall error $e');
      return false;
    }
  }

  /// 購入の復元
  /// iosの場合は、購入の復元（以前の購入履歴を復元する）を実装することが必要。
  Future<bool> restorePurchase() async {
    try {
      // logIn 前に復元すると匿名ユーザー側に購入が付いてしまう
      await future;
      final userId = await _ensureLoggedIn();
      if (userId == null) {
        return false;
      }
      final customerInfo = await Purchases.restorePurchases();
      return await _syncCustomerInfo(
        customerInfo,
        userId: userId,
        force: true,
      );
    } on PlatformException catch (e) {
      // receiptAlreadyInUseError は Restore Behavior が
      //「Keep with original App User ID」の時に出る
      _logger.e(
        'restore error code=${PurchasesErrorHelper.getErrorCode(e)} '
        'message=${e.message} details=${e.details}',
      );
      return false;
    }
  }

  /// RevenueCat の結果を DB / ローカル Provider に反映する。
  /// 成功時 true、DB 更新失敗時 false。
  Future<bool> _syncSubscriptionToDatabase({
    required String userId,
    required bool active,
  }) async {
    final result = await ref
        .read(accountServiceProvider)
        .updateIsSubscribe(isSubscribe: active, expectedUserId: userId);
    if (!ref.mounted) {
      return result.when(success: (_) => true, failure: (_) => false);
    }
    final ok = result.when(
      success: (_) {
        _lastSyncedUserId = userId;
        _lastSyncedActive = active;
        CacheManager().invalidateUserCache(userId);
        ref.invalidate(subscribedUsersProvider);
        return true;
      },
      failure: (e) {
        _logger.e('updateIsSubscribe(isSubscribe: $active) failed: $e');
        return false;
      },
    );
    await ref.read(isSubscribeProvider.notifier).refresh();
    if (!ok) {
      _logger.w('DB sync failed; local provider refreshed from current DB');
    }
    return ok;
  }

  bool _isEntitlementActive(CustomerInfo purchaserInfo, String entitlement) {
    final entitlements = purchaserInfo.entitlements.all;
    if (entitlements.isEmpty || !entitlements.containsKey(entitlement)) {
      return false;
    }
    return entitlements[entitlement]!.isActive;
  }
}
