import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';

const _japanPrefectureMilestones = [5, 10, 15, 17, 20, 25, 30, 35, 40, 45, 47];
const _streakWeekMilestones = [2, 4, 8, 12, 24, 52];
const _worldCountryCap = 196;

int? _nextStreakWeekMilestone(int streakWeeks) {
  for (final m in _streakWeekMilestones) {
    if (streakWeeks < m) {
      return m;
    }
  }
  return null;
}

int? _nextJapanPrefectureMilestone(int visited) {
  for (final t in _japanPrefectureMilestones) {
    if (visited < t) {
      return t;
    }
  }
  return null;
}

/// マイマップの統計情報を表示するカード
class AppMapStatsCard extends StatelessWidget {
  const AppMapStatsCard({
    required this.visitedCitiesCount,
    required this.postsCount,
    required this.completionPercentage,
    required this.visitedPrefecturesCount,
    required this.visitedCountriesCount,
    required this.visitedAreasCount,
    required this.activityDays,
    required this.postingStreakWeeks,
    required this.viewType,
    super.key,
  });

  final int visitedCitiesCount;
  final int postsCount;
  final double completionPercentage;
  final int visitedPrefecturesCount;
  final int visitedCountriesCount;
  final int visitedAreasCount;
  final int activityDays;

  /// `users.streak_weeks` ベース（記録ビュー用）
  final int postingStreakWeeks;
  final MapViewType viewType;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? Colors.black : Colors.white;
    final summaryColor = isDark ? Colors.white : const Color(0xFF444444);
    final summary = switch (viewType) {
      MapViewType.detail =>
        t.mapStats.recordSummary.replaceAll('{days}', activityDays.toString()),
      MapViewType.japan => t.mapStats.japanSummary
          .replaceAll('{prefectures}', visitedPrefecturesCount.toString()),
      MapViewType.world => t.mapStats.worldSummary
          .replaceAll('{countries}', visitedCountriesCount.toString()),
    };
    final encouragementLine = _encouragementSubline(t);
    final sublineColor = isDark ? Colors.white70 : Colors.black;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildStatItems(t, isDark),
          ),
          const Gap(12),
          Center(
            child: FittedBox(
              child: Text(
                summary,
                style: TextStyle(
                  fontSize: 15,
                  color: summaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (encouragementLine != null) ...[
            const Gap(8),
            Center(
              child: Text(
                encouragementLine,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: sublineColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildStatItems(Translations t, bool isDark) {
    final labelColor = isDark ? Colors.white70 : Colors.grey[600];
    switch (viewType) {
      case MapViewType.detail:
        return [
          Column(
            children: [
              const Text(
                '📍',
                style: TextStyle(fontSize: 32),
              ),
              const Gap(8),
              Text(
                '$visitedAreasCount',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const Gap(4),
              Text(
                t.mapStats.visitedArea,
                style: TextStyle(
                  fontSize: 12,
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                '🍜',
                style: TextStyle(fontSize: 32),
              ),
              const Gap(8),
              Text(
                '$postsCount',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEA4335),
                ),
              ),
              const Gap(4),
              Text(
                t.mapStats.posts,
                style: TextStyle(
                  fontSize: 12,
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                '📅',
                style: TextStyle(fontSize: 32),
              ),
              const Gap(8),
              Text(
                '$activityDays${t.dayUnit}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF34A853),
                ),
              ),
              const Gap(4),
              Text(
                t.mapStats.activityDays,
                style: TextStyle(
                  fontSize: 12,
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ];
      case MapViewType.japan:
        return [
          Column(
            children: [
              const Text(
                '🗾',
                style: TextStyle(fontSize: 32),
              ),
              const Gap(8),
              Text(
                '$visitedPrefecturesCount/47',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const Gap(4),
              Text(
                t.mapStats.prefectures,
                style: TextStyle(
                  fontSize: 12,
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                '🍜',
                style: TextStyle(fontSize: 32),
              ),
              const Gap(8),
              Text(
                '$postsCount',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEA4335),
                ),
              ),
              const Gap(4),
              Text(
                t.mapStats.posts,
                style: TextStyle(
                  fontSize: 12,
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                '📊',
                style: TextStyle(fontSize: 32),
              ),
              const Gap(8),
              Text(
                '${(visitedPrefecturesCount / 47 * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF34A853),
                ),
              ),
              const Gap(4),
              Text(
                t.mapStats.achievementRate,
                style: TextStyle(
                  fontSize: 12,
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ];
      case MapViewType.world:
        return [
          Column(
            children: [
              const Text(
                '🌍',
                style: TextStyle(fontSize: 32),
              ),
              const Gap(8),
              Text(
                '$visitedCountriesCount/196',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const Gap(4),
              Text(
                t.mapStats.visitedCountries,
                style: TextStyle(
                  fontSize: 12,
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                '🍜',
                style: TextStyle(fontSize: 32),
              ),
              const Gap(8),
              Text(
                '$postsCount',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEA4335),
                ),
              ),
              const Gap(4),
              Text(
                t.mapStats.posts,
                style: TextStyle(
                  fontSize: 12,
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                '📊',
                style: TextStyle(fontSize: 32),
              ),
              const Gap(8),
              Text(
                '${(visitedCountriesCount / 196 * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF34A853),
                ),
              ),
              const Gap(4),
              Text(
                t.mapStats.achievementRate,
                style: TextStyle(
                  fontSize: 12,
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ];
    }
  }

  String? _encouragementSubline(Translations t) {
    switch (viewType) {
      case MapViewType.detail:
        if (postingStreakWeeks <= 0) {
          return null;
        }
        return _recordEncouragementLine(t, postingStreakWeeks);
      case MapViewType.japan:
        if (visitedPrefecturesCount >= 47) {
          return t.mapStats.japanStatsComplete;
        }
        final next = _nextJapanPrefectureMilestone(visitedPrefecturesCount);
        if (next == null) {
          return null;
        }
        final remaining = next - visitedPrefecturesCount;
        return t.mapStats.japanStatsEncouragement
            .replaceAll('{current}', visitedPrefecturesCount.toString())
            .replaceAll('{remaining}', remaining.toString());
      case MapViewType.world:
        if (visitedCountriesCount >= _worldCountryCap) {
          return t.mapStats.worldStatsComplete
              .replaceAll('{current}', visitedCountriesCount.toString());
        }
        final next = visitedCountriesCount + 1;
        return t.mapStats.worldStatsEncouragement
            .replaceAll('{current}', visitedCountriesCount.toString())
            .replaceAll('{remaining}', '1')
            .replaceAll('{next}', next.toString());
    }
  }

  String _recordEncouragementLine(Translations t, int streakWeeks) {
    final next = _nextStreakWeekMilestone(streakWeeks);
    if (next == null) {
      return t.mapStats.recordStreakKeepGoing
          .replaceAll('{streak}', streakWeeks.toString());
    }
    final remaining = next - streakWeeks;
    return t.mapStats.recordStreakWithGoal
        .replaceAll('{streak}', streakWeeks.toString())
        .replaceAll('{remaining}', remaining.toString())
        .replaceAll('{milestone}', next.toString());
  }
}
