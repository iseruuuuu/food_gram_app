import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/config/constants/map_overlay_constants.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant_group.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/map_category_filter_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart'
    as map_repo;
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_skeleton.dart';
import 'package:food_gram_app/ui/component/common/app_tab_error.dart';
import 'package:food_gram_app/ui/screen/map/components/map_category_chip_bar.dart';
import 'package:food_gram_app/ui/screen/map/map_view_model.dart';
import 'package:food_gram_app/ui/screen/tab/tab_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// ピン/一覧タップでモーダル内表示を切り替えるための選択状態
final mapModalSelectionProvider =
    StateProvider<MapModalSelection?>((ref) => null);

/// マップ画面の「最初のモーダル」（近くのレストラン一覧）を表示するシート。
class MapRestaurantOverviewModalSheet extends ConsumerWidget {
  const MapRestaurantOverviewModalSheet({super.key});

  /// ボトムナビより少し高い、常時表示のシート高さ（画面比）
  static double openSheetSize(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    if (screenHeight <= 0) {
      return MapOverlayConstants.overviewCollapsedSize;
    }
    final size = (TabScreen.bottomNavOccupiedHeight(context) +
            MapOverlayConstants.overviewOpenPeekPx) /
        screenHeight;
    return size.clamp(
      MapOverlayConstants.overviewCollapsedSize,
      MapOverlayConstants.overviewExpandedSize,
    );
  }

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

    final sheetSize = openSheetSize(context);
    final minChildSize = (TabScreen.bottomNavHeightFraction(context) + 0.04)
        .clamp(0.08, sheetSize);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: sheetSize,
      minChildSize: minChildSize,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? Colors.black : Colors.white;
        final handleColor = isDark ? Colors.white54 : Colors.grey[300];
        final t = Translations.of(context);
        final slivers = <Widget>[
          SliverToBoxAdapter(
            child: SizedBox(
              width: double.infinity,
              height: 36,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MapCategoryChipBar(
              onCategoryChanged: () => ref
                  .read(mapViewModelProvider.notifier)
                  .refreshPinsForCategoryFilter(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
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
            ),
          if (nearbyAsync != null)
            nearbyAsync.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: MapEmpty(),
                    ),
                  );
                }
                final grouped = _groupByRestaurantName(posts);
                final filter = ref.watch(mapCategoryFilterProvider);
                final filteredGroups = grouped
                    .map(
                      (g) => RestaurantGroup(
                        name: g.name,
                        lat: g.lat,
                        lng: g.lng,
                        posts: g.posts
                            .where((p) => postMatchesMapFilter(filter, p))
                            .toList(),
                      ),
                    )
                    .where((g) => g.posts.isNotEmpty)
                    .toList();
                if (filteredGroups.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: MapEmpty(),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final group = filteredGroups[index];
                        final supabase = ref.watch(supabaseProvider);
                        final postsForRestaurant = group.posts;
                        final firstPath = postsForRestaurant.isEmpty
                            ? ''
                            : group.representativePost.firstFoodImage;
                        final imageUrl = firstPath.isEmpty
                            ? null
                            : supabase.storage
                                .from('food')
                                .getPublicUrl(firstPath);
                        final extraCount = postsForRestaurant.length > 1
                            ? postsForRestaurant.length - 1
                            : 0;
                        final onSurface = isDark ? Colors.white : Colors.black;
                        final muted = isDark ? Colors.white70 : Colors.black54;
                        return InkWell(
                          onTap: () async {
                            await ref
                                .read(mapViewModelProvider.notifier)
                                .animateToLatLng(
                                  lat: group.lat,
                                  lng: group.lng,
                                  keepZoom: true,
                                  focusAboveSheet: true,
                                );
                            ref.read(mapModalSelectionProvider.notifier).state =
                                MapModalSelection(
                              name: group.name,
                              lat: group.lat,
                              lng: group.lng,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        if (imageUrl == null)
                                          Image.asset(
                                            isDark
                                                ? Assets.image.emptyDark.path
                                                : Assets.image.empty.path,
                                            fit: BoxFit.cover,
                                          )
                                        else
                                          CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.cover,
                                            errorWidget: (_, __, ___) =>
                                                Image.asset(
                                              isDark
                                                  ? Assets.image.emptyDark.path
                                                  : Assets.image.empty.path,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        if (extraCount > 0)
                                          Positioned(
                                            right: 6,
                                            bottom: 6,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(
                                                  alpha: 0.62,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '+$extraCount',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        group.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (group.posts.isNotEmpty &&
                                          group.representativePost.foodName
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          group.representativePost.foodName,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: muted,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      if (group.averageStar != null) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star_rounded,
                                              color: Color(0xFFFFC107),
                                              size: 18,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              group.averageStar!
                                                  .toStringAsFixed(1),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: onSurface,
                                                fontWeight: FontWeight.w600,
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
                        );
                      },
                      childCount: filteredGroups.length,
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
                  child: AppTabError.map(
                    compact: true,
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: CustomScrollView(
              controller: scrollController,
              primary: false,
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              slivers: slivers,
            ),
          ),
        );
      },
    );
  }
}

/// 「同じレストラン」とみなすために、店名と座標の近さでグループ化する。
/// 代表投稿が最新になるよう、先に createdAt 降順へ揃えてからまとめる。
List<RestaurantGroup> _groupByRestaurantName(List<Posts> posts) {
  const threshold = 0.0003; // 約 30m 前後を想定
  final newestFirst = [...posts]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final groups = <RestaurantGroup>[];
  for (final p in newestFirst) {
    final name = p.restaurant.trim();
    // 既存グループの中から「同じ店」とみなせるものを探す
    final existingIndex = groups.indexWhere(
      (g) =>
          g.name.trim() == name &&
          (p.lat - g.lat).abs() <= threshold &&
          (p.lng - g.lng).abs() <= threshold,
    );
    if (existingIndex == -1) {
      groups.add(
        RestaurantGroup(
          name: name,
          lat: p.lat,
          lng: p.lng,
          posts: [p],
        ),
      );
    } else {
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
