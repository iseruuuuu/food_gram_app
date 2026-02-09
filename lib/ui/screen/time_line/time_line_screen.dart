import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_error_widget.dart';
import 'package:food_gram_app/ui/component/common/app_list_view.dart';
import 'package:food_gram_app/ui/component/common/app_skeleton.dart';
import 'package:food_gram_app/ui/screen/tab/tab_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TimeLineScreen extends HookConsumerWidget {
  const TimeLineScreen({super.key});

  static const int _tabIndex = 1; // フードタブ

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategoryName = useState('');
    final categoriesData = ref.watch<List<CategoryData>>(categoriesProvider);
    final state = ref.watch(postsStreamProvider(selectedCategoryName.value));
    final tabController =
        useTabController(initialLength: categoriesData.length);
    final scrollController = useScrollController();
    final scrollToTopRequested = ref.watch(scrollToTopForTabProvider);

    /// スクロールを先頭へ戻すためのHooks
    useEffect(
      () {
        if (scrollToTopRequested != _tabIndex) {
          return null;
        }
        void scrollToTop() {
          if (!scrollController.hasClients) {
            return;
          }
          scrollController
              .animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          )
              .then((_) {
            ref.read(scrollToTopForTabProvider.notifier).state = null;
          });
        }

        if (scrollController.hasClients) {
          scrollToTop();
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) => scrollToTop());
        }
        return null;
      },
      [scrollToTopRequested],
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          surfaceTintColor: Colors.transparent,
          forceMaterialTransparency: true,
          elevation: 0,
        ),
      ),
      body: RefreshIndicator(
        color: Colors.black,
        backgroundColor: Colors.white,
        onRefresh: () async {
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
              child: Column(
                children: [
                  TabBar(
                    tabAlignment: TabAlignment.start,
                    controller: tabController,
                    indicatorWeight: 3,
                    isScrollable: true,
                    automaticIndicatorColorAdjustment: false,
                    unselectedLabelColor: Colors.grey,
                    labelColor: Colors.black,
                    indicatorColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.tab,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    padding: EdgeInsets.zero,
                    tabs: categoriesData.map((category) {
                      return Tab(
                        icon: Text(
                          category.displayIcon,
                          style: const TextStyle(fontSize: 30),
                        ),
                      );
                    }).toList(),
                    onTap: (index) {
                      final category = categoriesData[index];
                      selectedCategoryName.value =
                          category.isAllCategory ? '' : category.name;
                    },
                  ),
                ],
              ),
            ),
            state.when(
              data: (posts) => posts.isNotEmpty
                  ? AppListView(
                      posts: posts,
                      routerPath: RouterPath.timeLineDetail,
                      type: AppListViewType.timeline,
                      controller: scrollController,
                      refresh: () {
                        ref
                          ..invalidate(
                            postsStreamProvider,
                          )
                          ..invalidate(blockListProvider);
                      },
                    )
                  : const SliverToBoxAdapter(child: AppEmpty()),
              loading: () =>
                  const SliverToBoxAdapter(child: AppListViewSkeleton()),
              error: (_, __) => SliverToBoxAdapter(
                child: AppErrorWidget(
                  onTap: () => ref
                      .refresh(postsStreamProvider(selectedCategoryName.value)),
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
          foregroundColor: Colors.black,
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
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 35,
          ),
        ),
      ),
    );
  }
}
