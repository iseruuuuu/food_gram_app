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
          Row(
            children: [
              const Gap(6),
              Text(
                t.myMapRecord.todayMemoriesTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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

/// 先頭カードに出す投稿（最近の1件）
List<Posts> recordFeaturedMemoryPosts(List<Posts> posts) {
  final latest = recordLatestPost(posts);
  return latest == null ? const [] : [latest];
}

/// 最近の記録（過去の思い出）セクション
class RecordRecentSection extends ConsumerWidget {
  const RecordRecentSection({
    required this.cardColor,
    required this.pastPosts,
    required this.onSeeMore,
    super.key,
  });

  final Color cardColor;
  final List<Posts> pastPosts;
  final VoidCallback onSeeMore;

  static const _previewCount = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (pastPosts.isEmpty) {
      return const SizedBox.shrink();
    }
    final previewPosts = pastPosts.take(_previewCount).toList();
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
          Row(
            children: [
              Expanded(
                child: Text(
                  t.myMapRecord.pastMemoriesLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onSeeMore,
                child: Row(
                  children: [
                    Text(
                      t.seeMore,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white60 : Colors.black45,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(12),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: previewPosts.length,
              separatorBuilder: (_, __) => const Gap(12),
              itemBuilder: (context, index) {
                final post = previewPosts[index];
                return _PastMemoryCard(
                  post: post,
                  onTap: () => _openRecordPost(
                    context: context,
                    ref: ref,
                    posts: pastPosts,
                    index: pastPosts.indexWhere((item) => item.id == post.id),
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

/// 記録タブ：過去の思い出1行（一覧画面用）
class RecordRecentListTile extends StatelessWidget {
  const RecordRecentListTile({
    required this.post,
    this.onTap,
    super.key,
  });

  final Posts post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final dateText = DateFormat('yyyy/M/d', localeTag).format(post.createdAt);
    final foodName = post.foodName.trim();
    final restaurant = post.restaurant.trim();
    final tags = parseFoodTagIds(post.foodTag).take(3).toList();
    final price = post.formattedPriceDisplay;
    final card = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1D1D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFECECEC),
        ),
      ),
      child: Row(
        children: [
          RecordPostImage(post: post, size: 72),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                if (foodName.isNotEmpty) ...[
                  const Gap(3),
                  Text(
                    foodName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
                if (restaurant.isNotEmpty) ...[
                  const Gap(3),
                  Text(
                    restaurant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (price.isNotEmpty || tags.isNotEmpty) ...[
                  const Gap(4),
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
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      for (final tag in tags) ...[
                        FoodTagIcon(
                          tagId: tag,
                          size: 16,
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                        const Gap(4),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
    if (onTap == null) {
      return card;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: card,
      ),
    );
  }
}
