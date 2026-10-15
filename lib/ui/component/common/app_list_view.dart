import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/admob/services/admob_rectangle_banner.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/timeline_detail_extra.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/detail_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/providers/subscribed_users_provider.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/my_profile_post_sort.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_translatable_text.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppListView extends HookConsumerWidget {
  const AppListView({
    required this.posts,
    required this.routerPath,
    required this.refresh,
    required this.type,
    required this.controller,
    this.categoryName,
    this.sortOrder,
    super.key,
  });

  final List<Posts> posts;
  final String routerPath;
  final VoidCallback refresh;
  final AppListViewType type;
  final ScrollController controller;
  final String? categoryName;
  final MyProfilePostSortOrder? sortOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width / 3;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final supabase = ref.watch(supabaseProvider);
    final impressedPostIds = useRef<Set<int>>({});
    if (posts.isEmpty) {
      return const SliverToBoxAdapter(child: AppEmpty());
    }
    final rowCount = (posts.length / 3).ceil();
    const adEvery = 30;
    final adRowInterval = (adEvery / 3).floor();
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final isAdRow = (index + 1) % (adRowInterval + 1) == 0;
          if (isAdRow) {
            return SizedBox(
              width: double.infinity,
              child: Center(
                child: RectangleBanner(id: 'row_$index'),
              ),
            );
          }
          final actualRowIndex = index - (index ~/ (adRowInterval + 1));
          final startIndex = actualRowIndex * 3;
          return Row(
            children: List.generate(3, (gridIndex) {
              final itemIndex = startIndex + gridIndex;
              if (itemIndex >= posts.length) {
                return const Expanded(child: SizedBox());
              }
              final post = posts[itemIndex];
              final postId = post.id;
              if (type == AppListViewType.timeline &&
                  impressedPostIds.value.add(postId)) {
                ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
                  name: AnalyticsEvent.timelinePostImpression,
                  parameters: {AnalyticsParam.postId: postId},
                );
              }
              // 複数画像がある場合は最初の画像のみ表示（Storage キーは正規化済み）
              final storageKey = post.firstFoodImage;
              final itemImageUrl = storageKey.isEmpty
                  ? ''
                  : supabase.storage.from('food').getPublicUrl(storageKey);
              final postUserId = post.userId as String?;
              final isSubscribed = ref.watch(isSubscribedProvider(postUserId));
              final hasMultipleImages = post.foodImageList.length > 1;
              final showStarBadge =
                  (sortOrder == MyProfilePostSortOrder.starHigh ||
                          sortOrder == MyProfilePostSortOrder.starLow) &&
                      post.star > 0;
              final showHeartBadge =
                  sortOrder == MyProfilePostSortOrder.likesHigh &&
                      post.heart > 0;
              return Expanded(
                key: ValueKey(postId),
                child: GestureDetector(
                  onTap: () {
                    EasyDebounce.debounce(
                      'click_detail',
                      const Duration(milliseconds: 200),
                      () async {
                        if (type == AppListViewType.timeline) {
                          ref
                              .read(firebaseAnalyticsServiceProvider)
                              .logEventUnawaited(
                            name: AnalyticsEvent.timelinePostOpen,
                            parameters: {AnalyticsParam.postId: postId},
                          );
                        }
                        final postResult = await ref
                            .read(detailPostRepositoryProvider.notifier)
                            .getPostData(posts, itemIndex);
                        await postResult.whenOrNull(
                          success: (model) async {
                            final extra = (type == AppListViewType.timeline &&
                                    routerPath == RouterPath.timeLineDetail &&
                                    categoryName != null &&
                                    categoryName!.isNotEmpty)
                                ? TimelineDetailExtra(
                                    model: model,
                                    categoryName: categoryName,
                                  )
                                : model;
                            final result = await context.pushNamed(
                              routerPath,
                              extra: extra,
                            );
                            if (result != null) {
                              refresh();
                            }
                          },
                        );
                      },
                    );
                  },
                  child: SizedBox(
                    width: screenWidth,
                    height: screenWidth,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSubscribed
                                ? AppTheme.primaryOrange
                                : AppTheme.dividerOf(context),
                            width: isSubscribed ? 1.5 : 0.8,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: storageKey.isEmpty
                                    ? ColoredBox(
                                        color: isDark
                                            ? Colors.grey.shade900
                                            : Colors.grey.shade200,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: itemImageUrl,
                                        fit: BoxFit.cover,
                                        width: screenWidth,
                                        height: screenWidth,
                                        placeholder: (context, url) =>
                                            ColoredBox(
                                          color: AppTheme.cardOf(context),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          isDark
                                              ? Assets.image.emptyDark.path
                                              : Assets.image.empty.path,
                                          fit: BoxFit.cover,
                                          width: screenWidth,
                                          height: screenWidth,
                                        ),
                                      ),
                              ),
                              if (post.restaurant.isNotEmpty)
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    child: AppTranslatableText(
                                      post.restaurant,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      enableCopy: false,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
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
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.collections,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              if (showStarBadge || showHeartBadge)
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.65,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          showStarBadge
                                              ? Icons.star_rounded
                                              : Icons.favorite_rounded,
                                          color: AppTheme.primaryOrange,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          showStarBadge
                                              ? post.star.toStringAsFixed(1)
                                              : '${post.heart}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
        childCount: rowCount + (rowCount ~/ adRowInterval),
      ),
    );
  }
}

/// Viewごとに詳細画面の取得方法が異なるため設定する
enum AppListViewType {
  timeline,
  myprofile,
  profile,
  stored,
}
