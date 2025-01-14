import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/data/admob/admob_banner.dart';
import 'package:food_gram_app/core/data/admob/admob_interstitial.dart';
import 'package:food_gram_app/core/data/supabase/post_stream.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/env.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/router/go_router_extension.dart';
import 'package:food_gram_app/ui/component/app_elevated_button.dart';
import 'package:food_gram_app/ui/component/app_floating_button.dart';
import 'package:food_gram_app/ui/component/app_heart.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/app_profile_image.dart';
import 'package:food_gram_app/ui/component/app_share_widget.dart';
import 'package:food_gram_app/ui/component/dialog/app_share_dialog.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_master_modal_sheet.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_my_info_modal_sheet.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_other_info_modal_sheet.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:gap/gap.dart';
import 'package:gif/gif.dart';
import 'package:go_router/go_router.dart';
import 'package:heroine/heroine.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:snow_fall_animation/snow_fall_animation.dart';

class DetailPostScreen extends HookConsumerWidget {
  const DetailPostScreen({
    required this.posts,
    required this.users,
    super.key,
  });

  final Posts posts;
  final Users users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHeart = useState(false);
    final initialHeart = useState(posts.heart);
    final isSnowing = useState(false);
    final tickerProvider = useSingleTickerProvider();
    final adInterstitial = ref.watch(admobInterstitialNotifierProvider);
    final gifController = useMemoized(
      () => GifController(vsync: tickerProvider),
      [tickerProvider],
    );
    useEffect(
      () {
        adInterstitial.createAd();
        return gifController.dispose;
      },
      [gifController],
    );
    final deviceWidth = MediaQuery.of(context).size.width;
    final user = supabase.auth.currentUser?.id;
    final loading = ref.watch(loadingProvider);
    final menuLoading = useState(false);
    return PopScope(
      canPop: !loading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: !loading,
          surfaceTintColor: Colors.transparent,
          leading: !loading
              ? GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(
                    Icons.close,
                    size: 30,
                  ),
                )
              : SizedBox.shrink(),
          title: GestureDetector(
            onTap: () => isSnowing.value = !isSnowing.value,
            child: Text('     '),
          ),
          actions: [
            if (!loading)
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      if (user == Env.masterAccount) {
                        return AppDetailMasterModalSheet(
                          posts: posts,
                          users: users,
                        );
                      }
                      if (users.userId != user) {
                        return AppDetailOtherInfoModalSheet(
                          users: users,
                          posts: posts,
                        );
                      } else {
                        return AppDetailMyInfoModalSheet(
                          users: users,
                          posts: posts,
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
              if (isSnowing.value)
                const SnowFallAnimation(
                  config: SnowfallConfig(
                    numberOfSnowflakes: 300,
                    enableRandomOpacity: false,
                    enableSnowDrift: false,
                    holdSnowAtBottom: false,
                  ),
                ),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: AppProfileImage(
                            imagePath: users.image,
                            radius: 30,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                users.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '@${users.userName}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onDoubleTap: users.userId != user
                          ? () async {
                              final currentHeart = initialHeart.value;
                              if (isHeart.value) {
                                await supabase.from('posts').update({
                                  'heart': currentHeart - 1,
                                }).match({'id': posts.id});
                                initialHeart.value--;
                                isHeart.value = false;
                              } else {
                                await supabase.from('posts').update({
                                  'heart': currentHeart + 1,
                                }).match({'id': posts.id});
                                initialHeart.value++;
                                isHeart.value = true;
                              }
                            }
                          : null,
                      child: DragDismissable(
                        onDismiss: () => context.pop(),
                        child: Heroine(
                          tag: 'image-${posts.id}',
                          child: Container(
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
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Gap(5),
                        IconButton(
                          onPressed: users.userId != user
                              ? () async {
                                  final currentHeart = initialHeart.value;
                                  if (isHeart.value) {
                                    await supabase.from('posts').update({
                                      'heart': currentHeart - 1,
                                    }).match({'id': posts.id});
                                    initialHeart.value--;
                                    isHeart.value = false;
                                  } else {
                                    await supabase.from('posts').update({
                                      'heart': currentHeart + 1,
                                    }).match({'id': posts.id});
                                    initialHeart.value++;
                                    isHeart.value = true;
                                  }
                                }
                              : null,
                          icon: Icon(
                            isHeart.value
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                            color: isHeart.value ? Colors.red : Colors.black,
                            size: 30,
                          ),
                        ),
                        Gap(10),
                        GestureDetector(
                          onTap: () {
                            EasyDebounce.debounce(
                              'post',
                              Duration.zero,
                              () async {
                                await showGeneralDialog(
                                  context: context,
                                  pageBuilder: (context, anim1, anim2) {
                                    return AppShareDialog(
                                      posts: posts,
                                      users: users,
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: const Icon(
                            Icons.send,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            '${initialHeart.value} '
                            '${L10n.of(context).postDetailLikeButton}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gap(6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            AppDetailElevatedButton(
                              onPressed: () async {
                                await adInterstitial.showAd(
                                  onAdClosed: () async {
                                    await captureAndShare(
                                      widget: AppShareWidget(
                                        posts: posts,
                                        users: users,
                                      ),
                                      shareText: '${posts.foodName} '
                                          'in ${posts.restaurant}',
                                      loading: menuLoading,
                                    );
                                  },
                                );
                              },
                              icon: Icons.share,
                            ),
                            AppDetailElevatedButton(
                              onPressed: () async {
                                await adInterstitial.showAd(
                                  onAdClosed: () async {
                                    final availableMaps =
                                        await MapLauncher.installedMaps;
                                    await availableMaps.first.showMarker(
                                      coords: Coords(posts.lat, posts.lng),
                                      title: posts.restaurant,
                                    );
                                  },
                                );
                              },
                              icon: Icons.directions_walk,
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
                                    ref.invalidate(postStreamProvider);
                                  }
                                });
                              },
                              icon: Icons.restaurant,
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
                            posts.foodName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'In ${posts.restaurant}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const Gap(10),
                          Text(
                            posts.comment,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Wrap(
                            spacing: 10,
                            children: [
                              if (posts.foodTag.isNotEmpty)
                                Chip(
                                  backgroundColor: Colors.white,
                                  label: Text(posts.foodTag),
                                  labelStyle: const TextStyle(fontSize: 20),
                                ),
                              if (posts.restaurantTag.isNotEmpty)
                                Chip(
                                  backgroundColor: Colors.white,
                                  label: Text(posts.restaurantTag),
                                  labelStyle: const TextStyle(fontSize: 20),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const AdmobBanner(),
                  ],
                ),
              ),
              AppHeart(
                isHeart: isHeart.value,
                controller: gifController,
              ),
              AppLoading(
                loading: loading,
                status: 'Loading...',
              ),
            ],
          ),
        ),
        floatingActionButton: AppFloatingButton(
          onTap: () async {
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
        ),
      ),
    );
  }
}
