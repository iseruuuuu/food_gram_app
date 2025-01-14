import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/data/admob/admob_open.dart';
import 'package:food_gram_app/core/data/admob/app_tracking_transparency.dart';
import 'package:food_gram_app/core/data/purchase/purchase_provider.dart';
import 'package:food_gram_app/core/data/supabase/block_list.dart';
import 'package:food_gram_app/core/data/supabase/post_stream.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_error_widget.dart';
import 'package:food_gram_app/ui/component/app_floating_button.dart';
import 'package:food_gram_app/ui/component/app_list_view.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TimeLineScreen extends HookConsumerWidget {
  const TimeLineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = ref.watch(postStreamProvider);
    final homeMade = ref.watch(postHomeMadeStreamProvider);
    useEffect(
      () {
        loadAppTrackingTransparency();
        ref
            .read(purchaseProvider.notifier)
            .initInAppPurchase()
            .then((isSubscribed) {
          final value = math.Random().nextInt(10);
          if (value == 10) {
            if (!isSubscribed) {
              AdmobOpen().loadAd();
            }
          }
        });
        return null;
      },
      [],
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            surfaceTintColor: Colors.transparent,
            forceMaterialTransparency: true,
            elevation: 0,
            bottom: TabBar(
              indicatorWeight: 1,
              automaticIndicatorColorAdjustment: false,
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              enableFeedback: true,
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.dinner_dining, size: 30),
                  height: 38,
                ),
                Tab(
                  icon: Icon(Icons.restaurant_menu, size: 30),
                  height: 38,
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
              routerPath: RouterPath.timeLineDetail,
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
