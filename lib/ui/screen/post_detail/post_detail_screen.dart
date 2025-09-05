import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/admob/services/admob_banner.dart';
import 'package:food_gram_app/core/config/constants/url.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/theme/style/detail_post_style.dart';
import 'package:food_gram_app/core/utils/helpers/share_helper.dart';
import 'package:food_gram_app/core/utils/helpers/url_launch_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/env.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/go_router_extension.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_elevated_button.dart';
import 'package:food_gram_app/ui/component/app_heart.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/dialog/app_share_dialog.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_master_modal_sheet.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_my_info_modal_sheet.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_other_info_modal_sheet.dart';
import 'package:food_gram_app/ui/component/profile/app_profile_image.dart';
import 'package:food_gram_app/ui/screen/post_detail/post_detail_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:heroine/heroine.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:photo_viewer/photo_viewer.dart';

class PostDetailScreen extends HookConsumerWidget {
  const PostDetailScreen({
    required this.posts,
    required this.users,
    super.key,
  });

  final Posts posts;
  final Users users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        ref
            .read(postDetailViewModelProvider().notifier)
            .initializeStoreState(posts.id);
        ref
            .read(postDetailViewModelProvider().notifier)
            .initializeHeartState(posts.id, posts.heart);
        return;
      },
      [posts.id],
    );
    final deviceWidth = MediaQuery.of(context).size.width;
    final l10n = L10n.of(context);
    final menuLoading = useState(false);
    final loading = ref.watch(loadingProvider);
    final currentUser = ref.watch(currentUserProvider);
    final supabase = ref.watch(supabaseProvider);
    final state = ref.watch(postsViewModelProvider(posts.id));
    final detailState = ref.watch(postDetailViewModelProvider());
    return PopScope(
      canPop: !loading,
      child: state.when(
        loading: () => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            surfaceTintColor: Colors.transparent,
          ),
          body: const AppProcessLoading(
            loading: true,
            status: '',
          ),
        ),
        data: (state) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: !loading,
            surfaceTintColor: Colors.transparent,
            leading: loading || menuLoading.value
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.close,
                      size: 30,
                    ),
                  ),
            actions: [
              if (!loading && !menuLoading.value)
                IconButton(
                  onPressed: () async {
                    await showModalBottomSheet<void>(
                      context: context,
                      builder: (context) {
                        if (currentUser == Env.masterAccount) {
                          return AppDetailMasterModalSheet(
                            posts: posts,
                            users: users,
                            delete: (posts) async {
                              await ref
                                  .read(postDetailViewModelProvider().notifier)
                                  .delete(posts);
                            },
                          );
                        }
                        if (users.userId != currentUser) {
                          return AppDetailOtherInfoModalSheet(
                            users: users,
                            posts: posts,
                            loading: menuLoading,
                            block: (userId) async {
                              return ref
                                  .read(postDetailViewModelProvider().notifier)
                                  .block(userId);
                            },
                          );
                        } else {
                          return AppDetailMyInfoModalSheet(
                            users: users,
                            posts: state,
                            loading: menuLoading,
                            delete: (posts) async {
                              await ref
                                  .read(postDetailViewModelProvider().notifier)
                                  .delete(posts);
                            },
                            setUser: (posts) {
                              ref
                                  .read(
                                    postsViewModelProvider(posts.id).notifier,
                                  )
                                  .setUser(posts);
                            },
                          );
                        }
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (users.userId != currentUser &&
                              !posts.isAnonymous) {
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
                                    posts.isAnonymous
                                        ? l10n.anonymousPoster
                                        : users.name,
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
                      DragDismissable(
                        onDismiss: () => context.pop(),
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
                                      .getPublicUrl(state.foodImage),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                          onDoubleTap: () async {
                            await ref
                                .read(postDetailViewModelProvider().notifier)
                                .handleHeart(
                                  posts: posts,
                                  currentUser: currentUser!,
                                  userId: users.userId,
                                  onHeartLimitReached: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.heartLimitMessage),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  },
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
                                      .getPublicUrl(state.foodImage),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(8),
                          Row(
                            children: [
                              const Gap(5),
                              IconButton(
                                onPressed: () async {
                                  await ref
                                      .read(
                                        postDetailViewModelProvider().notifier,
                                      )
                                      .handleHeart(
                                        posts: posts,
                                        currentUser: currentUser!,
                                        userId: users.userId,
                                        onHeartLimitReached: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text(l10n.heartLimitMessage),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        },
                                      );
                                },
                                icon: Icon(
                                  detailState.isHeart
                                      ? CupertinoIcons.heart_fill
                                      : CupertinoIcons.heart,
                                  color: detailState.isHeart
                                      ? Colors.red
                                      : Colors.black,
                                  size: 30,
                                ),
                              ),
                              const Gap(10),
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
                                child: const Icon(Icons.send, size: 30),
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Text(
                                  '${detailState.heart} '
                                  '${l10n.likeButton}',
                                  style: DetailPostStyle.like(),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  ref
                                      .read(
                                        postDetailViewModelProvider().notifier,
                                      )
                                      .store(
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
                                iconSize: 36,
                                color: Colors.black,
                              ),
                            ],
                          ),
                          const Gap(6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                        shareText: '${posts.foodName} '
                                            'in ${posts.restaurant}',
                                      );
                                    },
                                    title: l10n.detailMenuShare,
                                    icon: Icons.share,
                                  ),
                                  AppDetailElevatedButton(
                                    onPressed: () async {
                                      final currentPath = GoRouter.of(context)
                                          .isCurrentLocation();
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
                                          ref.invalidate(postStreamProvider);
                                        }
                                      });
                                    },
                                    title: l10n.detailMenuPost,
                                    icon: Icons.restaurant,
                                  ),
                                  AppDetailElevatedButton(
                                    onPressed: () => LaunchUrlHelper()
                                        .open(URL.search(posts.restaurant)),
                                    title: l10n.detailMenuSearch,
                                    icon: Icons.search,
                                  ),
                                  AppDetailElevatedButton(
                                    onPressed: () async {
                                      final availableMaps =
                                          await MapLauncher.installedMaps;
                                      await availableMaps.first.showMarker(
                                        coords: Coords(posts.lat, posts.lng),
                                        title: posts.restaurant,
                                      );
                                    },
                                    title: l10n.detailMenuVisit,
                                    icon: Icons.directions_walk,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.foodName,
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
                                    'In ${state.restaurant}',
                                    style: DetailPostStyle.restaurant(),
                                  ),
                                ),
                                const Gap(12),
                                if (state.comment.isNotEmpty)
                                  Column(
                                    children: [
                                      Text(
                                        state.comment,
                                        style: DetailPostStyle.comment(),
                                      ),
                                      const Gap(12),
                                    ],
                                  ),
                                Wrap(
                                  spacing: 10,
                                  children: [
                                    if (state.foodTag.isNotEmpty)
                                      ...state.foodTag.split(',').map(
                                            (tag) => Chip(
                                              backgroundColor: Colors.white,
                                              padding: const EdgeInsets.all(2),
                                              label: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    tag,
                                                    style: const TextStyle(
                                                      fontSize: 24,
                                                    ),
                                                  ),
                                                  const Gap(8),
                                                  Text(
                                                    getLocalizedFoodName(
                                                      tag,
                                                      context,
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    if (state.restaurantTag.isNotEmpty)
                                      Chip(
                                        backgroundColor: Colors.white,
                                        padding: const EdgeInsets.all(2),
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              state.restaurantTag,
                                              style:
                                                  const TextStyle(fontSize: 24),
                                            ),
                                            const Gap(4),
                                            Text(
                                              getLocalizedCountryName(
                                                state.restaurantTag,
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
                      const AdmobBanner(id: 'detail'),
                    ],
                  ),
                ),
                AppHeart(isHeart: detailState.isAppearHeart),
                AppProcessLoading(
                  loading: menuLoading.value || loading,
                  status: 'Loading...',
                ),
              ],
            ),
          ),
          floatingActionButton: SizedBox(
            width: 70,
            height: 70,
            child: FloatingActionButton(
              heroTag: null,
              foregroundColor: Colors.black,
              backgroundColor: Colors.black,
              elevation: 10,
              shape: const CircleBorder(side: BorderSide()),
              onPressed: () async {
                final currentPath = GoRouter.of(context).isCurrentLocation();
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
                    ref.invalidate(postStreamProvider);
                  }
                });
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 35,
              ),
            ),
          ),
        ),
        error: () => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            surfaceTintColor: Colors.transparent,
          ),
          body: const Center(
            child: Text('エラーが発生しました'),
          ),
        ),
      ),
    );
  }
}
