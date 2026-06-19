import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_error_widget.dart';
import 'package:food_gram_app/ui/component/common/app_list_view.dart';
import 'package:food_gram_app/ui/component/common/app_tab_loading.dart';
import 'package:food_gram_app/ui/screen/tab/use_scroll_to_top_on_tab_trigger.dart';
import 'package:food_gram_app/ui/screen/time_line/components/timeline_category_tab_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TimeLineScreen extends HookConsumerWidget {
  const TimeLineScreen({super.key});

  static const int _tabIndex = 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategoryIndex = useState(0);
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
    useEffect(
      () {
        ref
            .read(firebaseAnalyticsServiceProvider)
            .logEventUnawaited(name: AnalyticsEvent.timelineOpen);
        return null;
      },
      const [],
    );
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
          await Future<void>.delayed(const Duration(seconds: 1));
          ref.invalidate(postsStreamProvider);
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
                },
              ),
            ),
            state.when(
              data: (posts) => posts.isNotEmpty
                  ? AppListView(
                      posts: posts,
                      routerPath: RouterPath.timeLineDetail,
                      type: AppListViewType.timeline,
                      controller: scrollController,
                      categoryName: selectedCategoryName.isEmpty
                          ? null
                          : selectedCategoryName,
                      refresh: () {
                        ref
                          ..invalidate(
                            postsStreamProvider,
                          )
                          ..invalidate(blockListProvider);
                      },
                    )
                  : const SliverToBoxAdapter(child: AppEmpty()),
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: AppTabLoading.food(),
              ),
              error: (_, __) => SliverToBoxAdapter(
                child: AppErrorWidget(
                  onTap: () =>
                      ref.refresh(postsStreamProvider(selectedCategoryName)),
                ),
              ),
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
          shape: const CircleBorder(side: BorderSide()),
          onPressed: () async {
            await context
                .pushNamed(RouterPath.timeLinePost)
                .then((value) async {
              if (value != null) {
                ref
                  ..invalidate(postsStreamProvider)
                  ..invalidate(blockListProvider);
              }
            });
          },
          child: const Icon(Icons.add, size: 35),
        ),
      ),
    );
  }
}
