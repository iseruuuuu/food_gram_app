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

/// サブスクの購入・復元と、サブスクの状態の判定をする。
///
/// サブスクに加入しているかどうかは RevenueCat の entitlement から取得し、
/// DB の `is_subscribe` はその結果を反映する。
///
/// DB に同期するタイミング:
/// - ログインをした時（アカウントを切り替えた時も含む）
/// - CustomerInfo の更新通知を受けた時
/// - App Store でプロモーションコードを引き換えて、アプリに戻ってきた
/// - ペイウォールを閉じた後、購入を復元した後
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

  /// Supabase の UID で RevenueCat にログインし、会員状態を DB に同期する。
  /// `Purchases.configure` は main.dart で済ませている前提。
  Future<bool> initInAppPurchase() async {
    final userId = ref.read(currentUserProvider);
    if (userId == null) {
      return false;
    }
    try {
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

  /// 今のユーザーで RevenueCat にログインできていなければ、ログインし直す。
  /// 起動時の logIn が通信エラーで失敗したままになるのを防ぐ。
  /// ログインできたらその UID を、できなければ null を返す。
  /// 同時に呼ばれても logIn は1回にまとめる。
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
    // logIn を待っている間にユーザーが切り替わっていたら、ログイン済みにしない
    if (!ref.mounted || ref.read(currentUserProvider) != userId) {
      return null;
    }
    _loggedInUserId = userId;
    return userId;
  }

  /// アプリが前面に戻った時に、会員状態を取り直して DB に同期する。
  /// ストアでコードを引き換えて戻ってきた場合も、ここで拾う。
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

  /// 端末のキャッシュを捨ててから CustomerInfo を取得する。
  /// キャッシュのままだと、ダッシュボードでの付与など
  /// SDK に通知が来ない変化を拾えない。
  Future<CustomerInfo> _fetchFreshCustomerInfo() async {
    await Purchases.invalidateCustomerInfoCache();
    return Purchases.getCustomerInfo();
  }

  /// CustomerInfo を取得し、未加入なら端末のストア購入を送ってから取り直す。
  /// アプリの外でコードを引き換えた購入は、
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

  /// 今 syncPurchases してよいかを返す。
  /// 引き換え画面から戻った直後は必ず許可し、それ以外は
  /// [_storeSyncInterval] に1回までに抑える。
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

  /// ストアのプロモーションコード（iOS ではオファーコード）入力画面を開く。
  /// 引き換えの結果は、CustomerInfo の更新通知か前面復帰時の同期で DB に反映される。
  /// 画面を開けたら true を返す。
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

  /// SDK からの CustomerInfo 更新通知を DB に同期する。
  void _onCustomerInfoUpdated(String? userId, CustomerInfo info) {
    // ユーザー切り替え直後に、前のユーザーの情報で DB を書き換えないようにする
    if (!ref.mounted || userId == null || userId != _loggedInUserId) {
      return;
    }
    unawaited(_syncCustomerInfo(info, userId: userId));
  }

  /// [info] の会員状態を DB に同期する。
  /// [userId] には [info] を取得した時点のログインユーザーを渡す。
  /// 会員で、かつ DB に反映できた時だけ true を返す。
  /// [force] が false なら、前回と同じ値の書き込みは省く。
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

  /// DB への書き込みをキューに積み、1件ずつ順に実行する。
  /// 重複かどうかは積んだ時ではなく実行する時に判定するので、
  /// 書き込み中に届いた新しい状態も取りこぼさない。
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

  /// キューの順番が来た書き込みを実行する。書き込まずに済んだ時も true を返す。
  Future<bool> _runDatabaseSync({
    required String userId,
    required bool active,
    required bool force,
  }) async {
    // 順番を待っている間にユーザーが切り替わっていたら、前のユーザーの状態を書き込まない
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

  /// ペイウォールを表示し、閉じた後に会員状態を DB に同期する。
  /// 購入して会員になり、DB にも反映できたら true を返す。
  /// 年間プランなどは反映が遅れることがあるので、まだ有効でなければ
  /// 少し待ってもう一度同期する。同期中は全画面のローディングを出す。
  /// RevenueCat にログインできない時は [StateError] を投げる。
  Future<bool> presentPaywallGuarded({String? source}) async {
    // 未ログインのまま買うと購入が匿名ユーザーに付くので、表示させずにエラーにする
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
      final synced = await syncAfterPaywall();
      if (!isActiveNow) {
        // 年間プランなどで反映が遅れている場合に備え、少し待ってからもう一度同期する
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
      // もともと会員でも、DB に反映できなければ成功扱いにしない
      return synced;
    } finally {
      loading.isLoading(value: false);
    }
  }

  /// RevenueCat から会員状態を取り直し、DB に同期する。
  /// 会員で、かつ DB に反映できた時だけ true を返す。
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

  /// 端末のストアアカウントの購入を、今のユーザーに復元する。
  /// iOS では審査上、復元の導線が必須。
  /// 会員になり、DB にも反映できたら true を返す。
  Future<bool> restorePurchase() async {
    try {
      // logIn の前に復元すると、購入が匿名ユーザーに付いてしまう
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
      // receiptAlreadyInUseError は、Restore Behavior が
      // 「Keep with original App User ID」の時に出る
      _logger.e(
        'restore error code=${PurchasesErrorHelper.getErrorCode(e)} '
        'message=${e.message} details=${e.details}',
      );
      return false;
    }
  }

  /// [userId] の `is_subscribe` を [active] に更新し、関連するキャッシュと
  /// Provider も更新する。DB を更新できたら true を返す。
  Future<bool> _syncSubscriptionToDatabase({
    required String userId,
    required bool active,
  }) async {
    final result = await ref
        .read(accountServiceProvider)
        .updateIsSubscribe(isSubscribe: active, expectedUserId: userId);
    // ユーザー切り替えで Provider が作り直された後は ref に触れない
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
