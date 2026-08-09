import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/analytics_screen.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:food_gram_app/core/supabase/auth/services/account_service.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/env.dart';
import 'package:logger/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'revenue_cat_service.g.dart';

@riverpod
class RevenueCatService extends _$RevenueCatService {
  final logger = Logger();
  bool isSubscribed = false;
  late Offerings offerings;
  bool _isInitialized = false;
  String? get user => ref.read(currentUserProvider);
  String get entitlementId => Env.entitlementId;
  String get entitlementOffering => Env.entitlementOffering;

  @override
  Future<bool> build() {
    return initInAppPurchase();
  }

  Future<bool> initInAppPurchase() async {
    try {
      if (_isInitialized) {
        offerings = await Purchases.getOfferings();
        final customerInfo = await Purchases.getCustomerInfo();
        await _getPurchaserInfo(customerInfo);
        final active =
            customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
        await _syncSubscriptionToDatabase(active: active);
        return active;
      }
      late PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(Env.androidPurchaseKey);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(Env.iOSPurchaseKey);
      }
      await Purchases.configure(configuration);
      // Offerings を取得
      offerings = await Purchases.getOfferings();
      // Supabase の UID を使用してログイン
      final result = await Purchases.logIn(user!);
      await _getPurchaserInfo(result.customerInfo);
      _isInitialized = true;
      final active =
          result.customerInfo.entitlements.all[entitlementId]?.isActive ??
              false;
      // 起動時に RevenueCat を正として DB の is_subscribe を同期する
      await _syncSubscriptionToDatabase(active: active);
      return active;
    } on PlatformException catch (e) {
      logger.e('initInAppPurchase error caught! $e');
      // 取得失敗時は誤って false に落とさない
      return false;
    }
  }

  /// Paywall表示の前後でエンタイトルメントを比較し、
  /// 非アクティブ→アクティブに変化した時は同期処理を行う。
  /// 年間プランなどで反映が遅れる場合に備え、閉じた直後と少し遅れて2回同期を試す。
  /// 反映中はグローバル Loading でオーバーレイ表示する。
  Future<bool> presentPaywallGuarded() async {
    final beforeInfo = await Purchases.getCustomerInfo();
    final wasActive =
        beforeInfo.entitlements.all[entitlementId]?.isActive ?? false;
    final analytics = ref.read(firebaseAnalyticsServiceProvider);
    analytics.logScreen(AnalyticsScreen.paywall);
    analytics.logEventUnawaited(name: AnalyticsEvent.paywallOpen);
    if (!wasActive) {
      analytics.logEventUnawaited(name: AnalyticsEvent.purchaseStart);
    }

    final latest = await Purchases.getOfferings();
    offerings = latest;
    final offering =
        latest.getOffering(entitlementOffering) ?? latest.current;
    logger.d(
      'Paywall offerings current=${latest.current?.identifier} '
      'keys=${latest.all.keys.toList()} '
      'selected=${offering?.identifier} '
      'packages=${offering?.availablePackages.length}',
    );
    if (offering == null) {
      logger.e('No offering available for paywall');
      analytics.logEventUnawaited(name: AnalyticsEvent.purchaseFailed);
      return false;
    }

    try {
      await RevenueCatUI.presentPaywall(offering: offering);
    } on PlatformException catch (e) {
      logger.e('presentPaywall failed: $e');
      analytics.logEventUnawaited(name: AnalyticsEvent.purchaseFailed);
      return false;
    }

    final afterInfo = await Purchases.getCustomerInfo();
    final isActiveNow =
        afterInfo.entitlements.all[entitlementId]?.isActive ?? false;

    final loading = ref.read(loadingProvider.notifier);
    try {
      loading.isLoading(value: true);
      if (isActiveNow && !wasActive) {
        await syncAfterPaywall();
        analytics.logEventUnawaited(name: AnalyticsEvent.purchaseSuccess);
        return true;
      }
      // 即時には有効になっていなくても、年間プランなどで遅れて反映されることがあるため1回同期
      await syncAfterPaywall();
      if (!isActiveNow) {
        // まだ有効でなければ少し待って再取得してからもう1回同期
        await Future<void>.delayed(const Duration(seconds: 2));
        final retryActive = await syncAfterPaywall();
        if (retryActive) {
          analytics.logEventUnawaited(name: AnalyticsEvent.purchaseSuccess);
          return true;
        }
      }
      if (!isActiveNow) {
        analytics.logEventUnawaited(name: AnalyticsEvent.purchaseFailed);
      }
      return isActiveNow;
    } finally {
      loading.isLoading(value: false);
    }
  }

  /// RevenueCat の購入状態を再取得し、DB の is_subscribe を true/false 両方へ同期する。
  /// active なのに DB 更新が失敗した場合は false を返し、購読済み扱いにしない。
  Future<bool> syncAfterPaywall() async {
    try {
      final info = await Purchases.getCustomerInfo();
      final active = info.entitlements.all[entitlementId]?.isActive ?? false;
      final synced = await _syncSubscriptionToDatabase(active: active);
      if (active && !synced) {
        return false;
      }
      return active;
    } on PlatformException catch (e) {
      logger.e('syncAfterPaywall error $e');
      return false;
    }
  }

  /// 購入の復元
  /// iosの場合は、購入の復元（以前の購入履歴を復元する）を実装することが必要。
  Future<bool> restorePurchase() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isActive = await _updatePurchases(customerInfo, entitlementId);
      await _getPurchaserInfo(customerInfo);
      final synced = await _syncSubscriptionToDatabase(active: isActive);
      if (!isActive) {
        logger.w('購入情報なし');
        return false;
      }
      return synced;
    } on PlatformException catch (e) {
      logger.e('purchase repo  restorePurchase error $e');
      return false;
    }
  }

  /// RevenueCat の結果を DB / ローカル Provider に反映する。
  /// ネットワーク等で DB 更新に失敗しても、[active] 自体は呼び出し元へ返す。
  Future<bool> _syncSubscriptionToDatabase({required bool active}) async {
    final result = await ref
        .read(accountServiceProvider)
        .updateIsSubscribe(isSubscribe: active);
    final ok = result.when(
      success: (_) {
        final userId = ref.read(currentUserProvider);
        if (userId != null) {
          CacheManager().invalidateUserCache(userId);
        }
        return true;
      },
      failure: (e) {
        logger.e('updateIsSubscribe(isSubscribe: $active) failed: $e');
        return false;
      },
    );
    await ref.read(isSubscribeProvider.notifier).refresh();
    if (!ok) {
      logger.w('DB sync failed; local provider refreshed from current DB');
    }
    return ok;
  }

  Future<void> _getPurchaserInfo(CustomerInfo customerInfo) async {
    try {
      isSubscribed = await _updatePurchases(customerInfo, entitlementId);
    } on PlatformException catch (e) {
      logger.e('getPurchaserInfo error $e');
    }
  }

  Future<bool> _updatePurchases(
    CustomerInfo purchaserInfo,
    String entitlement,
  ) async {
    var isPurchased = false;
    final entitlements = purchaserInfo.entitlements.all;
    if (entitlements.isEmpty || !entitlements.containsKey(entitlement)) {
      isPurchased = false;
    } else if (entitlements[entitlement]!.isActive) {
      isPurchased = true;
    }
    return isPurchased;
  }
}
