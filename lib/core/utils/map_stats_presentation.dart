import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/gen/strings.g.dart';

const japanPrefectureMilestones = [5, 10, 15, 17, 20, 25, 30, 35, 40, 45, 47];
const streakWeekMilestones = [2, 4, 8, 12, 24, 52];
const japanPrefectureCap = 47;
const worldCountryCap = 196;

int? nextStreakWeekMilestone(int streakWeeks) {
  for (final m in streakWeekMilestones) {
    if (streakWeeks < m) {
      return m;
    }
  }
  return null;
}

int? nextJapanPrefectureMilestone(int visited) {
  for (final t in japanPrefectureMilestones) {
    if (visited < t) {
      return t;
    }
  }
  return null;
}

/// マイマップ統計カードとホームウィジェットで共有する
/// 表示用データ。
class MapStatsPresentation {
  const MapStatsPresentation({
    required this.viewType,
    required this.columns,
    required this.summary,
    this.encouragement,
  });

  factory MapStatsPresentation.build({
    required Translations t,
    required MapViewType viewType,
    required int postsCount,
    required int visitedPrefecturesCount,
    required int visitedCountriesCount,
    required int visitedAreasCount,
    required int activityDays,
    required int postingStreakWeeks,
  }) {
    final safePostsCount = postsCount < 0 ? 0 : postsCount;
    final safeVisitedPrefecturesCount = visitedPrefecturesCount.clamp(
      0,
      japanPrefectureCap,
    );
    final safeVisitedCountriesCount = visitedCountriesCount.clamp(
      0,
      worldCountryCap,
    );
    final safeVisitedAreasCount = visitedAreasCount < 0 ? 0 : visitedAreasCount;
    final safeActivityDays = activityDays < 0 ? 0 : activityDays;
    final safePostingStreakWeeks =
        postingStreakWeeks < 0 ? 0 : postingStreakWeeks;
    final japanAchievementPct =
        (safeVisitedPrefecturesCount / japanPrefectureCap * 100)
            .toStringAsFixed(1);
    final worldAchievementPct =
        (safeVisitedCountriesCount / worldCountryCap * 100).toStringAsFixed(1);

    final summary = switch (viewType) {
      MapViewType.detail => t.mapStats.recordSummary
          .replaceAll('{days}', safeActivityDays.toString()),
      MapViewType.japan => t.mapStats.japanSummary
          .replaceAll('{prefectures}', safeVisitedPrefecturesCount.toString()),
      MapViewType.world => t.mapStats.worldSummary
          .replaceAll('{countries}', safeVisitedCountriesCount.toString()),
    };

    final columns = switch (viewType) {
      MapViewType.detail => [
          MapStatsColumnPresentation(
            emoji: '📍',
            value: '$safeVisitedAreasCount',
            label: t.mapStats.visitedArea,
          ),
          MapStatsColumnPresentation(
            emoji: '🍜',
            value: '$safePostsCount',
            label: t.mapStats.posts,
          ),
          MapStatsColumnPresentation(
            emoji: '📅',
            value: '$safeActivityDays${t.dayUnit}',
            label: t.mapStats.activityDays,
          ),
        ],
      MapViewType.japan => [
          MapStatsColumnPresentation(
            emoji: '🗾',
            value: '$safeVisitedPrefecturesCount/$japanPrefectureCap',
            label: t.mapStats.prefectures,
          ),
          MapStatsColumnPresentation(
            emoji: '🍜',
            value: '$safePostsCount',
            label: t.mapStats.posts,
          ),
          MapStatsColumnPresentation(
            emoji: '📊',
            value: '$japanAchievementPct%',
            label: t.mapStats.achievementRate,
          ),
        ],
      MapViewType.world => [
          MapStatsColumnPresentation(
            emoji: '🌍',
            value: '$safeVisitedCountriesCount/$worldCountryCap',
            label: t.mapStats.visitedCountries,
          ),
          MapStatsColumnPresentation(
            emoji: '🍜',
            value: '$safePostsCount',
            label: t.mapStats.posts,
          ),
          MapStatsColumnPresentation(
            emoji: '📊',
            value: '$worldAchievementPct%',
            label: t.mapStats.achievementRate,
          ),
        ],
    };

    final encouragement = _encouragement(
      t: t,
      viewType: viewType,
      visitedPrefecturesCount: safeVisitedPrefecturesCount,
      visitedCountriesCount: safeVisitedCountriesCount,
      postingStreakWeeks: safePostingStreakWeeks,
    );

    return MapStatsPresentation(
      viewType: viewType,
      columns: columns,
      summary: summary,
      encouragement: encouragement,
    );
  }

  final MapViewType viewType;
  final List<MapStatsColumnPresentation> columns;
  final String summary;
  final String? encouragement;

  Map<String, dynamic> toJson() => {
        'viewType': viewType.name,
        'columns': columns.map((c) => c.toJson()).toList(),
        'summary': summary,
        if (encouragement != null) 'encouragement': encouragement,
      };

  static String? _encouragement({
    required Translations t,
    required MapViewType viewType,
    required int visitedPrefecturesCount,
    required int visitedCountriesCount,
    required int postingStreakWeeks,
  }) {
    switch (viewType) {
      case MapViewType.detail:
        if (postingStreakWeeks <= 0) {
          return null;
        }
        final next = nextStreakWeekMilestone(postingStreakWeeks);
        if (next == null) {
          return t.mapStats.recordStreakKeepGoing
              .replaceAll('{streak}', postingStreakWeeks.toString());
        }
        final remaining = next - postingStreakWeeks;
        return t.mapStats.recordStreakWithGoal
            .replaceAll('{streak}', postingStreakWeeks.toString())
            .replaceAll('{remaining}', remaining.toString())
            .replaceAll('{milestone}', next.toString());
      case MapViewType.japan:
        if (visitedPrefecturesCount >= japanPrefectureCap) {
          return t.mapStats.japanStatsComplete;
        }
        final next = nextJapanPrefectureMilestone(visitedPrefecturesCount);
        if (next == null) {
          return null;
        }
        final remaining = next - visitedPrefecturesCount;
        return t.mapStats.japanStatsEncouragement
            .replaceAll('{current}', visitedPrefecturesCount.toString())
            .replaceAll('{remaining}', remaining.toString());
      case MapViewType.world:
        if (visitedCountriesCount >= worldCountryCap) {
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
}

class MapStatsColumnPresentation {
  const MapStatsColumnPresentation({
    required this.emoji,
    required this.value,
    required this.label,
  });

  final String emoji;
  final String value;
  final String label;

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'value': value,
        'label': label,
      };
}
