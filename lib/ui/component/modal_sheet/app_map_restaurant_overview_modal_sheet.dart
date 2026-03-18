import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant_group.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart'
    as map_repo;
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/common/app_error_widget.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_skeleton.dart';
import 'package:food_gram_app/ui/screen/map/map_view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// ピン/一覧タップでモーダル内表示を切り替えるための選択状態
final mapModalSelectionProvider =
    StateProvider<MapModalSelection?>((ref) => null);

/// マップ画面の「最初のモーダル」（近くのレストラン一覧）を表示するシート。
class AppMapRestaurantOverviewModalSheet extends HookConsumerWidget {
  const AppMapRestaurantOverviewModalSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(mapModalSelectionProvider);
    if (selection != null) {
      return const SizedBox.shrink();
    }
    // カメラに関わる処理（カメラの位置に応じて近隣のレストランを取得）
    final cameraCenter = ref.watch(mapViewModelProvider).cameraCenterLatLng;
    // カメラの位置に応じて近隣のレストランを取得
    final nearbyAsync = cameraCenter == null
        ? null
        : ref.watch(map_repo.getNearByPostsProvider(cameraCenter));
    return DraggableScrollableSheet(
      expand: false,
      // 初期のModalSheetの高さ
      initialChildSize: 0.42,
      minChildSize: 0.15,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? Colors.black : Colors.white;
        final handleColor = isDark ? Colors.white54 : Colors.grey[300];
        final t = Translations.of(context);
        final slivers = <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => ref
                      .read(mapViewModelProvider.notifier)
                      .setNearbySearchCenterFromCamera(),
                  icon: const Icon(Icons.search, size: 18),
                  label: Text(
                    t.searchNearbyPlaces,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                      child: MapEmptyNearby(),
                    ),
                  );
                }
                final grouped = _groupByRestaurantName(posts);
                if (grouped.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: MapEmptyNearby(),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final group = grouped[index];
                        final supabase = ref.watch(supabaseProvider);
                        final postsForRestaurant = group.posts;
                        final thumbUrls = postsForRestaurant
                            .expand((p) => p.foodImageList)
                            .map(
                              (path) => path.isEmpty
                                  ? null
                                  : supabase.storage
                                      .from('food')
                                      .getPublicUrl(path),
                            )
                            .toList();
                        final hasMultiplePosts = postsForRestaurant.length > 1;
                        return InkWell(
                          onTap: () async {
                            await ref
                                .read(mapViewModelProvider.notifier)
                                .animateToLatLng(
                                  lat: group.lat,
                                  lng: group.lng,
                                );
                            ref.read(mapModalSelectionProvider.notifier).state =
                                MapModalSelection(
                              name: group.name,
                              lat: group.lat,
                              lng: group.lng,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 写真
                                  SizedBox(
                                    height: 100,
                                    width: double.infinity,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: _RestaurantThumbnail(
                                            thumbUrls: thumbUrls,
                                            isDark: isDark,
                                          ),
                                        ),
                                        if (hasMultiplePosts)
                                          Positioned(
                                            right: 8,
                                            top: 6,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(
                                                  alpha: 0.6,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.collections,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // 店名 + 星
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      10,
                                      12,
                                      10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          group.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Builder(
                                          builder: (context) {
                                            final stars = postsForRestaurant
                                                .map((e) => e.star)
                                                .where((s) => s > 0)
                                                .toList();
                                            final avg = stars.isEmpty
                                                ? null
                                                : (stars.reduce(
                                                      (a, b) => a + b,
                                                    ) /
                                                    stars.length);
                                            if (avg == null) {
                                              return const SizedBox.shrink();
                                            }
                                            return Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Color(0xFFFFC107),
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  avg.toStringAsFixed(1),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black87,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: grouped.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: SizedBox(
                  height: 400,
                  child: AppNearbyRestaurantsSkeleton(),
                ),
              ),
              error: (_, __) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: MapErrorWidget(
                    onRetry: () async {
                      if (cameraCenter != null) {
                        final _ = ref.refresh(
                          map_repo.getNearByPostsProvider(cameraCenter),
                        );
                      }
                    },
                  ),
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
}

/// 「同じレストラン」とみなすために、店名と座標の近さでグループ化する。
List<RestaurantGroup> _groupByRestaurantName(List<Posts> posts) {
  const threshold = 0.0003; // 約 30m 前後を想定
  final groups = <RestaurantGroup>[];
  for (final p in posts) {
    final name = p.restaurant.trim();
    // 既存グループの中から「同じ店」とみなせるものを探す
    final existingIndex = groups.indexWhere(
      (g) =>
          g.name.trim() == name &&
          (p.lat - g.lat).abs() <= threshold &&
          (p.lng - g.lng).abs() <= threshold,
    );
    if (existingIndex == -1) {
      // 見つからなければ新しくグループを作成
      groups.add(
        RestaurantGroup(
          name: name,
          lat: p.lat,
          lng: p.lng,
          posts: [p],
        ),
      );
    } else {
      // 既存グループに投稿を追加（不変オブジェクトなので新しく作り直す）
      final existing = groups[existingIndex];
      final updatedPosts = [...existing.posts, p];
      groups[existingIndex] = RestaurantGroup(
        name: existing.name,
        lat: existing.lat,
        lng: existing.lng,
        posts: updatedPosts,
      );
    }
  }

  return groups;
}

class _RestaurantThumbnail extends StatelessWidget {
  const _RestaurantThumbnail({
    required this.thumbUrls,
    required this.isDark,
  });

  final List<String?> thumbUrls;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final hasMultiple = thumbUrls.length > 1;

    Widget buildImageContent() {
      if (thumbUrls.isEmpty) {
        return Image.asset(
          isDark ? Assets.image.emptyDark.path : Assets.image.empty.path,
          fit: BoxFit.cover,
        );
      }

      if (thumbUrls.length == 1) {
        final url = thumbUrls.first;
        if (url == null) {
          return Image.asset(
            isDark ? Assets.image.emptyDark.path : Assets.image.empty.path,
            fit: BoxFit.cover,
          );
        }
        return CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Image.asset(
            isDark ? Assets.image.emptyDark.path : Assets.image.empty.path,
            fit: BoxFit.cover,
          ),
        );
      }

      // 2枚以上 → PageView でスワイプ
      return PageView.builder(
        itemCount: thumbUrls.length,
        itemBuilder: (context, pageIndex) {
          final url = thumbUrls[pageIndex];
          if (url == null) {
            return Image.asset(
              isDark ? Assets.image.emptyDark.path : Assets.image.empty.path,
              fit: BoxFit.cover,
            );
          }
          return CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Image.asset(
              isDark ? Assets.image.emptyDark.path : Assets.image.empty.path,
              fit: BoxFit.cover,
            ),
          );
        },
      );
    }

    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(child: buildImageContent()),
          if (hasMultiple)
            Positioned(
              right: 8,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.collections,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
