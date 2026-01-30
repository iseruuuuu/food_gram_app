import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/purchase/services/revenue_cat_service.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class AppPromoteDialog extends ConsumerWidget {
  const AppPromoteDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
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
              t.promoteDialogTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(20),
            _buildFeatureItem(
              icon: Icons.emoji_events,
              title: t.promoteDialogTrophyTitle,
              description: t.promoteDialogTrophyDesc,
            ),
            _buildFeatureItem(
              icon: Icons.label,
              title: t.promoteDialogTagTitle,
              description: t.promoteDialogTagDesc,
            ),
            _buildFeatureItem(
              icon: Icons.account_circle,
              title: t.promoteDialogIconTitle,
              description: t.promoteDialogIconDesc,
            ),
            _buildFeatureItem(
              icon: Icons.block,
              title: t.promoteDialogAdTitle,
              description: t.promoteDialogAdDesc,
            ),
            const Gap(20),
            ElevatedButton(
              onPressed: () async {
                context.pop();
                try {
                  await ref
                      .read(revenueCatServiceProvider.notifier)
                      .presentPaywallGuarded();
                } on Exception catch (_) {
                  return;
                }
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
                t.promoteDialogButton,
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
                t.promoteDialogLater,
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
          const Gap(12),
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
