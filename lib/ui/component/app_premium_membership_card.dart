import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_gram_app/core/purchase/paywall_launch_guard.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/dialog/app_paywall_success_dialog.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppPremiumMembershipCard extends HookConsumerWidget {
  const AppPremiumMembershipCard({
    this.source = 'membership_card',
    super.key,
  });

  final String source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final paywallGuard = useMemoized(PaywallLaunchGuard.new);
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
                      const Gap(12),
                      Flexible(
                        child: Text(
                          t.setting.premiumMembership,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.isDarkOf(context)
                                ? AppTheme.textPrimaryDark
                                : AppTheme.orangeDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  final purchased = await paywallGuard.present(
                    context: context,
                    ref: ref,
                    source: source,
                  );
                  if (purchased && context.mounted) {
                    await showPaywallSuccessDialog(context: context);
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
