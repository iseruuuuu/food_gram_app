import 'package:food_gram_app/core/data/purchase/purchase_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_provider.g.dart';

@riverpod
Future<bool> subscription(
  SubscriptionRef ref,
) async {
  try {
    await ref.read(purchaseProvider.notifier).initInAppPurchase();
    // RevenueCatからCustomerInfoを取得
    final customerInfo = await Purchases.getCustomerInfo();

    // 指定されたエンタイトルメントがアクティブか確認
    final entitlements = customerInfo.entitlements.all;
    if (entitlements.containsKey('foodgram_premium_membership') &&
        entitlements['foodgram_premium_membership']!.isActive) {
      print('サブスクできてる！！');

      return true;
    }
    return false;
  } catch (e) {
    print('Error checking entitlement: $e');
    return false; // エラー発生時はfalseを返す
  }
}
