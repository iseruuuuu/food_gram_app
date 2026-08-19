import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/gen/assets.gen.dart';

/// 記録タブで使う投稿サムネイル
class RecordPostImage extends ConsumerWidget {
  const RecordPostImage({
    required this.post,
    required this.size,
    this.borderRadius = 12,
    super.key,
  });

  final Posts post;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storageKey = post.firstFoodImage;
    final imageUrl = storageKey.isEmpty
        ? null
        : ref
            .read(supabaseProvider)
            .storage
            .from('food')
            .getPublicUrl(storageKey);
    final placeholder = ColoredBox(
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      child: Icon(
        Icons.fastfood,
        color: isDark ? Colors.white54 : Colors.black38,
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl == null
            ? placeholder
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => ColoredBox(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
                errorWidget: (_, __, ___) => Image.asset(
                  isDark
                      ? Assets.image.emptyDark.path
                      : Assets.image.empty.path,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}
