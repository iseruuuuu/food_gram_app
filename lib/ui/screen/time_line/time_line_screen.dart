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
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TimeLineScreen extends HookConsumerWidget {
  const TimeLineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategoryName = useState('');
    final postState =
        ref.watch(postStreamByCategoryProvider(selectedCategoryName.value));
    final categoriesData = ref.watch<List<CategoryData>>(categoriesProvider);
    final tabController =
        useTabController(initialLength: categoriesData.length);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(backgroundColor: Colors.white),
      ),
      body: RefreshIndicator(
        color: Colors.black,
        onRefresh: () async {
          await Future<void>.delayed(const Duration(seconds: 1));
          ref.invalidate(
            postStreamByCategoryProvider(selectedCategoryName.value),
          );
        },
        child: CustomScrollView(
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
            if (postState.hasValue)
              postState.value!.isNotEmpty
                  ? AppListView(
                      data: postState.value!,
                      routerPath: RouterPath.timeLineDetail,
                      refresh: () {
                        ref
                          ..invalidate(postStreamProvider)
                          ..invalidate(blockListProvider);
                      },
                    )
                  : const SliverToBoxAdapter(child: AppEmpty()),
            if (postState.isLoading)
              const SliverToBoxAdapter(
                child: AppListViewSkeleton(),
              ),
            if (postState.hasError)
              SliverToBoxAdapter(
                child: AppErrorWidget(
                  onTap: () => ref.refresh(postStreamProvider),
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
                  ..invalidate(postStreamProvider)
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
