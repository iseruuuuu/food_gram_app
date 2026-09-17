import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_gram_app/core/purchase/services/revenue_cat_service.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppPremiumMembershipCard extends ConsumerWidget {
  const AppPremiumMembershipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Card(
            elevation: 0,
            color: AppTheme.orangeBackgroundOf(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppTheme.primaryOrange),
            ),
            child: SizedBox(
              height: 45,
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                tileColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 0,
                dense: true,
                title: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.crown,
                        color: AppTheme.primaryOrange,
                        size: 22,
                      ),
                      const Gap(18),
                      Text(
                        t.setting.premiumMembership,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.isDarkOf(context)
                              ? AppTheme.textPrimaryDark
                              : AppTheme.orangeDark,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  try {
                    await ref.read(revenueCatServiceProvider.future);
                    await ref
                        .read(revenueCatServiceProvider.notifier)
                        .presentPaywallGuarded();
                  } on Exception catch (e) {
                    debugPrint('presentPaywallGuarded failed: $e');
                  }
                },
              ),
            ),
          ),
        ),
        const Gap(12),
      ],
    );
  }
}
