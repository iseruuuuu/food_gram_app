import 'dart:io';

import 'package:flutter/services.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/analytics_screen.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:food_gram_app/core/model/result.dart';
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

@Riverpod(keepAlive: true)
class RevenueCatService extends _$RevenueCatService {
  final _logger = Logger();
  var _isInitialized = false;

  @override
  Future<bool> build() {
    return initInAppPurchase();
  }

  Future<bool> initInAppPurchase() async {
    try {
      final entitlementId = Env.entitlementId;
      if (_isInitialized) {
        await Purchases.getOfferings();
        final customerInfo = await Purchases.getCustomerInfo();
        final active =
            customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
        final synced = await _syncSubscriptionToDatabase(active: active);
        // active なのに DB 反映できなければ購読済み扱いにしない
        return active && synced;
      }
      late PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(Env.androidPurchaseKey);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(Env.iOSPurchaseKey);
      }
      await Purchases.configure(configuration);
      // Offerings を取得
      await Purchases.getOfferings();
      // Supabase の UID を使用してログイン
      final userId = ref.read(currentUserProvider);
      final result = await Purchases.logIn(userId!);
      _isInitialized = true;
      final active =
          result.customerInfo.entitlements.all[entitlementId]?.isActive ??
              false;
      // 起動時に RevenueCat を正として DB の is_subscribe を同期する
      final synced = await _syncSubscriptionToDatabase(active: active);
      // active なのに DB 反映できなければ購読済み扱いにしない
      return active && synced;
    } on PlatformException catch (e) {
      _logger.e('initInAppPurchase error caught! $e');
      // 取得失敗時は誤って false に落とさない
      return false;
    }
  }

  /// Paywall表示の前後でエンタイトルメントを比較し、
  /// 非アクティブ→アクティブに変化した時は同期処理を行う。
  /// 年間プランなどで反映が遅れる場合に備え、閉じた直後と少し遅れて2回同期を試す。
  /// 反映中はグローバル Loading でオーバーレイ表示する。
  Future<bool> presentPaywallGuarded({String? source}) async {
    final entitlementId = Env.entitlementId;
    final beforeInfo = await Purchases.getCustomerInfo();
    final wasActive =
        beforeInfo.entitlements.all[entitlementId]?.isActive ?? false;
    final analytics = ref.read(firebaseAnalyticsServiceProvider);
    final sourceParams =
        source != null ? <String, Object>{AnalyticsParam.source: source} : null;
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
    try {
      final info = await Purchases.getCustomerInfo();
      final active =
          info.entitlements.all[Env.entitlementId]?.isActive ?? false;
      final synced = await _syncSubscriptionToDatabase(active: active);
      if (active && !synced) {
        return false;
      }
      return active;
    } on PlatformException catch (e) {
      _logger.e('syncAfterPaywall error $e');
      return false;
    }
  }

  /// 購入の復元
  /// iosの場合は、購入の復元（以前の購入履歴を復元する）を実装することが必要。
  Future<bool> restorePurchase() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isActive = _isEntitlementActive(customerInfo, Env.entitlementId);
      final synced = await _syncSubscriptionToDatabase(active: isActive);
      if (!isActive) {
        _logger.w('購入情報なし');
        return false;
      }
      return synced;
    } on PlatformException catch (e) {
      _logger.e('purchase repo  restorePurchase error $e');
      return false;
    }
  }

  /// RevenueCat の結果を DB / ローカル Provider に反映する。
  /// 成功時 true、DB 更新失敗時 false。
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
