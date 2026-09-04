import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/analyzer/record_food_traits_analyzer.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/location/prefecture_display.dart';
import 'package:food_gram_app/core/utils/map_stats_presentation.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/dialog/app_map_stats_share_dialog.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_detail_screen.dart';
import 'package:food_gram_app/ui/screen/record/components/japan/record_japan_fill_map.dart';
import 'package:food_gram_app/ui/screen/record/components/record_post_image.dart';
import 'package:food_gram_app/ui/screen/record/components/record_tab.dart';
import 'package:food_gram_app/ui/screen/record/record_view_model.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 記録タブ：日本ビュー（統計・列島マップ・投稿数ランキング）
class RecordJapanScreen extends ConsumerWidget {
  const RecordJapanScreen({
    required this.posts,
    this.scrollController,
    super.key,
  });

  final List<Posts> posts;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF161616) : Colors.white;
    final visits = recordVisitedPrefectureStats(posts);
    final ranking = recordPrefectureRanking(posts);
    final visitedCount = visits.length.clamp(0, japanPrefectureCap).toInt();
    final selectorTop = recordMapOverlayTopForContext(context);
    const bottomPadding = 120.0;
    return Padding(
      padding: EdgeInsets.only(top: selectorTop),
      child: Column(
        children: [
          RecordTab(
            currentViewType: MapViewType.japan,
            onViewTypeChanged:
                ref.read(recordViewModelProvider.notifier).changeViewType,
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
              children: [
                _JapanAtlasCard(
                  cardColor: cardColor,
                  posts: posts,
                  visitedCount: visitedCount,
                  onMapTap: (lat, lng) {
                    ref
                        .read(recordViewModelProvider.notifier)
                        .logRegionMapTap(lat, lng);
                  },
                ),
                const Gap(16),
                _JapanTop3Section(
                  cardColor: cardColor,
                  ranking: ranking,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JapanAtlasCard extends StatelessWidget {
  const _JapanAtlasCard({
    required this.cardColor,
    required this.posts,
    required this.visitedCount,
    required this.onMapTap,
  });

  final Color cardColor;
  final List<Posts> posts;
  final int visitedCount;
  final void Function(double lat, double lng) onMapTap;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ratio = (visitedCount / japanPrefectureCap).clamp(0.0, 1.0).toDouble();
    final percentText = (ratio * 100).toStringAsFixed(1);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.myMapRecord.japanAtlasTitle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      t.myMapRecord.japanAtlasHeadline,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      t.myMapRecord.japanEatingTitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: t.myMapShare.shareButton,
                onPressed: () {
                  showGeneralDialog<void>(
                    context: context,
                    pageBuilder: (_, __, ___) {
                      return AppMapStatsShareDialog(
                        postsCount: posts.length,
                        visitedPrefecturesCount: visitedCount,
                        visitedCountriesCount:
                            recordVisitedCountriesCount(posts),
                      );
                    },
                  );
                },
                icon: const Icon(
                  Icons.ios_share,
                  color: AppTheme.primaryBlue,
                  size: 22,
                ),
              ),
            ],
          ),
          const Gap(14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$visitedCount',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  color: Color(0xFF2F8F57),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2, left: 4),
                child: Text(
                  '/ $japanPrefectureCap',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),
              const Gap(8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  t.myMapRecord.prefectureConquest,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const Gap(10),
          Row(
            children: [
              Text(
                t.mapStats.achievementRate,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const Gap(6),
              Text(
                '$percentText%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const Gap(8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 7,
                    backgroundColor:
                        isDark ? Colors.white12 : const Color(0xFFE5E7EB),
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const Gap(14),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RecordJapanFillMap(
                      posts: posts,
                      onMapTap: onMapTap,
                    ),
                  ),
                  const Positioned(
                    right: 8,
                    bottom: 8,
                    child: _JapanMapLegend(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JapanMapLegend extends StatelessWidget {
  const _JapanMapLegend();

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1C1C1C) : Colors.white)
            .withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LegendRow(
            color: isDark ? const Color(0xFF3D9B64) : const Color(0xFF2F8F57),
            label: t.myMapRecord.legendHasPosts,
          ),
          const Gap(4),
          _LegendRow(
            color: isDark ? const Color(0xFF3A3632) : const Color(0xFFE8E2D8),
            label: t.myMapRecord.legendUnexplored,
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const Gap(6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _JapanTop3Section extends StatelessWidget {
  const _JapanTop3Section({
    required this.cardColor,
    required this.ranking,
  });

  final Color cardColor;
  final List<RecordPrefectureVisit> ranking;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
            t.myMapRecord.japanTop3Title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          const Gap(12),
          if (ranking.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  t.myMapRecord.noPrefectureRanking,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                for (var i = 0; i < ranking.length; i++) ...[
                  if (i > 0) const Gap(8),
                  Expanded(
                    child: _PrefectureRankCard(
                      rank: i + 1,
                      visit: ranking[i],
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _PrefectureRankCard extends StatelessWidget {
  const _PrefectureRankCard({
    required this.rank,
    required this.visit,
  });

  final int rank;
  final RecordPrefectureVisit visit;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final languageCode = Localizations.localeOf(context).languageCode;
    final name = localizedPrefectureName(
      name: visit.name,
      languageCode: languageCode,
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1D1D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFECECEC),
        ),
      ),
      child: Column(
        children: [
          if (rank == 1)
            const Text('👑', style: TextStyle(fontSize: 18, height: 1))
          else
            Text(
              '$rank',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 1,
                color: AppTheme.primaryBlue,
              ),
            ),
          const Gap(6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const Gap(2),
          Text(
            t.myMapRecord.prefectureMealUnit
                .replaceAll('{count}', '${visit.postCount}'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const Gap(8),
          RecordPostImage(
            post: visit.latestPost,
            size: 56,
            borderRadius: 28,
          ),
        ],
      ),
    );
  }
}
