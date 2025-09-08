import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/theme/style/detail_post_style.dart';
import 'package:food_gram_app/core/utils/helpers/share_helper.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/go_router_extension.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_elevated_button.dart';
import 'package:food_gram_app/ui/component/dialog/app_share_dialog.dart';
import 'package:food_gram_app/ui/component/profile/app_profile_image.dart';
import 'package:food_gram_app/ui/screen/post_detail/post_detail_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:heroine/heroine.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_viewer/photo_viewer.dart';

/// 投稿詳細画面のリストアイテム
class PostDetailListItem extends HookConsumerWidget {
  const PostDetailListItem({
    required this.posts,
    required this.users,
    required this.onHeartLimitReached,
    required this.menuLoading,
    super.key,
  });

  final Posts posts;
  final Users users;
  final VoidCallback onHeartLimitReached;
  final ValueNotifier<bool> menuLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final l10n = L10n.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final supabase = ref.watch(supabaseProvider);
    final detailState = ref.watch(postDetailViewModelProvider());

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ユーザー情報
          GestureDetector(
            onTap: () async {
              if (users.userId != currentUser && !posts.isAnonymous) {
                await context.pushNamed(
                  RouterPath.mapProfile,
                  extra: users,
                );
              }
            },
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: AppProfileImage(
                    imagePath: posts.isAnonymous
                        ? 'assets/icon/icon1.png'
                        : users.image,
                    radius: 30,
                  ),
                ),
                SizedBox(
                  width: deviceWidth - 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        posts.isAnonymous ? l10n.anonymousPoster : users.name,
                        style: DetailPostStyle.name(),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Builder(
                        builder: (context) {
                          final username = posts.isAnonymous
                              ? l10n.anonymousUsername
                              : users.userName;
                          return Text(
                            '@$username',
                            style: DetailPostStyle.userName(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 投稿画像
          Center(
            child: GestureDetector(
              onTap: () {
                showPhotoViewer(
                  context: context,
                  heroTagBuilder: (context) => 'image-${posts.id}',
                  builder: (context) => Container(
                    width: deviceWidth,
                    height: deviceWidth,
                    color: Colors.white,
                    child: CachedNetworkImage(
                      imageUrl: supabase.storage
                          .from('food')
                          .getPublicUrl(posts.foodImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              onDoubleTap: () async {
                if (currentUser == null) {
                  return;
                }
                await ref
                    .read(postDetailViewModelProvider().notifier)
                    .handleHeart(
                      posts: posts,
                      currentUser: currentUser,
                      userId: users.userId,
                      onHeartLimitReached: onHeartLimitReached,
                    );
              },
              child: Heroine(
                tag: 'image-${posts.id}',
                child: Container(
                  width: deviceWidth / 1.2,
                  height: deviceWidth / 1.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: supabase.storage
                          .from('food')
                          .getPublicUrl(posts.foodImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // アクションボタン
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    const Gap(4),
                    IconButton(
                      onPressed: () async {
                        if (currentUser == null) {
                          return;
                        }
                        await ref
                            .read(postDetailViewModelProvider().notifier)
                            .handleHeart(
                              posts: posts,
                              currentUser: currentUser,
                              userId: users.userId,
                              onHeartLimitReached: onHeartLimitReached,
                            );
                      },
                      icon: Icon(
                        detailState.isHeart
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: detailState.isHeart ? Colors.red : Colors.black,
                        size: 40,
                      ),
                    ),
                    const Gap(6),
                    GestureDetector(
                      onTap: () {
                        showGeneralDialog(
                          context: context,
                          pageBuilder: (_, __, ___) {
                            return AppShareDialog(
                              posts: posts,
                              users: users,
                            );
                          },
                        );
                      },
                      child: const Icon(Icons.send, size: 40),
                    ),
                    const Spacer(),
                    Text(
                      '${detailState.heart} ${l10n.likeButton}',
                      style: DetailPostStyle.like(),
                    ),
                    IconButton(
                      onPressed: () {
                        ref.read(postDetailViewModelProvider().notifier).store(
                              postId: posts.id,
                              openSnackBar: () {
                                final l10n = L10n.of(context);
                                final snackBar = SnackBar(
                                  content: Column(
                                    children: [
                                      Text(l10n.postSaved),
                                      Text(l10n.postSavedMessage),
                                    ],
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              },
                            );
                      },
                      icon: Icon(
                        detailState.isStore
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                      ),
                      iconSize: 40,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const Gap(6),

              // 詳細メニュー
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      AppDetailElevatedButton(
                        onPressed: () async {
                          await ShareHelpers().openShareModal(
                            posts: posts,
                            ref: ref,
                            loading: menuLoading,
                            context: context,
                            shareText:
                                '${posts.foodName} in ${posts.restaurant}',
                          );
                        },
                        title: l10n.detailMenuShare,
                        icon: Icons.share,
                      ),
                      AppDetailElevatedButton(
                        onPressed: () async {
                          final currentPath =
                              GoRouter.of(context).isCurrentLocation();
                          await context
                              .pushNamed(
                            currentPath,
                            extra: Restaurant(
                              name: posts.restaurant,
                              lat: posts.lat,
                              lng: posts.lng,
                              address: '',
                            ),
                          )
                              .then((value) async {
                            if (value != null) {
                              // 投稿ストリームを無効化
                              // ref.invalidate(postStreamProvider);
                            }
                          });
                        },
                        title: l10n.detailMenuPost,
                        icon: Icons.restaurant,
                      ),
                      AppDetailElevatedButton(
                        onPressed: () => ref
                            .read(postDetailViewModelProvider().notifier)
                            .openUrl(posts.restaurant),
                        title: l10n.detailMenuSearch,
                        icon: Icons.search,
                      ),
                      AppDetailElevatedButton(
                        onPressed: () async {
                          await ref
                              .read(postDetailViewModelProvider().notifier)
                              .openMap(
                            posts.restaurant,
                            posts.lat,
                            posts.lng,
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.noMapAppAvailable),
                                ),
                              );
                            },
                          );
                        },
                        title: l10n.detailMenuVisit,
                        icon: Icons.directions_walk,
                      ),
                    ],
                  ),
                ),
              ),

              // 投稿詳細情報
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      posts.foodName,
                      style: DetailPostStyle.foodName(),
                    ),
                    const Gap(4),
                    GestureDetector(
                      onTap: () {
                        context.pushNamed(
                          RouterPath.myProfileRestaurantReview,
                          extra: posts,
                        );
                      },
                      child: Text(
                        'In ${posts.restaurant}',
                        style: DetailPostStyle.restaurant(),
                      ),
                    ),
                    const Gap(16),
                    if (posts.comment.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            posts.comment,
                            style: DetailPostStyle.comment(),
                          ),
                          const Gap(12),
                        ],
                      ),
                    Wrap(
                      spacing: 10,
                      children: [
                        if (posts.foodTag.isNotEmpty)
                          ...posts.foodTag.split(',').map(
                                (tag) => Chip(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.all(2),
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        tag,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const Gap(8),
                                      Text(
                                        getLocalizedFoodName(tag, context),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        if (posts.restaurantTag.isNotEmpty)
                          Chip(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(2),
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  posts.restaurantTag,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const Gap(4),
                                Text(
                                  getLocalizedCountryName(
                                    posts.restaurantTag,
                                    context,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
