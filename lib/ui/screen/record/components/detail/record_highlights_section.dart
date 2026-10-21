import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/post/analyzer/record_food_traits_analyzer.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_premium_lock.dart';
import 'package:gap/gap.dart';

/// 記録タブ：食のハイライト（一番食べた料理・最長連続記録・新しく行ったお店・よく食べる時間）
class RecordHighlightsSection extends StatelessWidget {
  const RecordHighlightsSection({
    required this.posts,
    required this.isSubscribed,
    required this.onTapPremiumCta,
    super.key,
  });

  final List<Posts> posts;
  final bool isSubscribed;
  final VoidCallback onTapPremiumCta;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const SizedBox.shrink();
    }
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final traits = analyzeRecordFoodTraits(posts);
    final longestStreak = recordLongestDailyStreak(posts);
    final isStreakUpdating = recordIsDailyStreakUpdating(posts);
    final newShopsYear = recordNewShopsThisYear(posts);
    final monthlyGrowth = recordMonthlyGrowthPercent(posts);

    final topGenreLabel = traits.topGenre != null
        ? getLocalizedFoodName(traits.topGenre!, context)
        : '—';
    final topGenreSub = traits.topGenreCount > 0
        ? t.myMapRecord.foodCountUnit
            .replaceAll('{count}', '${traits.topGenreCount}')
        : '';

    final streakValue = t.myMapRecord.streakDaysValue
        .replaceAll('{days}', '$longestStreak');
    final streakSub = isStreakUpdating
        ? t.myMapRecord.streakUpdating
        : t.myMapRecord.streakPersonalBest;

    final newShopsValue = t.myMapRecord.newShopsThisYear
        .replaceAll('{count}', '$newShopsYear');
    final newShopsSub = t.myMapRecord.explorationRateShort
        .replaceAll('{percent}', '${traits.explorationRatio}');

    final timeSlotValue = _formatTimeSlot(traits.topTimeSlot);
    final timeSlotSub = traits.topTimeCount > 0
        ? t.myMapRecord.foodCountUnit
            .replaceAll('{count}', '${traits.topTimeCount}')
        : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: recordSectionCardDecoration(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.myMapRecord.highlightsTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _HighlightTile(
                    icon: Icons.local_fire_department_rounded,
                    accent: const Color(0xFFEF4444),
                    title: t.myMapRecord.longestRecordTitle,
                    value: streakValue,
                    subtitle: streakSub,
                    isDark: isDark,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: _HighlightTile(
                    icon: Icons.restaurant_menu_rounded,
                    accent: AppTheme.primaryOrange,
                    title: t.myMapRecord.mostEatenFoodTitle,
                    value: topGenreLabel,
                    subtitle: topGenreSub,
                    isDark: isDark,
                    locked: !isSubscribed,
                    onLockedTap: onTapPremiumCta,
                  ),
                ),
              ],
            ),
          ),
          const Gap(10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _HighlightTile(
                    icon: Icons.explore_outlined,
                    accent: const Color(0xFF3B82F6),
                    title: t.myMapRecord.newShopsTitle,
                    value: newShopsValue,
                    subtitle: newShopsSub,
                    isDark: isDark,
                    locked: !isSubscribed,
                    onLockedTap: onTapPremiumCta,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: _HighlightTile(
                    icon: Icons.schedule_rounded,
                    accent: const Color(0xFF10B981),
                    title: t.myMapRecord.eatingTimeTitle,
                    value: timeSlotValue,
                    subtitle: timeSlotSub,
                    isDark: isDark,
                    locked: !isSubscribed,
                    onLockedTap: onTapPremiumCta,
                  ),
                ),
              ],
            ),
          ),
          if (monthlyGrowth != null && monthlyGrowth > 0) ...[
            const Gap(12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF241910)
                    : const Color(0xFFFFF6EE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryOrange.withValues(
                    alpha: isDark ? 0.3 : 0.2,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.myMapRecord.monthlyGrowthTitle
                        .replaceAll('{percent}', '$monthlyGrowth'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    t.myMapRecord.monthlyGrowthBody,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimeSlot(RecordMealTimeSlot? slot) {
    return switch (slot) {
      RecordMealTimeSlot.morning => '☀️ 05:00 - 11:00',
      RecordMealTimeSlot.lunch => '🍽️ 11:00 - 15:00',
      RecordMealTimeSlot.afternoon => '☕ 15:00 - 18:00',
      RecordMealTimeSlot.evening => '🌙 18:00 - 22:00',
      RecordMealTimeSlot.lateNight => '🦉 22:00 - 05:00',
      null => '—',
    };
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({
    required this.icon,
    required this.accent,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.isDark,
    this.locked = false,
    this.onLockedTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String value;
  final String subtitle;
  final bool isDark;
  final bool locked;
  final VoidCallback? onLockedTap;

  @override
  Widget build(BuildContext context) {
    final valueBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const Gap(2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ],
    );

    final tile = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1D1D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFECECEC),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accent),
              const Gap(6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
              if (locked)
                const Icon(
                  Icons.lock_rounded,
                  size: 13,
                  color: AppTheme.primaryOrange,
                ),
            ],
          ),
          const Gap(8),
          if (locked)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: valueBody,
            )
          else
            valueBody,
        ],
      ),
    );

    if (locked && onLockedTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onLockedTap,
        child: tile,
      );
    }
    return tile;
  }
}
