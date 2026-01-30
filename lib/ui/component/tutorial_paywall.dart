import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/theme/style/paywall_style.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/dialog/app_paywall_success_dialog.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class TutorialPaywall extends ConsumerWidget {
  const TutorialPaywall({
    required this.onNextPage,
    required this.confettiController,
    super.key,
  });

  final VoidCallback onNextPage;
  final ConfettiController confettiController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Offerings>(
      future: Purchases.getOfferings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final offerings = snapshot.data;
        final offering = offerings?.current ??
            (offerings?.all.isNotEmpty ?? false
                ? offerings!.all.values.first
                : null);
        if (offering == null) {
          return Center(
            child: Text(
              Translations.of(context).paywall.title,
              style: PaywallStyle.title(),
            ),
          );
        }
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          body: PaywallView(
            offering: offering,
            onPurchaseCompleted: (customerInfo, storeTransaction) async {
              // 購入完了時の処理
              ref.invalidate(isSubscribeProvider);
              confettiController.play();
              await showPaywallSuccessDialog(
                context: context,
                controller: confettiController,
              );
              if (context.mounted) {
                onNextPage();
              }
            },
            onRestoreCompleted: (customerInfo) async {
              ref.invalidate(isSubscribeProvider);
              if (context.mounted) {
                SnackBarHelper().openSimpleSnackBar(
                  context,
                  Translations.of(context).setting.restoreSuccessTitle,
                );
              }
            },
          ),
        );
      },
    );
  }
}
