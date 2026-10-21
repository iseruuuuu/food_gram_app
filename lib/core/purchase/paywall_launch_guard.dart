import 'package:flutter/material.dart';
import 'package:food_gram_app/core/purchase/services/revenue_cat_service.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 連打と、RevenueCat ログイン前の表示を防ぐ。失敗時は再試行できるエラーを出す。
class PaywallLaunchGuard {
  var _inFlight = false;

  Future<bool> present({
    required BuildContext context,
    required WidgetRef ref,
    String? source,
  }) async {
    if (_inFlight) {
      return false;
    }
    _inFlight = true;
    try {
      await ref.read(revenueCatServiceProvider.future);
      if (!context.mounted) {
        return false;
      }
      return await ref
          .read(revenueCatServiceProvider.notifier)
          .presentPaywallGuarded(source: source);
    } on Object catch (e, st) {
      debugPrint('presentPaywallGuarded failed: $e\n$st');
      if (context.mounted) {
        SnackBarHelper().openErrorSnackBar(
          context,
          Translations.of(context).setting.purchaseError,
          '',
        );
      }
      return false;
    } finally {
      _inFlight = false;
    }
  }
}
