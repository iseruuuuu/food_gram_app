import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/screen/search/component/restaurant_search.dart';
import 'package:food_gram_app/ui/screen/search/component/user_search.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchScreen extends HookConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesData = ref.watch(categoriesProvider);
    final l10n = L10n.of(context);
    final nearbyPosts = ref.watch(getNearByPostsProvider);
    final supabase = ref.watch(supabaseProvider);
    final tabController = useTabController(initialLength: 2);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          forceMaterialTransparency: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          toolbarHeight: 0,
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
            controller: tabController,
            tabs: [
              Tab(text: l10n.searchRestaurantTitle),
              const Tab(text: 'ユーザー検索'),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            RestaurantSearchTab(
              categoriesData: categoriesData,
              nearbyPosts: nearbyPosts,
              supabase: supabase,
            ),
            const UserSearchTab(),
          ],
        ),
      ),
    );
  }
}
