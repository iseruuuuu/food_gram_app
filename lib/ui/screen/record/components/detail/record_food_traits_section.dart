import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/post/analyzer/record_food_traits_analyzer.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/food_tag_icon.dart';
import 'package:gap/gap.dart';

/// 記録タブ：プレミアム向けの「食のハイライト」カード群
class RecordFoodTraitsSection extends StatelessWidget {
  const RecordFoodTraitsSection({
    required this.posts,
    required this.cardColor,
    required this.isSubscribed,
    required this.onTapPremiumCta,
    super.key,
  });

  final List<Posts> posts;
  final Color cardColor;
  final bool isSubscribed;
  final VoidCallback onTapPremiumCta;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summary = analyzeRecordFoodTraits(posts);
    final total = summary.totalPosts == 0 ? 1 : summary.totalPosts;
    final newShopsThisYear = recordNewShopsThisYear(posts);
    final longestStreak = recordLongestDailyStreak(posts);
    final isStreakUpdating = recordIsDailyStreakUpdating(posts);
    final topFoodId = summary.topGenre;
    final topFoodLabel = topFoodId == null
        ? t.myMapRecord.foodTraits.noData
        : getLocalizedFoodName(topFoodId, context);
    final highlights = [
      _HighlightItem(
        background: isDark ? const Color(0xFF1A2740) : const Color(0xFFE8F2FC),
        title: t.myMapRecord.mostEatenFoodTitle,
        value: topFoodLabel,
        sub: topFoodId == null
            ? null
            : t.myMapRecord.foodCountUnit
                .replaceAll('{count}', '${summary.topGenreCount}'),
        trailing: _FoodTrailing(tagId: topFoodId),
      ),
      _HighlightItem(
        background: isDark ? const Color(0xFF241E38) : const Color(0xFFEEE8F8),
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
        trailing: _EmojiTrailing(
          emoji: _timeSlotEmoji(summary.topTimeSlot),
        ),
      ),
      _HighlightItem(
        background: isDark ? const Color(0xFF2A2218) : const Color(0xFFFFF0E4),
        title: t.myMapRecord.newShopsTitle,
        value: t.myMapRecord.newShopsThisYear
            .replaceAll('{count}', '$newShopsThisYear'),
        sub: t.myMapRecord.explorationRateShort
            .replaceAll('{percent}', '${summary.explorationRatio}'),
        trailing: const _EmojiTrailing(emoji: '🏪'),
      ),
      _HighlightItem(
        background: isDark ? const Color(0xFF2A2718) : const Color(0xFFFFF6D8),
        title: t.myMapRecord.longestRecordTitle,
        value: t.myMapRecord.streakDaysValue
            .replaceAll('{days}', '$longestStreak'),
        sub: isStreakUpdating
            ? t.myMapRecord.streakUpdating
            : t.myMapRecord.streakPersonalBest,
        subColor: isStreakUpdating ? const Color(0xFFF97316) : null,
        trailing: const _EmojiTrailing(emoji: '📅'),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
          Text(
            t.myMapRecord.highlightsTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
                childAspectRatio: 1.38,
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
    );
  }
}

String _timeSlotEmoji(RecordMealTimeSlot? slot) {
  return switch (slot) {
    RecordMealTimeSlot.evening || RecordMealTimeSlot.lateNight => '🌙',
    _ => '☀️',
  };
}

class _HighlightItem {
  const _HighlightItem({
    required this.background,
    required this.title,
    required this.value,
    required this.trailing,
    this.sub,
    this.subColor,
  });

  final Color background;
  final String title;
  final String value;
  final String? sub;
  final Color? subColor;
  final Widget trailing;
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.item});

  final _HighlightItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? Colors.white60 : Colors.black;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 10),
      decoration: BoxDecoration(
        color: item.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: muted,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  item.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                if (item.sub != null) ...[
                  const Spacer(),
                  FittedBox(
                    child: Text(
                      item.sub!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: item.subColor ?? muted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Gap(4),
          item.trailing,
        ],
      ),
    );
  }
}

class _FoodTrailing extends StatelessWidget {
  const _FoodTrailing({required this.tagId});

  final String? tagId;

  @override
  Widget build(BuildContext context) {
    if (tagId == null) {
      return const _EmojiTrailing(emoji: '🍽️');
    }
    return SizedBox(
      width: 50,
      height: 50,
      child: FoodTagIcon(
        tagId: tagId!,
        size: 40,
        textStyle: const TextStyle(fontSize: 30),
        centerText: true,
      ),
    );
  }
}

class _EmojiTrailing extends StatelessWidget {
  const _EmojiTrailing({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 30)),
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
      borderRadius: BorderRadius.circular(16),
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
