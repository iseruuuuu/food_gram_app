import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/purchase/services/revenue_cat_service.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/dialog/app_paywall_success_dialog.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppRemoveAdsCta extends ConsumerWidget {
  const AppRemoveAdsCta({
    required this.source,
    super.key,
  });

  final String source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final textColor = AppTheme.isDarkOf(context)
        ? AppTheme.textPrimaryDark
        : AppTheme.orangeDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: AppTheme.orangeBackgroundOf(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.primaryOrange),
        ),
        child: InkWell(
          onTap: () async {
            ref.read(firebaseAnalyticsServiceProvider).logPremiumFeatureTap(
                  AnalyticsEvent.premiumRemoveAdsTap,
                );
            final purchased = await ref
                .read(revenueCatServiceProvider.notifier)
                .presentPaywallGuarded(source: source);
            if (purchased && context.mounted) {
              await showPaywallSuccessDialog(context: context);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 44,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.crown,
                    color: AppTheme.primaryOrange,
                    size: 18,
                  ),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      t.paywall.removeAdsCta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: textColor,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
