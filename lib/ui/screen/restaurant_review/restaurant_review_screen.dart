import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/ui/component/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/app_profile_image.dart';
import 'package:gap/gap.dart';
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          posts.restaurant,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: AsyncValueSwitcher(
        asyncValue: reviewsAsync,
        onErrorTap: () async => ref.refresh(
          restaurantReviewsProvider(
            lat: posts.lat,
            lng: posts.lng,
          ),
        ),
        onData: (reviews) => RefreshIndicator(
          onRefresh: () async => ref.refresh(
            restaurantReviewsProvider(
              lat: posts.lat,
              lng: posts.lng,
            ),
          ),
          child: ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final model = reviews[index];
              return Card(
                color: Colors.white54,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppProfileImage(
                            imagePath: model.users.image,
                            radius: 28,
                          ),
                          Gap(8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                model.users.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Gap(8),
                      Text(
                        model.posts.foodName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gap(4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          model.posts.comment,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
