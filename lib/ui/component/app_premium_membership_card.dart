import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_gram_app/core/purchase/providers/subscription_provider.dart';
import 'package:food_gram_app/core/theme/style/setting_style.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class AppPremiumMembershipCard extends ConsumerWidget {
  const AppPremiumMembershipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final subscriptionState = ref.watch(subscriptionProvider);
    return subscriptionState.when(
      data: (isSubscribed) {
        if (isSubscribed) {
          return const SizedBox.shrink();
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  height: 45,
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tileColor: const Color(0xFFFFFDD0),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    minVerticalPadding: 0,
                    dense: true,
                    subtitleTextStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    title: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            FontAwesomeIcons.crown,
                            color: Colors.yellow,
                            size: 22,
                          ),
                          const Gap(18),
                          Text(
                            l10n.settingPremiumMembership,
                            style: SettingStyle.premium(),
                          ),
                          const Gap(18),
                          const Icon(
                            FontAwesomeIcons.crown,
                            color: Colors.yellow,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      try {
                        await RevenueCatUI.presentPaywall();
                        ref.invalidate(
                          subscriptionProvider,
                        );
                      } on Exception catch (_) {
                        return;
                      }
                    },
                  ),
                ),
              ),
            ),
            const Gap(12),
          ],
        );
      },
      error: (_, __) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}
