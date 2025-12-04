import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/theme/style/paywall_style.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/paywall_widget.dart';
import 'package:food_gram_app/ui/screen/setting/setting_view_model.dart';
import 'package:go_router/go_router.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final loading = ref.watch(loadingProvider);
    final controller = ConfettiController(duration: const Duration(seconds: 2));

    return Scaffold(
      body: Stack(
        children: [
          PaywallBackground(child: Container()),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    onPressed: context.pop,
                    iconSize: 28,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  centerTitle: true,
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('✨️ ', style: PaywallStyle.title()),
                      Text(l10n.paywallTitle, style: PaywallStyle.title()),
                      Text(' ✨️', style: PaywallStyle.title()),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          PaywallContent(
                            onPurchase: () =>
                                _handlePurchase(context, ref, controller),
                            showComingSoon: true,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppProcessLoading(
            loading: loading,
            status: 'Loading...',
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          style: PaywallStyle.button(),
          onPressed: () => _handlePurchase(context, ref, controller),
          child: Text(
            l10n.paywallPrice,
            style: PaywallStyle.price(),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePurchase(
    BuildContext context,
    WidgetRef ref,
    ConfettiController controller,
  ) async {
    try {
      final result =
          await ref.read(settingViewModelProvider().notifier).purchase();
      if (!context.mounted) {
        return;
      }
      if (result) {
        controller.play();
        await showPaywallSuccessDialog(
          context: context,
          controller: controller,
          timeoutDuration: const Duration(seconds: 5),
        );
        context.pop(true);
      }
    } on Exception catch (e) {
      if (context.mounted) {
        SnackBarHelper().openErrorSnackBar(
          context,
          L10n.of(context).purchaseError,
          e.toString(),
        );
      }
    }
  }
}
