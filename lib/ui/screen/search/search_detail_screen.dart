import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:go_router/go_router.dart';

class SearchDetailScreen extends ConsumerWidget {
  const SearchDetailScreen({
    required this.posts,
    super.key,
  });

  final List<Posts> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.watch(supabaseProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final itemImageUrl = supabase.storage
                .from('food')
                .getPublicUrl(posts[index].foodImage);
            final restaurantName = posts[index].restaurant;
            return GestureDetector(
              onTap: () {
                context.pushNamed(
                  RouterPath.searchRestaurantReview,
                  extra: posts[index],
                );
              },
              child: Stack(
                children: [
                  Card(
                    elevation: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: itemImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: index.isEven ? 200 : 300,
                        placeholder: (context, url) => Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.35,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        restaurantName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        softWrap: false,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
