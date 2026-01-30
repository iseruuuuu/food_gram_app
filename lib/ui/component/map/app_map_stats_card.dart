import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';

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
  final MapViewType viewType;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final summary = switch (viewType) {
      MapViewType.detail =>
        t.mapStatsRecordSummary.replaceAll('{days}', activityDays.toString()),
      MapViewType.japan => t.mapStatsJapanSummary
          .replaceAll('{prefectures}', visitedPrefecturesCount.toString()),
      MapViewType.world => t.mapStatsWorldSummary
          .replaceAll('{countries}', visitedCountriesCount.toString()),
    };
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
            children: _buildStatItems(t),
          ),
          const Gap(12),
          Center(
            child: Text(
              summary,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF444444),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStatItems(Translations t) {
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
                  color: Color(0xFF1A73E8),
                ),
              ),
              const Gap(4),
              Text(
                t.mapStatsVisitedArea,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
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
                t.mapStatsPosts,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
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
                t.mapStatsActivityDays,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
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
                  color: Color(0xFF1A73E8),
                ),
              ),
              const Gap(4),
              Text(
                t.mapStatsPrefectures,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
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
                t.mapStatsPosts,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
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
                t.mapStatsAchievementRate,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
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
                  color: Color(0xFF1A73E8),
                ),
              ),
              const Gap(4),
              Text(
                t.mapStatsVisitedCountries,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
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
                t.mapStatsPosts,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
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
                t.mapStatsAchievementRate,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ];
    }
  }
}
