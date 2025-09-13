import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/admob/services/admob_rectangle_banner.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/core/supabase/user/providers/subscribed_users_provider.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:go_router/go_router.dart';
import 'package:heroine/heroine.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppListView extends HookConsumerWidget {
  const AppListView({
    required this.posts,
    required this.routerPath,
    required this.refresh,
    required this.type,
    super.key,
  });

  final List<Posts> posts;
  final String routerPath;
  final VoidCallback refresh;
  final AppListViewType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width / 3;
    final supabase = ref.watch(supabaseProvider);
    final subscribedUsersAsync = ref.watch(subscribedUsersProvider);
    if (posts.isEmpty) {
      return const AppEmpty();
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
                            .read(postRepositoryProvider.notifier)
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
                  child: Heroine(
                    tag: 'image-${posts[itemIndex].id}',
                    flightShuttleBuilder: const FlipShuttleBuilder().call,
                    spring: SimpleSpring.bouncy,
                    child: SizedBox(
                      width: screenWidth,
                      height: screenWidth,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: subscribedUsersAsync.when(
                          data: (subscribedUsers) {
                            final postUserId =
                                posts[itemIndex].userId as String?;
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
                                        placeholder: (context, url) =>
                                            Container(
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
