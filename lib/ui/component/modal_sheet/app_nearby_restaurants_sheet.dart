import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant_group.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_list_view.dart';
import 'package:food_gram_app/ui/component/common/app_skeleton.dart';
import 'package:food_gram_app/ui/screen/map/map_view_model.dart';
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
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 8),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: nearbyAsync.when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return const _EmptyNearby();
                    }
                    final grouped = _groupByRestaurantName(posts);
                    if (selection != null) {
                      final postsAsync = ref.watch(
                        AppNearbyRestaurantsSheet
                            .postsByNameFromRepositoryProvider(
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
                                  IconButton(
                                    onPressed: () => ref
                                        .read(
                                          mapModalSelectionProvider.notifier,
                                        )
                                        .state = null,
                                    icon: const Icon(Icons.close),
                                  ),
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
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                            ),
                            error: (_, __) => const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: Text('読み込みに失敗しました'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.separated(
                      controller: controller,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: grouped.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final group = grouped[index];
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
                    );
                  },
                  loading: () => const AppNearbyRestaurantsSkeleton(),
                  error: (_, __) => const _EmptyNearby(),
                ),
              ),
            ],
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

class _EmptyNearby extends StatelessWidget {
  const _EmptyNearby();
  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return Center(
      child: Text(
        t.noResultsFound,
        style: const TextStyle(color: Colors.black54),
      ),
    );
  }
}
