import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/user/repository/user_repository.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/profile/app_profile_image.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppMyMapRestaurantModalSheet extends ConsumerWidget {
  const AppMyMapRestaurantModalSheet({
    required this.post,
    super.key,
  });

  final List<Posts?> post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: deviceWidth,
        height: deviceWidth / 1.7,
        child: ListView.builder(
          itemCount: post.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final currentPost = post[index];
            if (currentPost == null) {
              return const SizedBox.shrink();
            }
            return _MapModalCardItem(
              post: currentPost,
              postList: post,
              index: index,
              deviceWidth: deviceWidth,
            );
          },
        ),
      ),
    );
  }
}

class _MapModalCardItem extends HookConsumerWidget {
  const _MapModalCardItem({
    required this.post,
    required this.postList,
    required this.index,
    required this.deviceWidth,
  });

  final Posts post;
  final List<Posts?> postList;
  final int index;
  final double deviceWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.watch(supabaseProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? Colors.black : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.white70 : Colors.grey.shade600;
    final t = Translations.of(context);
    final pageController = usePageController();
    final userFuture = useMemoized(
      () => ref
          .read(userRepositoryProvider.notifier)
          .getUserFromPost(post)
          .then((result) => result.whenOrNull(success: (u) => u)),
      [post.userId],
    );
    final snapshot = useFuture(userFuture);
    final imageUrls = post.foodImageList
        .map((path) => supabase.storage.from('food').getPublicUrl(path))
        .toList();
    final isLoading = snapshot.connectionState == ConnectionState.waiting;
    final displayName = isLoading
        ? '...'
        : (snapshot.data != null && !post.isAnonymous
            ? snapshot.data!.name
            : t.anonymous.poster);
    final imagePath = post.isAnonymous
        ? 'assets/icon/icon1.png'
        : (snapshot.data?.image ?? 'assets/icon/icon1.png');
    return GestureDetector(
      onTap: () {
        EasyDebounce.debounce(
          'click detail',
          Duration.zero,
          () async {
            final userResult = await ref
                .read(userRepositoryProvider.notifier)
                .getUserFromPost(postList[index]!);
            await userResult.whenOrNull(
              success: (postUsers) async {
                final model = Model(postUsers, postList[index]!);
                await context
                    .pushNamed(
                  RouterPath.mapDetail,
                  extra: model,
                )
                    .then((value) {
                  if (value != null) {
                    ref
                      ..invalidate(postsStreamProvider)
                      ..invalidate(blockListProvider);
                  }
                });
              },
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          child: SizedBox(
            width: deviceWidth / 1.2,
            height: deviceWidth / 1.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: cardBg,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      AppProfileImage(
                        imagePath: imagePath,
                        radius: 20,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (post.star > 0) ...[
                              const Gap(2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const Gap(2),
                                  Text(
                                    post.star.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: subtitleColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: deviceWidth,
                    child: imageUrls.isEmpty
                        ? Image.asset(
                            isDark
                                ? Assets.image.emptyDark.path
                                : Assets.image.empty.path,
                            fit: BoxFit.cover,
                          )
                        : PageView.builder(
                            itemCount: imageUrls.length,
                            controller: pageController,
                            itemBuilder: (context, pageIndex) {
                              return CachedNetworkImage(
                                imageUrl: imageUrls[pageIndex],
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Image.asset(
                                  isDark
                                      ? Assets.image.emptyDark.path
                                      : Assets.image.empty.path,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
