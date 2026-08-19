import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/food_tag_registry.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/food_tag_icon.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';

/// 記録タブ上部：あいさつ・タグ画像・犬のLottie
class RecordWelcomeSection extends HookWidget {
  const RecordWelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tagIds = useMemoized(() {
      final ids = customFoodTags.keys.toList()..shuffle();
      return ids.take(4).toList();
    });
    final background = isDark
        ? const [Color(0xFF16283A), Color(0xFF0F1C2C)]
        : const [Color(0xFFD6EBFA), Color(0xFFEAF3FE)];
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: background,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -28,
            right: 72,
            child: _SoftBlob(
              size: 88,
              color:
                  AppTheme.primaryBlue.withValues(alpha: isDark ? 0.35 : 0.18),
            ),
          ),
          Positioned(
            bottom: -36,
            left: -18,
            child: _SoftBlob(
              size: 110,
              color: const Color(0xFF5BA3D9)
                  .withValues(alpha: isDark ? 0.28 : 0.22),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t.myMapRecord.welcomeTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark ? Colors.white : const Color(0xFF0B3A66),
                        ),
                      ),
                      const Gap(4),
                      Row(
                        children: [
                          for (var i = 0; i < tagIds.length; i++) ...[
                            _WelcomeTagChip(
                              tagId: tagIds[i],
                              isDark: isDark,
                            ),
                            if (i != tagIds.length - 1) const Gap(8),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Lottie.asset(
                  Assets.lottie.sammaryDog,
                  width: 108,
                  height: 108,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftBlob extends StatelessWidget {
  const _SoftBlob({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _WelcomeTagChip extends StatelessWidget {
  const _WelcomeTagChip({
    required this.tagId,
    required this.isDark,
  });

  final String tagId;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FoodTagIcon(tagId: tagId, size: 36),
    );
  }
}

/// 記録タブ：まだ投稿していない人向けの空状態
class RecordEmptySection extends StatelessWidget {
  const RecordEmptySection({
    required this.onRecordTap,
    super.key,
  });

  final VoidCallback onRecordTap;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            Assets.lottie.noRecord,
            width: 220,
            height: 220,
            fit: BoxFit.contain,
          ),
          const Gap(16),
          Text(
            t.myMapRecord.emptyTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
          const Gap(8),
          Text(
            t.myMapRecord.emptyBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const Gap(24),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 52,
            child: ElevatedButton(
              onPressed: onRecordTap,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                t.myMapRecord.emptyCta,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
