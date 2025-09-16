import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';

class AppCardListItem extends ConsumerWidget {
  const AppCardListItem({
    required this.post,
    required this.index,
    required this.onTap,
    super.key,
  });

  final Posts post;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemImageUrl = ref
        .read(supabaseProvider)
        .storage
        .from('food')
        .getPublicUrl(post.foodImage);
    final restaurantName = post.restaurant;
    return GestureDetector(
      onTap: onTap,
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
  }
}
