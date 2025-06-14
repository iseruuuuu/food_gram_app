import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/app_profile_image.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReviewWidget extends ConsumerWidget {
  const ReviewWidget({
    required this.reviewsAsync,
    required this.posts,
    super.key,
  });

  final AsyncValue<Result<List<Model>, Exception>> reviewsAsync;
  final Posts posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueSwitcher(
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
        child: reviews.when(
          success: (data) {
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final model = data[index];
                return Card(
                  color: Colors.white70,
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
                            const Gap(8),
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
                        const Gap(8),
                        Text(
                          model.posts.foodName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            model.posts.comment,
                            style: const TextStyle(
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
            );
          },
          failure: (_) {
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class ReviewImageWidget extends ConsumerWidget {
  const ReviewImageWidget({
    required this.reviewsAsync,
    required this.posts,
    super.key,
  });

  final AsyncValue<Result<List<Model>, Exception>> reviewsAsync;
  final Posts posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width / 3;
    final supabase = ref.watch(supabaseProvider);
    return AsyncValueSwitcher(
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
        child: reviews.when(
          success: (data) {
            return CustomScrollView(
              slivers: [
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    childCount: data.length,
                    (context, index) {
                      final model = data[index];
                      final foodImageUrl = supabase.storage
                          .from('food')
                          .getPublicUrl(model.posts.foodImage);
                      return GestureDetector(
                        onTap: () {
                          context.pushNamed(
                            RouterPath.timeLineDetail,
                            extra: model,
                          );
                        },
                        child: Card(
                          elevation: 10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: foodImageUrl,
                              fit: BoxFit.cover,
                              width: screenWidth,
                              height: screenWidth,
                              placeholder: (context, url) => Container(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          failure: (_) {
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
