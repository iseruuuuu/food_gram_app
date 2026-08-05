import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

enum FirstPostSuccessAction {
  viewMap,
  viewAlbum,
  later,
}

/// 初回投稿完了 → 次アクション誘導の一連ダイアログ。
Future<FirstPostSuccessAction?> showFirstPostSuccessGuide({
  required BuildContext context,
  Posts? post,
}) async {
  final t = Translations.of(context);

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return _FirstPostCompleteDialog(post: post, t: t);
    },
  );

  if (!context.mounted) {
    return null;
  }

  return showDialog<FirstPostSuccessAction>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return _FirstPostNextActionDialog(t: t);
    },
  );
}

class _FirstPostCompleteDialog extends ConsumerWidget {
  const _FirstPostCompleteDialog({
    required this.post,
    required this.t,
  });

  final Posts? post;
  final Translations t;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceWidth = MediaQuery.sizeOf(context).width;

    String? imageUrl;
    final storageKey = post?.firstFoodImage ?? '';
    if (storageKey.isNotEmpty) {
      imageUrl = ref
          .read(supabaseProvider)
          .storage
          .from('food')
          .getPublicUrl(storageKey);
    }

    final restaurant = post?.restaurant.trim() ?? '';
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final dateLabel = post != null
        ? DateFormat.yMd(localeTag).format(post!.createdAt.toLocal())
        : '';

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: deviceWidth * 0.85,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 40)),
              const Gap(12),
              Text(
                t.firstPostGuide.successTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const Gap(8),
              Text(
                t.firstPostGuide.successSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              if (post != null) ...[
                const Gap(20),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surfaceContainerHighest
                        : const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: imageUrl == null || imageUrl.isEmpty
                              ? ColoredBox(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade200,
                                )
                              : CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) {
                                    return Image.asset(
                                      isDark
                                          ? Assets.image.emptyDark.path
                                          : Assets.image.empty.path,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.isEmpty
                                  ? post!.foodName
                                  : restaurant,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (dateLabel.isNotEmpty) ...[
                              const Gap(4),
                              Text(
                                dateLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.55),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Gap(8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue,
                ),
                child: Text(
                  t.close,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FirstPostNextActionDialog extends StatelessWidget {
  const _FirstPostNextActionDialog({required this.t});

  final Translations t;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final deviceWidth = MediaQuery.sizeOf(context).width;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: deviceWidth * 0.85,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.firstPostGuide.nextTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const Gap(8),
              Text(
                t.firstPostGuide.nextSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const Gap(20),
              _ActionTile(
                icon: CupertinoIcons.map,
                label: t.firstPostGuide.viewMap,
                onTap: () => Navigator.of(context)
                    .pop(FirstPostSuccessAction.viewMap),
              ),
              const Gap(10),
              _ActionTile(
                icon: CupertinoIcons.book,
                label: t.firstPostGuide.viewAlbum,
                onTap: () => Navigator.of(context)
                    .pop(FirstPostSuccessAction.viewAlbum),
              ),
              const Gap(8),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(FirstPostSuccessAction.later),
                child: Text(
                  t.firstPostGuide.seeLater,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark
          ? colorScheme.surfaceContainerHighest
          : const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryBlue, size: 22),
              const Gap(12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
