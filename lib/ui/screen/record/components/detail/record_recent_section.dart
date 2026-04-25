import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';

/// 最近の記録セクション
class RecordRecentSection extends StatelessWidget {
  const RecordRecentSection({
    required this.cardColor,
    required this.mutedColor,
    required this.latestPosts,
    super.key,
  });

  final Color cardColor;
  final Color mutedColor;
  final List<Posts> latestPosts;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.myMapRecord.recentTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(12),
          if (latestPosts.isEmpty)
            Text(
              t.myMapRecord.noPostsYet,
              style: TextStyle(color: mutedColor),
            )
          else
            Column(
              children: latestPosts
                  .map((post) => RecordRecentListTile(post: post))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

/// 記録タブ：最近の記録1行
class RecordRecentListTile extends ConsumerWidget {
  const RecordRecentListTile({required this.post, super.key});

  final Posts post;

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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 74,
              height: 74,
              child: imageUrl == null
                  ? ColoredBox(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      child: Icon(
                        Icons.fastfood,
                        color: isDark ? Colors.white54 : Colors.black38,
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => ColoredBox(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: isDark ? Colors.white54 : Colors.black38,
                        ),
                      ),
                    ),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.foodName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const Gap(2),
                Text(
                  post.restaurant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.favorite, size: 18, color: Color(0xFFEF4444)),
              const Gap(2),
              Text(
                '${post.heart}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
