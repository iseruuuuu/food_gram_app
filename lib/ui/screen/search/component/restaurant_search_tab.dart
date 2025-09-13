import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RestaurantSearchTab extends HookConsumerWidget {
  const RestaurantSearchTab({
    required this.categoriesData,
    required this.nearbyPosts,
    required this.supabase,
    super.key,
  });

  final List<CategoryData> categoriesData;
  final AsyncValue<List<Posts>> nearbyPosts;
  final SupabaseClient supabase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (ref.watch(locationProvider).value?.latitude != 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.nearbyRestaurants,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  TextButton(
                    onPressed: nearbyPosts.hasValue
                        ? () {
                            final posts = nearbyPosts.value!;
                            context.pushNamed(
                              RouterPath.searchDetail,
                              extra: posts,
                            );
                          }
                        : null,
                    child: Text(
                      l10n.seeMore,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            if (ref.watch(locationProvider).value?.latitude != 0)
              SizedBox(
                width: MediaQuery.sizeOf(context).width,
                height: 100,
                child: nearbyPosts.when(
                  data: (posts) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final imageUrl = supabase.storage
                            .from('food')
                            .getPublicUrl(post.foodImage);
                        return GestureDetector(
                          onTap: () {
                            context.pushNamed(
                              RouterPath.searchRestaurantReview,
                              extra: post,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: AppListViewSkeleton.new,
                  error: (error, stack) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.grey),
                  ),
                ),
              ),
            ...categoriesData.where((category) => !category.isAllCategory).map(
              (category) {
                final selectedCategoryName = useState(category.name);
                final state =
                    ref.watch(postsStreamProvider(selectedCategoryName.value));
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${category.displayIcon}'
                          '${getLocalizedCategoryName(category.name, context)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        TextButton(
                          onPressed: state.hasValue
                              ? () {
                                  final posts = state.value!.toList();
                                  context.pushNamed(
                                    RouterPath.searchDetail,
                                    extra: posts,
                                  );
                                }
                              : null,
                          child: Text(
                            l10n.seeMore,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    state.when(
                      data: (posts) {
                        return SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: posts.length >= 10 ? 10 : posts.length,
                            itemBuilder: (context, index) {
                              final post = posts[index];
                              final imageUrl = supabase.storage
                                  .from('food')
                                  .getPublicUrl(post.foodImage);
                              return GestureDetector(
                                onTap: () {
                                  context.pushNamed(
                                    RouterPath.searchRestaurantReview,
                                    extra: posts[index],
                                  );
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      loading: AppListViewSkeleton.new,
                      error: (error, stack) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, color: Colors.grey),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
