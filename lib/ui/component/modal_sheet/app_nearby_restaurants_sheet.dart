import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/supabase/post/services/map_post_service.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_list_view.dart';
import 'package:food_gram_app/ui/screen/map/map_view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 現在地から近いレストラン(投稿)を一覧表示する下部モーダル
class AppNearbyRestaurantsSheet extends HookConsumerWidget {
  const AppNearbyRestaurantsSheet({super.key});

  /// ピン/一覧タップでモーダル内表示を切り替えるための選択状態
  static final mapModalSelectionProvider =
      StateProvider<MapModalSelection?>((ref) => null);

  /// レストラン名で投稿取得（ローカルProvider。コード生成不要）
  static final getRestaurantPostsByNameLocalProvider =
      FutureProvider.family<List<Posts>, String>((ref, name) async {
    final data = await ref
        .read(mapPostServiceProvider.notifier)
        .getPostsByRestaurantName(name);
    return data.map(Posts.fromJson).toList();
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(mapModalSelectionProvider);
    final nearbyAsync = ref.watch(getNearByPostsProvider);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.24,
      minChildSize: 0.15,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const _DragHandle(),
              Expanded(
                child: nearbyAsync.when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return const _EmptyNearby();
                    }
                    final grouped = _groupByRestaurantName(posts);
                    if (selection != null) {
                      return _RestaurantPostsGridBodySelection(
                        selection: selection,
                        controller: controller,
                        onClose: () => ref
                            .read(mapModalSelectionProvider.notifier)
                            .state = null,
                      );
                    }
                    return ListView.separated(
                      controller: controller,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: grouped.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final group = grouped[index];
                        return _RestaurantTile(
                          group: group,
                          onOpen: (g) => ref
                              .read(mapModalSelectionProvider.notifier)
                              .state = MapModalSelection(
                            name: g.name,
                            lat: g.lat,
                            lng: g.lng,
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const _NearbySkeleton(),
                  error: (_, __) => const _EmptyNearby(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// レストラン名でグルーピング（同名はまとめる）
  List<_RestaurantGroup> _groupByRestaurantName(List<Posts> posts) {
    final map = <String, List<Posts>>{};
    for (final p in posts) {
      final key = p.restaurant.trim();
      map.putIfAbsent(key, () => []).add(p);
    }
    return map.entries.map((entry) {
      final list = entry.value;
      // 代表座標は最初の投稿を使用
      return _RestaurantGroup(
        name: entry.key,
        lat: list.first.lat,
        lng: list.first.lng,
        posts: list,
      );
    }).toList();
  }
}

class _RestaurantTile extends ConsumerWidget {
  const _RestaurantTile({required this.group, required this.onOpen});
  final _RestaurantGroup group;
  final void Function(_RestaurantGroup) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.watch(supabaseProvider);
    final postsByNameAsync = ref.watch(
      AppNearbyRestaurantsSheet.getRestaurantPostsByNameLocalProvider(
        group.name,
      ),
    );
    final fallbackImageUrls = group.posts
        .map((p) => p.firstFoodImage)
        .where((path) => path.isNotEmpty)
        .map((path) => supabase.storage.from('food').getPublicUrl(path))
        .toList();
    return InkWell(
      onTap: () async {
        // 該当場所にズーム
        await ref.read(mapViewModelProvider.notifier).animateToLatLng(
              lat: group.lat,
              lng: group.lng,
            );
        // 同一モーダル内でグリッドに切り替え
        onOpen(group);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            postsByNameAsync.when(
              data: (posts) {
                final stars =
                    posts.map((e) => e.star).where((s) => s > 0).toList();
                final avg = stars.isEmpty
                    ? null
                    : (stars.reduce((a, b) => a + b) / stars.length);
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
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
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
                      .map((p) => p.firstFoodImage)
                      .where((path) => path.isNotEmpty)
                      .map(
                        (path) =>
                            supabase.storage.from('food').getPublicUrl(path),
                      )
                      .toList();
                  if (imageUrls.isEmpty) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        Assets.image.empty.path,
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: imageUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
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
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        Assets.image.empty.path,
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: urls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
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
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        Assets.image.empty.path,
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: urls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
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
  }
}

/// 選択状態（ピン/一覧タップで使用）
class MapModalSelection {
  MapModalSelection({
    required this.name,
    required this.lat,
    required this.lng,
  });
  final String name;
  final double lat;
  final double lng;
}

/// selection を使うバージョン（ピンタップからの遷移でも使える）
class _RestaurantPostsGridBodySelection extends ConsumerWidget {
  const _RestaurantPostsGridBodySelection({
    required this.selection,
    required this.controller,
    required this.onClose,
  });
  final MapModalSelection selection;
  final ScrollController controller;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(
      AppNearbyRestaurantsSheet.getRestaurantPostsByNameLocalProvider(
        selection.name,
      ),
    );
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selection.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
              ],
            ),
          ),
        ),
        postsAsync.when(
          data: (posts) => AppListView(
            posts: posts,
            routerPath: RouterPath.mapDetail,
            type: AppListViewType.timeline,
            refresh: () {},
          ),
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (_, __) => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('読み込みに失敗しました')),
            ),
          ),
        ),
      ],
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _EmptyNearby extends StatelessWidget {
  const _EmptyNearby();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '近くの投稿が見つかりません',
        style: TextStyle(color: Colors.black54),
      ),
    );
  }
}

class _NearbySkeleton extends StatelessWidget {
  const _NearbySkeleton();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 180,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Container(
                      height: 90,
                      margin: EdgeInsets.only(right: i == 2 ? 0 : 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RestaurantGroup {
  _RestaurantGroup({
    required this.name,
    required this.lat,
    required this.lng,
    required this.posts,
  });
  final String name;
  final double lat;
  final double lng;
  final List<Posts> posts;
}
