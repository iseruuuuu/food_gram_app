import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/data/supabase/post_stream.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_error_widget.dart';
import 'package:food_gram_app/ui/component/app_floating_button.dart';
import 'package:food_gram_app/ui/component/app_list_view.dart';
import 'package:go_router/go_router.dart';

class TimeLineScreen extends ConsumerWidget {
  const TimeLineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = ref.watch(postStreamProvider);
    final homeMade = ref.watch(postHomeMadeStreamProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(55),
          child: AppBar(
            surfaceTintColor: Colors.transparent,
            forceMaterialTransparency: true,
            elevation: 0,
            bottom: const TabBar(
              indicatorWeight: 1,
              automaticIndicatorColorAdjustment: false,
              labelStyle: TextStyle(fontSize: 12),
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.dinner_dining),
                  text: 'レストラン',
                  height: 50,
                ),
                Tab(
                  icon: Icon(Icons.restaurant_menu),
                  text: '自炊',
                  height: 50,
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            FoodListView(state: restaurant),
            FoodListView(state: homeMade),
          ],
        ),
        floatingActionButton: AppFloatingButton(
          onTap: () async {
            await context
                .pushNamed(RouterPath.timeLinePost)
                .then((value) async {
              if (value != null) {
                ref.invalidate(postStreamProvider);
              }
            });
          },
        ),
      ),
    );
  }
}

class FoodListView extends ConsumerWidget {
  const FoodListView({
    required this.state,
    super.key,
  });

  final AsyncValue<List<Map<String, dynamic>>> state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return state.when(
      data: (data) => Column(
        children: [
          Expanded(
            child: AppListView(
              data: data,
              routerPath: RouterPath.timeLineDetailPost,
              refresh: () {
                ref
                  ..invalidate(postStreamProvider)
                  ..invalidate(postHomeMadeStreamProvider)
                  ..invalidate(blockListProvider);
              },
              isTimeLine: true,
            ),
          ),
        ],
      ),
      error: (_, __) => AppErrorWidget(
        onTap: () => ref.refresh(postStreamProvider),
      ),
      loading: () => Center(
        child: Assets.image.loading.image(
          fit: BoxFit.cover,
          width: 100,
          height: 100,
        ),
      ),
    );
  }
}
