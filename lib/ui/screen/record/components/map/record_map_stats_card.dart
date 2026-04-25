import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/map_stats_presentation.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';

/// 記録タブ：日本／世界マップ用の統計サマリーカード
class RecordMapStatsCard extends StatelessWidget {
  const RecordMapStatsCard({
    required this.postsCount,
    required this.visitedPrefecturesCount,
    required this.visitedCountriesCount,
    required this.visitedAreasCount,
    required this.activityDays,
    required this.postingStreakWeeks,
    required this.viewType,
    super.key,
  });

  final int postsCount;
  final int visitedPrefecturesCount;
  final int visitedCountriesCount;
  final int visitedAreasCount;
  final int activityDays;
  final int postingStreakWeeks;
  final MapViewType viewType;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? Colors.black : Colors.white;
    final summaryColor = isDark ? Colors.white : const Color(0xFF444444);
    final pres = MapStatsPresentation.build(
      t: t,
      viewType: viewType,
      postsCount: postsCount,
      visitedPrefecturesCount: visitedPrefecturesCount,
      visitedCountriesCount: visitedCountriesCount,
      visitedAreasCount: visitedAreasCount,
      activityDays: activityDays,
      postingStreakWeeks: postingStreakWeeks,
    );
    final sublineColor = isDark ? Colors.white70 : Colors.black;
    final statLabelColor = isDark ? Colors.white70 : Colors.grey[600];
    const valueBlue = AppTheme.primaryBlue;
    const valueRed = Color(0xFFEA4335);
    const valueGreen = Color(0xFF34A853);
    final statValueColors = [valueBlue, valueRed, valueGreen];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            children: List.generate(pres.columns.length, (i) {
              final c = pres.columns[i];
              return Column(
                children: [
                  const Gap(8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(c.emoji, style: const TextStyle(fontSize: 28)),
                      const Gap(8),
                      Column(
                        children: [
                          Text(
                            c.value,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: statValueColors[i],
                            ),
                          ),
                          const Gap(2),
                          Text(
                            c.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: statLabelColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
          if (viewType == MapViewType.japan) ...[
            const Gap(12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF0F2E4D) : const Color(0xFFE9F2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      pres.milestoneHint!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFF9CCBFF)
                            : const Color(0xFF2B6CB0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (viewType == MapViewType.world) ...[
            const Gap(12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF0F2E4D) : const Color(0xFFE9F2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      pres.milestoneHint!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFF9CCBFF)
                            : const Color(0xFF2B6CB0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Gap(12),
            Center(
              child: FittedBox(
                child: Text(
                  pres.summary,
                  style: TextStyle(
                    fontSize: 15,
                    color: summaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (pres.encouragement != null) ...[
              const Gap(8),
              Center(
                child: Text(
                  pres.encouragement!,
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
        ],
      ),
    );
  }
}
