import 'dart:io';

import 'package:flutter/services.dart';
import 'package:food_gram_app/core/supabase/auth/services/account_service.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
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
  static const String _entitlementId = 'foodgram_premium_membership';

  String? get user => ref.read(currentUserProvider);
  String get entitlementId => _entitlementId;

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
        final isSubscription = customerInfo.entitlements.active;
        return isSubscription.isNotEmpty;
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
      final isSubscription = result.customerInfo.entitlements.active;
      if (isSubscription.isEmpty) {
        return false;
      } else {
        return true;
      }
    } on PlatformException catch (e) {
      logger.e('initInAppPurchase error caught! $e');
      return false;
    }
  }

  /// Paywall表示の前後でエンタイトルメントを比較し、
  /// 非アクティブ→アクティブに変化した時のみ同期処理を行う
  Future<bool> presentPaywallWithActivationGuard() async {
    final beforeInfo = await Purchases.getCustomerInfo();
    final wasActive =
        beforeInfo.entitlements.all[_entitlementId]?.isActive ?? false;
    await RevenueCatUI.presentPaywall();
    final afterInfo = await Purchases.getCustomerInfo();
    final isActiveNow =
        afterInfo.entitlements.all[_entitlementId]?.isActive ?? false;
    if (isActiveNow && !wasActive) {
      await syncAfterPaywall();
      return true;
    }
    return false;
  }

  /// RevenueCat の購入状態を再取得
  /// 購入状態が有効なら、DBを更新し、UI側の購読フラグを再評価する
  Future<bool> syncAfterPaywall() async {
    try {
      final info = await Purchases.getCustomerInfo();
      final active = info.entitlements.all[_entitlementId]?.isActive ?? false;
      if (active) {
        await ref.read(accountServiceProvider).updateIsSubscribe();
      }
      await ref.read(isSubscribeProvider.notifier).refresh();
      return active;
    } on PlatformException catch (e) {
      logger.e('syncAfterPaywall error $e');
      return false;
    }
  }

  /// 購入の復元
  /// iosの場合は、購入の復元（以前の購入履歴を復元する）を実装することが必要
  Future<bool> restorePurchase() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isActive = await _updatePurchases(customerInfo, _entitlementId);
      if (!isActive) {
        logger.w('購入情報なし');
        return false;
      } else {
        await _getPurchaserInfo(customerInfo);
        await ref.read(accountServiceProvider).updateIsSubscribe();
        await ref.read(isSubscribeProvider.notifier).refresh();
        return true;
      }
    } on PlatformException catch (e) {
      logger.e('purchase repo  restorePurchase error $e');
      return false;
    }
  }

  Future<void> _getPurchaserInfo(CustomerInfo customerInfo) async {
    try {
      isSubscribed = await _updatePurchases(customerInfo, _entitlementId);
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
