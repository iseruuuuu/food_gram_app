import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/admob/services/admob_rectangle_banner.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/timeline_detail_extra.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/detail_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/providers/subscribed_users_provider.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
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
    super.key,
  });

  final List<Posts> posts;
  final String routerPath;
  final VoidCallback refresh;
  final AppListViewType type;
  final ScrollController controller;
  final String? categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width / 3;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final supabase = ref.watch(supabaseProvider);
    if (posts.isEmpty) {
      return const SliverToBoxAdapter(child: AppEmpty());
    }
    final rowCount = (posts.length / 3).ceil();
    const adEvery = 30;
    final adRowInterval = (adEvery / 3).floor();
    const options = LiveOptions(
      showItemInterval: Duration(milliseconds: 150),
      showItemDuration: Duration(milliseconds: 240),
      visibleFraction: 0.01,
    );
    return LiveSliverList.options(
      options: options,
      controller: controller,
      itemCount: rowCount + (rowCount ~/ adRowInterval),
      itemBuilder: (context, index, animation) {
        final isAdRow = (index + 1) % (adRowInterval + 1) == 0;
        Widget rowWidget;
        if (isAdRow) {
          rowWidget = SizedBox(
            width: double.infinity,
            child: Center(
              child: RectangleBanner(id: 'row_$index'),
            ),
          );
        } else {
          final actualRowIndex = index - (index ~/ (adRowInterval + 1));
          final startIndex = actualRowIndex * 3;
          rowWidget = Row(
            children: List.generate(3, (gridIndex) {
              final itemIndex = startIndex + gridIndex;
              if (itemIndex >= posts.length) {
                return const Expanded(child: SizedBox());
              }
              // 複数画像がある場合は最初の画像のみ表示
              final firstImage = posts[itemIndex].firstFoodImage;
              final itemImageUrl =
                  supabase.storage.from('food').getPublicUrl(firstImage);
              final postUserId = posts[itemIndex].userId as String?;
              final isSubscribed = ref.watch(isSubscribedProvider(postUserId));
              final hasMultipleImages =
                  posts[itemIndex].foodImageList.length > 1;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    EasyDebounce.debounce(
                      'click_detail',
                      const Duration(milliseconds: 200),
                      () async {
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Card(
                              elevation: isSubscribed ? 0 : 10,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  isSubscribed ? 0 : 10,
                                ),
                                child: firstImage.isEmpty
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
                                        placeholder: (context, url) => Container(
                                          color: Colors.white,
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
                            ),
                          ),
                          if (isSubscribed)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  Assets.image.frame.path,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          if (posts[itemIndex].restaurant.isNotEmpty)
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
                                child: Text(
                                  posts[itemIndex].restaurant,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
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
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0,
            end: 1,
          ).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: rowWidget,
          ),
        );
      },
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
