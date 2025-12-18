import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
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
    final l10n = L10n.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _buildStatItems(l10n),
      ),
    );
  }

  List<Widget> _buildStatItems(L10n l10n) {
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
                l10n.mapStatsVisitedArea,
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
                l10n.mapStatsPosts,
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
                '$activityDays日',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF34A853),
                ),
              ),
              const Gap(4),
              Text(
                l10n.mapStatsActivityDays,
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
                l10n.mapStatsPrefectures,
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
                l10n.mapStatsPosts,
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
                l10n.mapStatsAchievementRate,
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
                l10n.mapStatsVisitedCountries,
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
                l10n.mapStatsPosts,
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
                l10n.mapStatsAchievementRate,
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
