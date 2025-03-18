import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/admob/services/admob_open.dart';
import 'package:food_gram_app/core/admob/tracking/ad_tracking_permission.dart';
import 'package:food_gram_app/core/local/force_update_checker.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/purchase/services/revenue_cat_service.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/utils/helpers/dialog_helper.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_error_widget.dart';
import 'package:food_gram_app/ui/component/app_floating_button.dart';
import 'package:food_gram_app/ui/component/app_list_view.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TimeLineScreen extends HookConsumerWidget {
  const TimeLineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeMade = ref.watch(postHomeMadeStreamProvider);
    useEffect(
      () {
        AdTrackingPermission().requestTracking();
        ref
            .read(revenueCatServiceProvider.notifier)
            .initInAppPurchase()
            .then((isSubscribed) {
          final value = math.Random().nextInt(10);
          if (value == 0) {
            if (!isSubscribed) {
              AdmobOpen().loadAd();
            }
          }
        });
        ref.read(forceUpdateCheckerProvider.notifier).checkForceUpdate(
          openDialog: () {
            DialogHelper().forceUpdateDialog(context);
          },
        );
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
            RestaurantCategoryScreen(),
            FoodListView(
              state: homeMade,
              isRestaurant: false,
            ),
          ],
        ),
        floatingActionButton: AppFloatingButton(
          onTap: () async {
            await context
                .pushNamed(RouterPath.timeLinePost)
                .then((value) async {
              if (value != null) {
                ref
                  ..invalidate(postStreamProvider)
                  ..invalidate(postHomeMadeStreamProvider)
                  ..invalidate(blockListProvider);
              }
            });
          },
        ),
      ),
    );
  }
}

class RestaurantCategoryScreen extends HookConsumerWidget {
  const RestaurantCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategoryName = useState('');
    final postState =
        ref.watch(postStreamByCategoryProvider(selectedCategoryName.value));
    final l10n = L10n.of(context);
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: foodCategory.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: () {
                    selectedCategoryName.value = '';
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: selectedCategoryName.value.isEmpty
                          ? Colors.black
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(),
                    ),
                    child: Row(
                      children: [
                        Text('🍽️', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 4),
                        Text(
                          l10n.foodCategoryAll,
                          style: TextStyle(
                            color: selectedCategoryName.value.isEmpty
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final entry = foodCategory.entries.elementAt(index - 1);
              final categoryName = entry.key;
              final foodEmojis = entry.value;
              final displayIcon = foodEmojis.isNotEmpty ? foodEmojis[0] : '🍽️';
              final isSelected = selectedCategoryName.value == categoryName;
              return GestureDetector(
                onTap: () {
                  selectedCategoryName.value = categoryName;
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(),
                  ),
                  child: Row(
                    children: [
                      Text(displayIcon, style: TextStyle(fontSize: 24)),
                      Gap(4),
                      Text(
                        l10nCategory(categoryName, l10n),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: FoodListView(
            state: postState,
            isRestaurant: true,
          ),
        ),
      ],
    );
  }
}

class FoodListView extends ConsumerWidget {
  const FoodListView({
    required this.state,
    required this.isRestaurant,
    super.key,
  });

  final AsyncValue<List<Map<String, dynamic>>> state;
  final bool isRestaurant;

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
              isTimeLine: isRestaurant,
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

String l10nCategory(String categoryName, L10n l10n) {
  String displayName;
  switch (categoryName) {
    case 'Noodles':
      displayName = l10n.foodCategoryNoodles;
      break;
    case 'Meat':
      displayName = l10n.foodCategoryMeat;
      break;
    case 'Fast Food':
      displayName = l10n.foodCategoryFastFood;
      break;
    case 'Rice Dishes':
      displayName = l10n.foodCategoryRiceDishes;
      break;
    case 'Seafood':
      displayName = l10n.foodCategorySeafood;
      break;
    case 'Bread':
      displayName = l10n.foodCategoryBread;
      break;
    case 'Sweets & Snacks':
      displayName = l10n.foodCategorySweetsAndSnacks;
      break;
    case 'Fruits':
      displayName = l10n.foodCategoryFruits;
      break;
    case 'Vegetables':
      displayName = l10n.foodCategoryVegetables;
      break;
    case 'Beverages':
      displayName = l10n.foodCategoryBeverages;
      break;
    case 'Others':
      displayName = l10n.foodCategoryOthers;
      break;
    default:
      displayName = categoryName;
  }

  return displayName;
}
