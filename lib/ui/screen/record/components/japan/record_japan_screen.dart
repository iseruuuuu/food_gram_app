import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/analyzer/record_food_traits_analyzer.dart';
import 'package:food_gram_app/core/supabase/post/repository/detail_post_repository.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/location/prefecture_display.dart';
import 'package:food_gram_app/core/utils/map_stats_presentation.dart';
import 'package:food_gram_app/core/utils/restaurant/restaurant_display_name.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/dialog/app_map_stats_share_dialog.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_detail_screen.dart';
import 'package:food_gram_app/ui/screen/record/components/japan/record_japan_fill_map.dart';
import 'package:food_gram_app/ui/screen/record/components/record_post_image.dart';
import 'package:food_gram_app/ui/screen/record/components/record_tab.dart';
import 'package:food_gram_app/ui/screen/record/record_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 記録タブ：日本ビュー（統計・列島マップ）
class RecordJapanScreen extends HookConsumerWidget {
  const RecordJapanScreen({
    required this.posts,
    super.key,
  });

  final List<Posts> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPostIds = useState<List<int>>(const []);
    final postsById = {for (final post in posts) post.id: post};
    final selectedPosts = [
      for (final id in selectedPostIds.value)
        if (postsById[id] != null) postsById[id]!,
    ];
    useEffect(
      () {
        final currentIds = postsById.keys.toSet();
        final retained = [
          for (final id in selectedPostIds.value)
            if (currentIds.contains(id)) id,
        ];
        if (retained.length != selectedPostIds.value.length) {
          selectedPostIds.value = retained;
        }
        return null;
      },
      [posts],
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF161616) : Colors.white;
    final visits = recordVisitedPrefectureStats(posts);
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
              child: _JapanAtlasCard(
                cardColor: cardColor,
                posts: posts,
                visitedCount: visitedCount,
                selectedPosts: selectedPosts,
                onPinTap: (tapped) {
                  selectedPostIds.value = [
                    for (final post in tapped) post.id,
                  ];
                },
                onMapTap: (lat, lng) {
                  selectedPostIds.value = const [];
                  ref
                      .read(recordViewModelProvider.notifier)
                      .logRegionMapTap(lat, lng);
                },
              ),
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
    required this.selectedPosts,
    required this.onPinTap,
    required this.onMapTap,
  });

  final Color cardColor;
  final List<Posts> posts;
  final int visitedCount;
  final List<Posts> selectedPosts;
  final void Function(List<Posts> posts) onPinTap;
  final void Function(double lat, double lng) onMapTap;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ratio =
        (visitedCount / japanPrefectureCap).clamp(0.0, 1.0).toDouble();
    final percentText = (ratio * 100).toStringAsFixed(1);
    return Container(
      width: double.infinity,
      height: double.infinity,
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
          Text(
            t.myMapRecord.japanAtlasHeadline,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const Gap(10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$visitedCount',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  color: AppTheme.primaryOrange,
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
              const Spacer(),
              IconButton(
                tooltip: t.myMapShare.shareButton,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
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
                  color: AppTheme.primaryOrange,
                  size: 22,
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
                  color: AppTheme.primaryOrange,
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
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ),
            ],
          ),
          const Gap(14),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RecordJapanFillMap(
                      posts: posts,
                      onMapTap: onMapTap,
                      onPinTap: onPinTap,
                    ),
                  ),
                  if (selectedPosts.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: _JapanPinPostList(posts: selectedPosts),
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

class _JapanPinPostList extends ConsumerWidget {
  const _JapanPinPostList({required this.posts});

  final List<Posts> posts;

  static const _tileHeight = 64.0;
  static const _visibleCount = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visibleCount = math.min(posts.length, _visibleCount);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1D1D) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFECECEC),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: _tileHeight * visibleCount,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            physics: posts.length > _visibleCount
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: isDark ? Colors.white12 : Colors.black12,
            ),
            itemBuilder: (context, index) {
              return _JapanPinPostTile(
                posts: posts,
                index: index,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _JapanPinPostTile extends ConsumerWidget {
  const _JapanPinPostTile({
    required this.posts,
    required this.index,
  });

  final List<Posts> posts;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final post = posts[index];
    final subtitle = post.hasFoodName && post.hasRestaurant
        ? post.localizedRestaurant(t)
        : null;
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      leading: RecordPostImage(
        post: post,
        size: 44,
        borderRadius: 8,
      ),
      title: Text(
        post.localizedDisplayTitle(t),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
      trailing: Icon(
        Icons.chevron_right,
        size: 20,
        color: isDark ? Colors.white38 : Colors.black26,
      ),
      onTap: () => _openPost(context, ref),
    );
  }

  Future<void> _openPost(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(detailPostRepositoryProvider.notifier)
        .getPostData(posts, index);
    await result.whenOrNull(
      success: (model) async {
        if (!context.mounted) {
          return;
        }
        await context.pushNamed(
          RouterPath.myProfileDetail,
          extra: model,
        );
      },
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
            color: isDark ? const Color(0xFFFFA347) : AppTheme.primaryOrange,
            label: t.myMapRecord.legendHasPosts,
            gradient: LinearGradient(
              colors: isDark
                  ? const [Color(0xFF5A4533), Color(0xFFFFA347)]
                  : const [Color(0xFFF7E6CF), Color(0xFFE88932)],
            ),
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
    this.gradient,
  });

  final Color color;
  final String label;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: gradient == null ? 8 : 16,
          height: 8,
          decoration: BoxDecoration(
            color: gradient == null ? color : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(999),
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
