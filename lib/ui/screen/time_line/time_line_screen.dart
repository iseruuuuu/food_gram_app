import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_tab_error.dart';
import 'package:food_gram_app/ui/component/common/app_tab_loading.dart';
import 'package:food_gram_app/ui/screen/tab/use_scroll_to_top_on_tab_trigger.dart';
import 'package:food_gram_app/ui/screen/time_line/components/timeline_category_tab_bar.dart';
import 'package:food_gram_app/ui/screen/time_line/components/timeline_feed_section.dart';
import 'package:food_gram_app/ui/screen/time_line/components/timeline_recommend_section.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TimeLineScreen extends HookConsumerWidget {
  const TimeLineScreen({super.key});

  static const int _tabIndex = 1;
  static const int _recommendCount = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategoryIndex = useState(0);
    final recommendSeed = useState(0);
    final categoriesData = ref.watch<List<CategoryData>>(categoriesProvider);
    final selectedCategoryName = categoriesData.isEmpty
        ? ''
        : (categoriesData[selectedCategoryIndex.value].isAllCategory
            ? ''
            : categoriesData[selectedCategoryIndex.value].name);
    final state = ref.watch(postsStreamProvider(selectedCategoryName));
    final scrollController = useScrollController();
    useScrollToTopOnTabTrigger(
      ref: ref,
      scrollController: scrollController,
      tabIndex: _tabIndex,
    );

    void refreshProviders() {
      ref
        ..invalidate(postsStreamProvider)
        ..invalidate(blockListProvider);
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          surfaceTintColor: Colors.transparent,
          forceMaterialTransparency: true,
          elevation: 0,
        ),
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onRefresh: () async {
          ref
              .read(firebaseAnalyticsServiceProvider)
              .logEventUnawaited(name: AnalyticsEvent.timelineRefresh);
          recommendSeed.value = recommendSeed.value + 1;
          await Future<void>.delayed(const Duration(seconds: 1));
          refreshProviders();
        },
        child: CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: TimelineCategoryTabBar(
                categories: categoriesData,
                selectedIndex: selectedCategoryIndex.value,
                onCategorySelected: (index) {
                  selectedCategoryIndex.value = index;
                  recommendSeed.value = recommendSeed.value + 1;
                },
              ),
            ),
            ...state.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return [
                    const SliverToBoxAdapter(child: AppEmpty()),
                  ];
                }
                final sorted = List<Posts>.from(posts)
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                final recommended = _pickRecommendedPosts(
                  posts: sorted,
                  count: _recommendCount,
                  seed: recommendSeed.value ^ selectedCategoryName.hashCode,
                );
                final recommendedIds =
                    recommended.map((post) => post.id).toSet();
                final remainingPosts = sorted
                    .where((post) => !recommendedIds.contains(post.id))
                    .toList();
                final feedPosts =
                    remainingPosts.isNotEmpty ? remainingPosts : sorted;
                final categoryName = selectedCategoryName.isEmpty
                    ? null
                    : selectedCategoryName;

                return [
                  SliverToBoxAdapter(
                    child: TimelineRecommendSection(
                      recommendedPosts: recommended,
                      allPosts: sorted,
                      refresh: refreshProviders,
                      categoryName: categoryName,
                    ),
                  ),
                  TimelineFeedSection(
                    feedPosts: feedPosts,
                    allPosts: sorted,
                    refresh: refreshProviders,
                    categoryName: categoryName,
                  ),
                ];
              },
              loading: () => [
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppTabLoading.food(),
                ),
              ],
              error: (_, __) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppTabError.food(
                    onRetry: () => ref
                        .refresh(postsStreamProvider(selectedCategoryName)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          heroTag: null,
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          elevation: 10,
          shape: CircleBorder(
            side: BorderSide(color: AppTheme.fabBorderColor(context)),
          ),
          onPressed: () async {
            await context
                .pushNamed(RouterPath.timeLinePost)
                .then((value) async {
              if (value != null) {
                refreshProviders();
              }
            });
          },
          child: const Icon(Icons.add, size: 35),
        ),
      ),
    );
  }

  /// ランダムに最大 [count] 件のおすすめ投稿を選ぶ
  static List<Posts> _pickRecommendedPosts({
    required List<Posts> posts,
    required int count,
    required int seed,
  }) {
    if (posts.isEmpty) {
      return const [];
    }
    if (posts.length <= count) {
      return List<Posts>.from(posts);
    }
    final shuffled = List<Posts>.from(posts)..shuffle(Random(seed));
    return shuffled.take(count).toList();
  }
}
