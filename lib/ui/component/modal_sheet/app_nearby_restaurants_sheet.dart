import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant_group.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/repository/user_repository.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_skeleton.dart';
import 'package:food_gram_app/ui/component/profile/app_profile_image.dart';
import 'package:food_gram_app/ui/screen/map/map_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 現在地から近いレストラン(投稿)を一覧表示する下部モーダル
class AppNearbyRestaurantsSheet extends HookConsumerWidget {
  const AppNearbyRestaurantsSheet({super.key});

  /// ピン/一覧タップでモーダル内表示を切り替えるための選択状態
  static final mapModalSelectionProvider =
      StateProvider<MapModalSelection?>((ref) => null);

  /// Repository経由で店名の投稿を取得（コード生成に依存しないローカルProvider）
  static final postsByNameFromRepositoryProvider =
      FutureProvider.family<List<Posts>, String>((ref, name) async {
    final repo = ref.read(mapPostRepositoryProvider.notifier);
    return repo.getPostsByRestaurantName(name: name);
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(mapModalSelectionProvider);
    final cameraCenter = ref.watch(mapViewModelProvider).cameraCenterLatLng;
    final nearbyAsync = cameraCenter == null
        ? null
        : ref.watch(getNearByPostsProvider(cameraCenter));
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? Colors.black : Colors.white;
        final sheetFg = isDark ? Colors.white : Colors.black;
        final handleColor = isDark ? Colors.white54 : Colors.grey[300];
        final slivers = <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 10),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: handleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          if (selection == null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => ref
                        .read(mapViewModelProvider.notifier)
                        .setNearbySearchCenterFromCamera(),
                    icon: const Icon(Icons.search, size: 20),
                    label: Text(
                      Translations.of(context).searchNearbyPlaces,
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ),
          if (nearbyAsync == null)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else
            nearbyAsync.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: _EmptyNearby(),
                    ),
                  );
                }
                final grouped = _groupByRestaurantName(posts);
                if (selection != null) {
                  final postsAsync = ref.watch(
                    AppNearbyRestaurantsSheet.postsByNameFromRepositoryProvider(
                      selection.name,
                    ),
                  );
                  return SliverMainAxisGroup(slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                selection.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: sheetFg,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => ref
                                  .read(
                                    mapModalSelectionProvider.notifier,
                                  )
                                  .state = null,
                              icon: Icon(Icons.close, color: sheetFg),
                            ),
                          ],
                        ),
                      ),
                    ),
                    postsAsync.when(
                      data: (posts) => SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _MapSheetPostListItem(
                            post: posts[index],
                            onRefresh: () {
                              ref.invalidate(
                                AppNearbyRestaurantsSheet
                                    .postsByNameFromRepositoryProvider(
                                  selection.name,
                                ),
                              );
                              ref.invalidate(postsStreamProvider);
                              ref.invalidate(blockListProvider);
                            },
                          ),
                          childCount: posts.length,
                        ),
                      ),
                      loading: () => const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                      error: (_, __) => SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              Translations.of(context).notification.loadFailed,
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]);
                }
                if (grouped.isEmpty) {
                  return SliverToBoxAdapter(
                    child: const Padding(
                      padding: EdgeInsets.all(24),
                      child: _EmptyNearby(),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index.isOdd) {
                          return const Divider(height: 1);
                        }
                        final group = grouped[index ~/ 2];
                        final supabase = ref.watch(supabaseProvider);
                        final postsByNameAsync = ref.watch(
                          AppNearbyRestaurantsSheet
                              .postsByNameFromRepositoryProvider(
                            group.name,
                          ),
                        );
                        final fallbackImageUrls = group.posts
                            .map((i) => i.firstFoodImage)
                            .where((path) => path.isNotEmpty)
                            .map(
                              (path) => supabase.storage
                                  .from('food')
                                  .getPublicUrl(path),
                            )
                            .toList();
                        return InkWell(
                          onTap: () async {
                            await ref
                                .read(mapViewModelProvider.notifier)
                                .animateToLatLng(
                                  lat: group.lat,
                                  lng: group.lng,
                                );
                            ref
                                .read(
                                  mapModalSelectionProvider.notifier,
                                )
                                .state = MapModalSelection(
                              name: group.name,
                              lat: group.lat,
                              lng: group.lng,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        group.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                postsByNameAsync.when(
                                  data: (posts) {
                                    final stars = posts
                                        .map((e) => e.star)
                                        .where((s) => s > 0)
                                        .toList();
                                    final avg = stars.isEmpty
                                        ? null
                                        : (stars.reduce(
                                              (a, b) => a + b,
                                            ) /
                                            stars.length);
                                    return Row(
                                      children: [
                                        if (avg != null) ...[
                                          const Icon(
                                            Icons.star,
                                            color: Color(0xFFFFC107),
                                            size: 24,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            avg.toStringAsFixed(1),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    );
                                  },
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, __) => const SizedBox.shrink(),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 90,
                                  child: postsByNameAsync.when(
                                    data: (posts) {
                                      final imageUrls = posts
                                          .map((i) => i.firstFoodImage)
                                          .where((path) => path.isNotEmpty)
                                          .map(
                                            (path) => supabase.storage
                                                .from('food')
                                                .getPublicUrl(path),
                                          )
                                          .toList();
                                      if (imageUrls.isEmpty) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.asset(
                                            isDark
                                                ? Assets.image.emptyDark.path
                                                : Assets.image.empty.path,
                                            height: 90,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }
                                      return ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: imageUrls.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (context, index) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              imageUrl: imageUrls[index],
                                              height: 90,
                                              width: 90,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    loading: () {
                                      final urls = fallbackImageUrls;
                                      if (urls.isEmpty) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.asset(
                                            isDark
                                                ? Assets.image.emptyDark.path
                                                : Assets.image.empty.path,
                                            height: 90,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }
                                      return ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: urls.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (context, index) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              imageUrl: urls[index],
                                              height: 90,
                                              width: 90,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    error: (_, __) {
                                      final urls = fallbackImageUrls;
                                      if (urls.isEmpty) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.asset(
                                            isDark
                                                ? Assets.image.emptyDark.path
                                                : Assets.image.empty.path,
                                            height: 90,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }
                                      return ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: urls.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (context, index) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              imageUrl: urls[index],
                                              height: 90,
                                              width: 90,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: grouped.length * 2 - 1,
                    ),
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: SizedBox(
                  height: 400,
                  child: AppNearbyRestaurantsSkeleton(),
                ),
              ),
              error: (_, __) => SliverToBoxAdapter(
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: _EmptyNearby(),
                ),
              ),
            ),
        ];
        return DecoratedBox(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: CustomScrollView(
            controller: scrollController,
            primary: false,
            slivers: slivers,
          ),
        );
      },
    );
  }

  /// レストラン名でグループ化
  List<RestaurantGroup> _groupByRestaurantName(List<Posts> posts) {
    final map = <String, List<Posts>>{};
    for (final p in posts) {
      final key = p.restaurant.trim();
      map.putIfAbsent(key, () => []).add(p);
    }
    return map.entries.map((entry) {
      final list = entry.value;
      // 代表座標は最初の投稿を使用
      return RestaurantGroup(
        name: entry.key,
        lat: list.first.lat,
        lng: list.first.lng,
        posts: list,
      );
    }).toList();
  }
}

class _MapSheetPostListItem extends HookConsumerWidget {
  const _MapSheetPostListItem({
    required this.post,
    required this.onRefresh,
  });

  final Posts post;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.watch(supabaseProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetFg = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.white70 : Colors.grey.shade600;
    final t = Translations.of(context);
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
            ? (snapshot.data?.name ?? t.anonymous.poster)
            : t.anonymous.poster);
    final imagePath = post.isAnonymous
        ? 'assets/icon/icon1.png'
        : (snapshot.data?.image ?? 'assets/icon/icon1.png');

    return GestureDetector(
      onTap: () {
        EasyDebounce.debounce(
          'click map sheet detail',
          Duration.zero,
          () async {
            final userResult = await ref
                .read(userRepositoryProvider.notifier)
                .getUserFromPost(post);
            await userResult.whenOrNull(
              success: (postUsers) async {
                final model = Model(postUsers, post);
                await context
                    .pushNamed(RouterPath.mapDetail, extra: model)
                    .then((value) {
                  if (value != null) {
                    onRefresh();
                  }
                });
              },
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppProfileImage(imagePath: imagePath, radius: 24),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: sheetFg,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (post.star > 0) ...[
                        const Gap(4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const Gap(4),
                            Text(
                              post.star.toStringAsFixed(1),
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  Text(
                    post.comment,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: sheetFg,
                    ),
                  ),
                  const Gap(8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: imageUrls.isEmpty
                          ? Image.asset(
                              isDark
                                  ? Assets.image.emptyDark.path
                                  : Assets.image.empty.path,
                              fit: BoxFit.cover,
                            )
                          : imageUrls.length == 1
                              ? CachedNetworkImage(
                                  imageUrl: imageUrls.first,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Image.asset(
                                    isDark
                                        ? Assets.image.emptyDark.path
                                        : Assets.image.empty.path,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: imageUrls.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, i) {
                                    const size = 150.0;
                                    return SizedBox(
                                      height: size,
                                      width: size,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrls[i],
                                          height: size,
                                          width: size,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) =>
                                              Image.asset(
                                            isDark
                                                ? Assets.image.emptyDark.path
                                                : Assets.image.empty.path,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNearby extends StatelessWidget {
  const _EmptyNearby();
  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Text(
        t.noResultsFound,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }
}
