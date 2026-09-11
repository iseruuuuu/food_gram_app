import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/post/analyzer/record_food_traits_analyzer.dart';
import 'package:food_gram_app/core/supabase/post/repository/detail_post_repository.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/food_tag_icon.dart';
import 'package:food_gram_app/ui/screen/record/components/record_post_image.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

/// 記録タブ：最近の思い出（最新の投稿カード）
class RecordTodayMemoriesSection extends StatelessWidget {
  const RecordTodayMemoriesSection({
    required this.posts,
    super.key,
  });

  final List<Posts> posts;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF161616) : Colors.white;
    final latestPost = recordLatestPost(posts);
    if (latestPost == null) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.myMapRecord.todayMemoriesTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          _LatestMemoryCard(post: latestPost),
        ],
      ),
    );
  }
}

class _LatestMemoryCard extends StatelessWidget {
  const _LatestMemoryCard({required this.post});

  final Posts post;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final dateText = DateFormat('yyyy/M/d', localeTag).format(post.createdAt);
    final title =
        post.foodName.trim().isEmpty ? post.restaurant : post.foodName;
    final restaurant = post.restaurant.trim();
    final area = recordPostAreaLabel(post);
    final locationParts = <String>[
      if (restaurant.isNotEmpty) restaurant,
      if (area != null && area.isNotEmpty && area != restaurant) area,
    ];
    final location = locationParts.join(' · ');
    final comment = post.comment.trim();
    const imageSize = 130.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecordPostImage(post: post, size: imageSize),
        const Gap(12),
        Expanded(
          child: SizedBox(
            height: imageSize,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                const Gap(4),
                FittedBox(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                ),
                const Gap(4),
                Text(
                  '📍$location',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : Colors.black,
                  ),
                ),
                if (comment.isNotEmpty) ...[
                  const Gap(4),
                  Text(
                    comment,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 投稿一覧から最新の1件を返す
Posts? recordLatestPost(List<Posts> posts) {
  if (posts.isEmpty) {
    return null;
  }
  final sorted = [...posts]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sorted.first;
}

/// 最近の記録（過去の思い出）セクション
class RecordRecentSection extends ConsumerWidget {
  const RecordRecentSection({
    required this.cardColor,
    required this.pastPosts,
    super.key,
  });

  final Color cardColor;
  final List<Posts> pastPosts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    if (pastPosts.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.myMapRecord.pastMemoriesLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(12),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: pastPosts.length,
              separatorBuilder: (_, __) => const Gap(12),
              itemBuilder: (context, index) {
                final post = pastPosts[index];
                return _PastMemoryCard(
                  post: post,
                  onTap: () => _openRecordPost(
                    context: context,
                    ref: ref,
                    posts: pastPosts,
                    index: index,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void _openRecordPost({
  required BuildContext context,
  required WidgetRef ref,
  required List<Posts> posts,
  required int index,
}) {
  if (index < 0) {
    return;
  }
  EasyDebounce.debounce(
    'record_past_memory_tap',
    const Duration(milliseconds: 200),
    () async {
      if (!context.mounted) {
        return;
      }
      final result = await ref
          .read(detailPostRepositoryProvider.notifier)
          .getPostData(posts, index);
      await result.whenOrNull(
        success: (model) async {
          if (!context.mounted) {
            return;
          }
          await context.pushNamed(
            RouterPath.myProfileDetail,
            extra: model,
          );
        },
      );
    },
  );
}

class _PastMemoryCard extends StatelessWidget {
  const _PastMemoryCard({
    required this.post,
    required this.onTap,
  });

  final Posts post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final dateText = DateFormat('yyyy/M/d', localeTag).format(post.createdAt);
    final foodName = post.foodName.trim();
    final restaurant = post.restaurant.trim();
    final tags = parseFoodTagIds(post.foodTag).take(3).toList();
    final price = post.formattedPriceDisplay;
    const imageSize = 130.0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 300,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RecordPostImage(
                post: post,
                size: imageSize,
                borderRadius: 14,
              ),
              const Gap(10),
              Expanded(
                child: SizedBox(
                  height: imageSize,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      if (foodName.isNotEmpty) ...[
                        const Gap(4),
                        Text(
                          foodName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      if (restaurant.isNotEmpty) ...[
                        const Gap(4),
                        Text(
                          restaurant,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (price.isNotEmpty || tags.isNotEmpty)
                        Row(
                          children: [
                            if (price.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                  right: tags.isEmpty ? 0 : 6,
                                ),
                                child: Text(
                                  price,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            for (final tag in tags) ...[
                              FoodTagIcon(
                                tagId: tag,
                                size: 20,
                                textStyle: const TextStyle(fontSize: 20),
                              ),
                              const Gap(4),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
