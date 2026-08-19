import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/purchase/services/revenue_cat_service.dart';
import 'package:food_gram_app/core/supabase/post/analyzer/record_food_traits_analyzer.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_food_traits_section.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_intro_section.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_journey_map_section.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_memories_section.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_summary_section.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_yearly_section.dart';
import 'package:food_gram_app/ui/screen/record/components/record_tab.dart';
import 'package:food_gram_app/ui/screen/record/record_view_model.dart';
import 'package:food_gram_app/ui/screen/record/record_yearly_posts_screen.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 記録タブの全体のUI
class RecordDetailScreen extends HookConsumerWidget {
  const RecordDetailScreen({
    required this.posts,
    required this.scrollController,
    super.key,
  });

  final List<Posts> posts;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        final analytics = ref.read(firebaseAnalyticsServiceProvider);
        analytics.logEvent(name: AnalyticsEvent.recordOpen);
        analytics.logOnceEvent(
          key: PreferenceKey.analyticsFirstRecordOpen,
          name: AnalyticsEvent.firstRecordOpen,
        );
        analytics.logEvent(name: AnalyticsEvent.insightOpen);
        analytics.logOnceEvent(
          key: PreferenceKey.analyticsFirstInsightOpen,
          name: AnalyticsEvent.firstInsightOpen,
        );
        analytics.logEventUnawaited(name: AnalyticsEvent.recordSummaryOpen);
        analytics.logEventUnawaited(name: AnalyticsEvent.recordYearOpen);
        analytics.logEventUnawaited(name: AnalyticsEvent.recordRecentPostOpen);
        analytics.logEventUnawaited(name: AnalyticsEvent.recordStatisticsOpen);
        analytics.logEventUnawaited(name: AnalyticsEvent.foodInsightAreaOpen);
        analytics.logEventUnawaited(name: AnalyticsEvent.foodInsightGenreOpen);
        analytics.logEventUnawaited(name: AnalyticsEvent.foodInsightTimeOpen);
        analytics.logEventUnawaited(
          name: AnalyticsEvent.foodInsightRestaurantOpen,
        );
        return null;
      },
      const [],
    );
    final selectedYear = useState<int?>(null);
    final pastMemoriesKey = useMemoized(GlobalKey.new);
    final isSubscribe = ref.watch(isSubscribeProvider).valueOrNull ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF161616) : Colors.white;
    final mutedColor = isDark ? Colors.white70 : Colors.black54;
    final recentPosts = [...posts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final featuredIds =
        recordFeaturedMemoryPosts(posts).map((post) => post.id).toSet();
    final pastPosts =
        recentPosts.where((post) => !featuredIds.contains(post.id)).toList()
          ..sort((a, b) {
            final heartCompare = b.heart.compareTo(a.heart);
            if (heartCompare != 0) {
              return heartCompare;
            }
            return b.createdAt.compareTo(a.createdAt);
          });
    final displayedPastPosts = selectedYear.value == null
        ? pastPosts
        : (recentPosts
              .where((post) => post.createdAt.year == selectedYear.value)
              .toList()
            ..sort((a, b) {
              final heartCompare = b.heart.compareTo(a.heart);
              if (heartCompare != 0) {
                return heartCompare;
              }
              return b.createdAt.compareTo(a.createdAt);
            }));
    final yearlyCounts = <int, int>{};
    for (final post in posts) {
      final year = post.createdAt.year;
      yearlyCounts[year] = (yearlyCounts[year] ?? 0) + 1;
    }
    final sortedYears = yearlyCounts.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    final uniqueShops = _countUniqueRestaurants(posts);
    final monthlyGrowth = recordMonthlyGrowthPercent(posts);
    final selectorTop = recordMapOverlayTopForContext(context);
    const viewTypeTabHeight = 68.0;
    const bottomPadding = 96.0;
    return Stack(
      children: [
        if (posts.isEmpty)
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                selectorTop + viewTypeTabHeight,
                16,
                bottomPadding,
              ),
              child: RecordEmptySection(
                onRecordTap: () async {
                  ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
                        name: AnalyticsEvent.recordPostOpen,
                      );
                  final result = await context.pushNamed(
                    RouterPath.timeLinePost,
                  );
                  if (result == null || !context.mounted) {
                    return;
                  }
                  ref.invalidate(myMapRepositoryProvider);
                },
              ),
            ),
          )
        else
          CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  selectorTop + viewTypeTabHeight,
                  16,
                  bottomPadding,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const RecordWelcomeSection(),
                      const Gap(8),
                      RecordTodayMemoriesSection(posts: posts),
                      const Gap(14),
                      RecordSummarySection(
                        mealsCount: posts.length,
                        shopsCount: uniqueShops,
                        prefecturesCount: recordVisitedPrefecturesCount(posts),
                        countriesCount: recordVisitedCountriesCount(posts),
                      ),
                      const Gap(14),
                      RecordJourneyMapSection(
                        posts: posts,
                        cardColor: cardColor,
                        onSeeMore: () {
                          ref
                              .read(recordViewModelProvider.notifier)
                              .changeViewType(MapViewType.world);
                        },
                      ),
                      const Gap(14),
                      RecordFoodTraitsSection(
                        posts: posts,
                        cardColor: cardColor,
                        isSubscribed: isSubscribe,
                        onTapPremiumCta: () {
                          ref
                              .read(firebaseAnalyticsServiceProvider)
                              .logPremiumFeatureTap(
                                AnalyticsEvent.premiumRankingTap,
                              );
                          ref
                              .read(revenueCatServiceProvider.notifier)
                              .presentPaywallGuarded();
                        },
                      ),
                      if (monthlyGrowth != null && monthlyGrowth > 0) ...[
                        const Gap(14),
                        _MonthlyGrowthBanner(percent: monthlyGrowth),
                      ],
                      const Gap(14),
                      RecordYearlySection(
                        cardColor: cardColor,
                        mutedColor: mutedColor,
                        sortedYears: sortedYears,
                        yearlyCounts: yearlyCounts,
                        recentPosts: recentPosts,
                        selectedYear: selectedYear.value,
                        onYearSelected: (year) {
                          selectedYear.value =
                              selectedYear.value == year ? null : year;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final target = pastMemoriesKey.currentContext;
                            if (target == null) {
                              return;
                            }
                            Scrollable.ensureVisible(
                              target,
                              duration: const Duration(milliseconds: 280),
                              alignment: 0.15,
                            );
                          });
                        },
                      ),
                      if (displayedPastPosts.isNotEmpty) ...[
                        const Gap(14),
                        RecordRecentSection(
                          key: pastMemoriesKey,
                          cardColor: cardColor,
                          pastPosts: displayedPastPosts,
                          onSeeMore: () {
                            context.pushNamed(
                              RouterPath.recordYearlyPosts,
                              extra: RecordYearlyPostsExtra(
                                posts: displayedPastPosts,
                                title: Translations.of(context)
                                    .myMapRecord
                                    .pastMemoriesLabel,
                              ),
                            );
                          },
                        ),
                      ],
                      const Gap(20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        Positioned(
          top: selectorTop,
          left: 0,
          right: 0,
          child: RecordTab(
            currentViewType: MapViewType.detail,
            onViewTypeChanged:
                ref.read(recordViewModelProvider.notifier).changeViewType,
          ),
        ),
      ],
    );
  }
}

class _MonthlyGrowthBanner extends StatelessWidget {
  const _MonthlyGrowthBanner({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16283A) : const Color(0xFFEAF3FE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('📊', style: TextStyle(fontSize: 18)),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.myMapRecord.monthlyGrowthTitle
                      .replaceAll('{percent}', '$percent'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1565C0),
                  ),
                ),
                const Gap(2),
                Text(
                  t.myMapRecord.monthlyGrowthBody,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.white38 : const Color(0xFF90CAF9),
          ),
        ],
      ),
    );
  }
}

int _countUniqueRestaurants(List<Posts> posts) {
  return posts
      .map((post) => post.restaurant.trim())
      .where((name) => name.isNotEmpty)
      .toSet()
      .length;
}

double recordMapOverlayTopForContext(BuildContext context) {
  final topInset = MediaQuery.of(context).padding.top;
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth <= 375) {
    return topInset + 8;
  } else if (screenWidth < 720) {
    return topInset + 16;
  } else {
    return topInset + 12;
  }
}
