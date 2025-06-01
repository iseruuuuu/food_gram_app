import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/core/theme/style/restaurant_review_style.dart';
import 'package:food_gram_app/ui/component/app_review_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RestaurantReviewScreen extends ConsumerWidget {
  const RestaurantReviewScreen({
    required this.posts,
    super.key,
  });

  final Posts posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(
      restaurantReviewsProvider(
        lat: posts.lat,
        lng: posts.lng,
      ),
    );
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: GestureDetector(
            onTap: context.pop,
            child: const Icon(Icons.close, size: 30),
          ),
          title: Text(
            posts.restaurant,
            style: RestaurantReviewStyle.restaurant(),
          ),
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
            tabs: const <Widget>[
              Tab(
                icon: Icon(Icons.photo_camera_back, size: 30),
                height: 38,
              ),
              Tab(
                icon: Icon(Icons.chat_bubble_outline, size: 30),
                height: 38,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ReviewImageWidget(
              reviewsAsync: reviewsAsync,
              posts: posts,
            ),
            ReviewWidget(
              reviewsAsync: reviewsAsync,
              posts: posts,
            ),
          ],
        ),
      ),
    );
  }
}
