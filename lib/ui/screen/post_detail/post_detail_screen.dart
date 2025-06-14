import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/admob/services/admob_banner.dart';
import 'package:food_gram_app/core/admob/services/admob_interstitial.dart';
import 'package:food_gram_app/core/config/constants/url.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
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
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/app_profile_image.dart';
import 'package:food_gram_app/ui/component/dialog/app_share_dialog.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_master_modal_sheet.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_my_info_modal_sheet.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_other_info_modal_sheet.dart';
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
    final initialHeart = useState(posts.heart);
    final heartList = useState<List<String>>([]);
    final isHeart = useState(false);
    final isAppearHeart = useState(false);
    final adInterstitial =
        useMemoized(() => ref.read(admobInterstitialNotifierProvider));
    final preference = Preference();
    // 既にいいねをしているかどうかuseEffect
    useEffect(
      () {
        preference.getStringList(PreferenceKey.heartList).then((value) {
          heartList.value = value;
          isHeart.value = value.contains(posts.id.toString());
        });
        return;
      },
      [],
    );
    // 広告のためのuseEffect
    useEffect(
      () {
        adInterstitial.createAd();
        return;
      },
      [adInterstitial],
    );
    final deviceWidth = MediaQuery.of(context).size.width;
    final loading = ref.watch(loadingProvider);
    final menuLoading = useState(false);
    final l10n = L10n.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final supabase = ref.watch(supabaseProvider);
    Future<void> handleHeart() async {
      if (users.userId == currentUser) {
        return;
      }
      final postId = posts.id.toString();
      final currentHeart = initialHeart.value;
      if (isHeart.value) {
        await supabase.from('posts').update({
          'heart': currentHeart - 1,
        }).match({'id': posts.id});
        initialHeart.value--;
        isHeart.value = false;
        isAppearHeart.value = false;
        heartList.value = List.from(heartList.value)..remove(postId);
      } else {
        await supabase.from('posts').update({
          'heart': currentHeart + 1,
        }).match({'id': posts.id});
        initialHeart.value++;
        isHeart.value = true;
        isAppearHeart.value = true;
        heartList.value = List.from(heartList.value)..add(postId);
      }
      await preference.setStringList(
        PreferenceKey.heartList,
        heartList.value,
      );
    }

    final state = ref.watch(postsViewModelProvider(posts.id));

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
          body: const AppLoading(
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
                          if (users.userId != currentUser) {
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
                                imagePath: users.image,
                                radius: 30,
                              ),
                            ),
                            SizedBox(
                              width: deviceWidth - 150,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    users.name,
                                    style: DetailPostStyle.name(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '@${users.userName}',
                                    style: DetailPostStyle.userName(),
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
                          onDoubleTap: handleHeart,
                          child: Heroine(
                            tag: 'image-${posts.id}',
                            child: Container(
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
                                onPressed: handleHeart,
                                icon: Icon(
                                  isHeart.value
                                      ? CupertinoIcons.heart_fill
                                      : CupertinoIcons.heart,
                                  color:
                                      isHeart.value ? Colors.red : Colors.black,
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
                                  '${initialHeart.value} '
                                  '${l10n.postDetailLikeButton}',
                                  style: DetailPostStyle.like(),
                                ),
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
                                      await adInterstitial.showAd(
                                        onAdClosed: () async {
                                          await ShareHelpers().openShareModal(
                                            posts: posts,
                                            ref: ref,
                                            loading: menuLoading,
                                            context: context,
                                            shareText: '${posts.foodName} '
                                                'in ${posts.restaurant}',
                                          );
                                        },
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
                                      await adInterstitial.showAd(
                                        onAdClosed: () async {
                                          final availableMaps =
                                              await MapLauncher.installedMaps;
                                          await availableMaps.first.showMarker(
                                            coords:
                                                Coords(posts.lat, posts.lng),
                                            title: posts.restaurant,
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
                                      Chip(
                                        backgroundColor: Colors.white,
                                        label: Text(state.foodTag),
                                        labelStyle:
                                            const TextStyle(fontSize: 28),
                                      ),
                                    if (state.restaurantTag.isNotEmpty)
                                      Chip(
                                        backgroundColor: Colors.white,
                                        label: Text(state.restaurantTag),
                                        labelStyle:
                                            const TextStyle(fontSize: 28),
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
                AppHeart(isHeart: isAppearHeart.value),
                AppLoading(
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
