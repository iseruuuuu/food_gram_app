import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/purchase/providers/subscription_provider.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class AppPromoteDialog extends ConsumerWidget {
  const AppPromoteDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.promoteDialogTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Gap(20),
            _buildFeatureItem(
              icon: Icons.emoji_events,
              title: l10n.promoteDialogTrophyTitle,
              description: l10n.promoteDialogTrophyDesc,
            ),
            _buildFeatureItem(
              icon: Icons.label,
              title: l10n.promoteDialogTagTitle,
              description: l10n.promoteDialogTagDesc,
            ),
            _buildFeatureItem(
              icon: Icons.account_circle,
              title: l10n.promoteDialogIconTitle,
              description: l10n.promoteDialogIconDesc,
            ),
            _buildFeatureItem(
              icon: Icons.block,
              title: l10n.promoteDialogAdTitle,
              description: l10n.promoteDialogAdDesc,
            ),
            Gap(20),
            ElevatedButton(
              onPressed: () {
                /// ダイアログを閉じ、PayWall画面に遷移する
                context
                  ..pop()
                  ..pushNamed(RouterPath.paywallPage).then((_) {
                    ref.invalidate(subscriptionProvider);
                  });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
              ),
              child: Text(
                l10n.promoteDialogButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: context.pop,
              style: const ButtonStyle(
                splashFactory: NoSplash.splashFactory,
              ),
              child: Text(
                l10n.promoteDialogLater,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.amber, size: 40),
          Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
