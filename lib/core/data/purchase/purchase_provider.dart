import 'dart:io';

import 'package:flutter/services.dart';
import 'package:food_gram_app/env.dart';
import 'package:food_gram_app/main.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_provider.g.dart';

@riverpod
class Purchase extends _$Purchase {
  bool isSubscribed = false;
  late Offerings offerings;
  final user = supabase.auth.currentUser?.id;

  @override
  Future<bool> build() {
    return initInAppPurchase();
  }

  Future<bool> initInAppPurchase() async {
    try {
      late PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        // TODO Android用のRevenuecat APIキーを入れる必要がありそう
        configuration = PurchasesConfiguration('');
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(Env.iOSPurchaseKey);
      }

      await Purchases.configure(configuration);

      /// Offerings を取得
      offerings = await Purchases.getOfferings();

      /// Supabase の UID を使用してログイン
      final result = await Purchases.logIn(user!);
      await getPurchaserInfo(result.customerInfo);

      /// アクティブなアイテムをログ出力
      final isSubscription = result.customerInfo.entitlements.active;
      if (isSubscription.isEmpty) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print('initInAppPurchase error caught! ${e}');
      return false;
    }
  }

  Future<void> getPurchaserInfo(CustomerInfo customerInfo) async {
    try {
      isSubscribed =
          await updatePurchases(customerInfo, 'monthly_subscription');
    } on PlatformException catch (e) {
      print('getPurchaserInfo error $e');
    }
  }

  Future<bool> updatePurchases(
      CustomerInfo purchaserInfo, String entitlement) async {
    var isPurchased = false;
    final entitlements = purchaserInfo.entitlements.all;

    if (entitlements.isEmpty || !entitlements.containsKey(entitlement)) {
      isPurchased = false;
    } else if (entitlements[entitlement]!.isActive) {
      isPurchased = true;
    }
    return isPurchased;
  }

  /// 購入処理
  /// makePurchase()を呼び出して実際に課金処理を行う
  Future<void> makePurchase(String offeringsName) async {
    await initInAppPurchase();
    try {
      Package? package;
      package = offerings.all[offeringsName]?.monthly;
      if (package != null) {
        await Purchases.logIn(user!);
        final customerInfo = await Purchases.purchasePackage(package);
        await getPurchaserInfo(customerInfo);
      }
    } on PlatformException catch (e) {
      print(' makePurchase error $e');
    }
  }

  /// 購入の復元
  /// iosの場合は、購入の復元（以前の購入履歴を復元する）を実装することが必要
  Future<void> restorePurchase(String entitlement) async {
    try {
      /// Entitlements
      /// 「アイテムの保有状況（アイテムが購入済みで、アクティブになっているかどうか）」を確認するための設定項目
      final customerInfo = await Purchases.restorePurchases();
      final isActive = await updatePurchases(customerInfo, entitlement);
      if (!isActive) {
        //TODO SnackBarとかを出す
        print('購入情報なし');
      } else {
        await getPurchaserInfo(customerInfo);
        print('$entitlement 購入情報あり　復元する');
        //TODO 必要であれば復元の処理が必要そう・・・？
        //TODO SnackBarとかを出す
      }
    } on PlatformException catch (e) {
      print('purchase repo  restorePurchase error ${e}');
    }
  }
}