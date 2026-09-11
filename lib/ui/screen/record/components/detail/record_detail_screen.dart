import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/purchase/services/revenue_cat_service.dart';
import 'package:food_gram_app/core/supabase/post/analyzer/record_food_traits_analyzer.dart';
import 'package:food_gram_app/core/supabase/post/analyzer/record_insight_analyzer.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/utils/location/country_detector.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_intro_section.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_memories_section.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_summary_section.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_yearly_section.dart';
import 'package:food_gram_app/ui/screen/record/components/record_tab.dart';
import 'package:food_gram_app/ui/screen/record/record_view_model.dart';
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
    useFuture(useMemoized(CountryDetector.ensureLoaded));
    final selectedYear = useState<int?>(null);
    final isSubscribe = ref.watch(isSubscribeProvider).valueOrNull ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF161616) : Colors.white;
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
    final years = recordSortedYears(posts);
    final recapYear = selectedYear.value ??
        (years.isNotEmpty ? years.first : DateTime.now().year);
    final displayedPastPosts = selectedYear.value == null
        ? pastPosts
        : (recentPosts
            .where(
              (post) => post.createdAt.toLocal().year == selectedYear.value,
            )
            .toList()
          ..sort((a, b) {
            final heartCompare = b.heart.compareTo(a.heart);
            if (heartCompare != 0) {
              return heartCompare;
            }
            return b.createdAt.compareTo(a.createdAt);
          }));
    final uniqueShops = recordUniqueRestaurantsCount(posts);
    final selectorTop = recordMapOverlayTopForContext(context);
    const viewTypeTabHeight = 68.0;
    const bottomPadding = 96.0;

    void openPaywall() {
      ref.read(firebaseAnalyticsServiceProvider).logPremiumFeatureTap(
            AnalyticsEvent.premiumRankingTap,
          );
      ref.read(revenueCatServiceProvider.notifier).presentPaywallGuarded();
    }

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
                      RecordTodayMemoriesSection(posts: recentPosts),
                      const Gap(14),
                      RecordSummarySection(
                        mealsCount: posts.length,
                        shopsCount: uniqueShops,
                        prefecturesCount: recordVisitedPrefecturesCount(posts),
                        countriesCount: recordVisitedCountriesCount(posts),
                        isSubscribed: isSubscribe,
                        onTapPremiumCta: openPaywall,
                      ),
                      const Gap(14),
                      RecordYearlySection(
                        posts: posts,
                        selectedYear: recapYear,
                        onYearSelected: (year) {
                          selectedYear.value = year;
                        },
                        isSubscribed: isSubscribe,
                        onTapPremiumCta: openPaywall,
                      ),
                      if (displayedPastPosts.isNotEmpty) ...[
                        const Gap(14),
                        RecordRecentSection(
                          cardColor: cardColor,
                          pastPosts: displayedPastPosts,
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
