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
    // 複数画像がある場合は最初の画像のみ表示
    final firstImage = post.firstFoodImage;
    final itemImageUrl = ref
        .read(supabaseProvider)
        .storage
        .from('food')
        .getPublicUrl(firstImage);
    final restaurantName = post.restaurant;
    final hasMultipleImages = post.foodImageList.length > 1;
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
          // 複数画像がある場合のアイコン
          if (hasMultipleImages)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.collections,
                  color: Colors.white,
                  size: 16,
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
