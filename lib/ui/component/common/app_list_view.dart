import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/admob/services/admob_rectangle_banner.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/detail_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/providers/subscribed_users_provider.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppListView extends HookConsumerWidget {
  const AppListView({
    required this.posts,
    required this.routerPath,
    required this.refresh,
    required this.type,
    this.controller,
    super.key,
  });

  final List<Posts> posts;
  final String routerPath;
  final VoidCallback refresh;
  final AppListViewType type;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width / 3;
    final supabase = ref.watch(supabaseProvider);
    final subscribedUsersAsync = ref.watch(subscribedUsersProvider);
    if (posts.isEmpty) {
      return const SliverToBoxAdapter(child: AppEmpty());
    }
    final rowCount = (posts.length / 3).ceil();
    const adEvery = 30;
    final adRowInterval = (adEvery / 3).floor();
    const options = LiveOptions(
      showItemInterval: Duration(milliseconds: 200),
      showItemDuration: Duration(milliseconds: 300),
      visibleFraction: 0.01,
    );
    return LiveSliverList.options(
      options: options,
      controller: controller ?? ScrollController(),
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
              final itemImageUrl = supabase.storage
                  .from('food')
                  .getPublicUrl(posts[itemIndex].foodImage);
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
                            final result = await context.pushNamed(
                              routerPath,
                              extra: model,
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
                      child: subscribedUsersAsync.when(
                        data: (subscribedUsers) {
                          final postUserId = posts[itemIndex].userId as String?;
                          final isSubscribed = postUserId != null &&
                              subscribedUsers.contains(postUserId);
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: Card(
                                  elevation: isSubscribed ? 0 : 10,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      isSubscribed ? 0 : 10,
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: itemImageUrl,
                                      fit: BoxFit.cover,
                                      width: screenWidth,
                                      height: screenWidth,
                                      placeholder: (context, url) => Container(
                                        color: Colors.white,
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
                            ],
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
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
