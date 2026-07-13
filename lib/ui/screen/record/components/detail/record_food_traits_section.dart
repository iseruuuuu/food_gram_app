import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/analyzer/record_food_traits_analyzer.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';

/// 記録タブ：プレミアム向けの「食の旅のハイライト」カード群
class RecordFoodTraitsSection extends StatelessWidget {
  const RecordFoodTraitsSection({
    required this.posts,
    required this.cardColor,
    required this.mutedColor,
    required this.isSubscribed,
    required this.onTapPremiumCta,
    super.key,
  });

  final List<Posts> posts;
  final Color cardColor;
  final Color mutedColor;
  final bool isSubscribed;
  final VoidCallback onTapPremiumCta;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final summary = analyzeRecordFoodTraits(posts);
    final total = summary.totalPosts == 0 ? 1 : summary.totalPosts;
    final newShopsThisYear = recordNewShopsThisYear(posts);
    final longestStreak = recordLongestDailyStreak(posts);
    final highlights = [
      _HighlightItem(
        icon: '🍜',
        accent: const Color(0xFFEA4335),
        title: t.myMapRecord.mostEatenFoodTitle,
        value: summary.topGenre ?? t.myMapRecord.foodTraits.noData,
        valueFontSize: 26,
        sub: summary.topGenre == null
            ? null
            : t.myMapRecord.foodCountUnit
                .replaceAll('{count}', '${summary.topGenreCount}'),
      ),
      _HighlightItem(
        icon: '🕐',
        accent: const Color(0xFFF59E0B),
        title: t.myMapRecord.eatingTimeTitle,
        value: summary.topTimeSlot == null
            ? t.myMapRecord.foodTraits.noData
            : recordFoodTraitsTimeSlotLabel(t, summary.topTimeSlot!),
        sub: summary.topTimeSlot == null
            ? null
            : t.myMapRecord.foodTraits.shareOfTotal.replaceAll(
                '{percent}',
                '${recordFoodTraitsRatio(summary.topTimeCount, total)}',
              ),
      ),
      _HighlightItem(
        icon: '🏪',
        accent: const Color(0xFF3B82F6),
        title: t.myMapRecord.newShopsTitle,
        value: t.myMapRecord.newShopsThisYear
            .replaceAll('{count}', '$newShopsThisYear'),
        sub: t.myMapRecord.explorationRateShort
            .replaceAll('{percent}', '${summary.explorationRatio}'),
      ),
      _HighlightItem(
        icon: '🔥',
        accent: const Color(0xFFA855F7),
        title: t.myMapRecord.longestRecordTitle,
        value: t.myMapRecord.streakDaysValue
            .replaceAll('{days}', '$longestStreak'),
        sub: t.myMapRecord.streakUpdating,
      ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('👑', style: TextStyle(fontSize: 17)),
                const Gap(6),
                Text(
                  t.myMapRecord.highlightsTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const Gap(12),
            Stack(
              children: [
                GridView.count(
                  padding: EdgeInsets.zero,
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: highlights
                      .map((item) => _HighlightCard(item: item))
                      .toList(),
                ),
                if (!isSubscribed)
                  Positioned.fill(
                    child: _NonSubscriberOverlay(
                      t: t,
                      onTapPremiumCta: onTapPremiumCta,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightItem {
  const _HighlightItem({
    required this.icon,
    required this.accent,
    required this.title,
    required this.value,
    this.sub,
    this.valueFontSize = 17,
  });

  final String icon;
  final Color accent;
  final String title;
  final String value;
  final String? sub;
  final double valueFontSize;
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.item});

  final _HighlightItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1D1D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFECECEC),
        ),
      ),
      child: Column(
        children: [
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const Gap(9),
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: item.valueFontSize,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          if (item.sub != null) ...[
            const Gap(6),
            Text(
              item.sub!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: item.accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NonSubscriberOverlay extends StatelessWidget {
  const _NonSubscriberOverlay({
    required this.t,
    required this.onTapPremiumCta,
  });

  final Translations t;
  final VoidCallback onTapPremiumCta;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.72),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.08),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 28,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Gap(4),
                Text(
                  t.myMapRecord.foodTraits.lockedDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(8),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: onTapPremiumCta,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFE8A63A),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: Text(
                      t.myMapRecord.foodTraits.premiumCta,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
