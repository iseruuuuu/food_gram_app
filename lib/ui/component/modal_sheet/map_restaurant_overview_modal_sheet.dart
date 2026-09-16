import 'package:flutter/material.dart';
import 'package:food_gram_app/core/config/constants/map_overlay_constants.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant_group.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/map_category_filter_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart'
    as map_repo;
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/geo_distance.dart';
import 'package:food_gram_app/core/utils/nearby_restaurant_posts.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_skeleton.dart';
import 'package:food_gram_app/ui/component/common/app_tab_error.dart';
import 'package:food_gram_app/ui/screen/map/components/map_area_restaurant_card.dart';
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

  /// しまったときにハンドルがナビ上へ少し出る高さ（画面比）
  static double collapsedSheetSize(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    if (screenHeight <= 0) {
      return MapOverlayConstants.overviewCollapsedSize;
    }
    final size = (TabScreen.bottomNavOccupiedHeight(context) +
            MapOverlayConstants.collapsedPeekPx) /
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
    // カメラ中心は距離ソートにだけ使い、投稿取得はマップと共有する
    final cameraCenter = ref.watch(mapViewModelProvider).cameraCenterLatLng;
    final nearbyAsync = ref.watch(map_repo.mapRepositoryProvider);

    final sheetSize = openSheetSize(context);
    final minChildSize = collapsedSheetSize(context).clamp(0.08, sheetSize);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: sheetSize,
      minChildSize: minChildSize,
      maxChildSize: sheetSize,
      builder: (context, scrollController) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? Colors.black : Colors.white;
        final handleColor = isDark ? Colors.white54 : Colors.grey[300];
        final t = Translations.of(context);
        final slivers = <Widget>[
          SliverToBoxAdapter(
            child: SizedBox(
              width: double.infinity,
              height: 24,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (cameraCenter == null)
            const SliverToBoxAdapter(
              child: AppNearbyRestaurantsSkeleton(),
            )
          else
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
                final filter = ref.watch(mapCategoryFilterProvider);
                final myPostsOnly = ref.watch(mapMyPostsOnlyProvider);
                final currentUserId = ref.watch(currentUserProvider);
                final visiblePosts = posts
                    .where(
                      (p) => postVisibleOnMap(
                        post: p,
                        filter: filter,
                        myPostsOnly: myPostsOnly,
                        currentUserId: currentUserId,
                      ),
                    )
                    .toList();
                final filteredGroups = _groupByRestaurantName(
                  visiblePosts,
                  centerLat: cameraCenter.latitude,
                  centerLng: cameraCenter.longitude,
                ).take(nearbyRestaurantLimit).toList();
                if (filteredGroups.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: MapEmpty(),
                    ),
                  );
                }
                final supabase = ref.watch(supabaseProvider);
                return SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      SizedBox(
                        height: MapAreaRestaurantCard.height,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          primary: false,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredGroups.length,
                          separatorBuilder: (_, __) {
                            return const SizedBox(width: 12);
                          },
                          itemBuilder: (context, index) {
                            final group = filteredGroups[index];
                            final firstPath = group.posts.isEmpty
                                ? ''
                                : group.representativePost.firstFoodImage;
                            final imageUrl = firstPath.isEmpty
                                ? null
                                : supabase.storage
                                    .from('food')
                                    .getPublicUrl(firstPath);
                            return MapAreaRestaurantCard(
                              group: group,
                              imageUrl: imageUrl,
                              onTap: () async {
                                await ref
                                    .read(mapViewModelProvider.notifier)
                                    .animateToLatLng(
                                      lat: group.lat,
                                      lng: group.lng,
                                      keepZoom: true,
                                      focusAboveSheet: true,
                                    );
                                ref
                                    .read(mapModalSelectionProvider.notifier)
                                    .state = MapModalSelection(
                                  name: group.name,
                                  lat: group.lat,
                                  lng: group.lng,
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: AppNearbyRestaurantsSkeleton(),
              ),
              error: (_, __) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AppTabError.map(
                    compact: true,
                    onRetry: () {
                      ref.invalidate(map_repo.mapRepositoryProvider);
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
/// 代表投稿は最新のまま、一覧はカメラ中心から近い店順にする。
List<RestaurantGroup> _groupByRestaurantName(
  List<Posts> posts, {
  required double centerLat,
  required double centerLng,
}) {
  final groups = <RestaurantGroup>[];
  for (final p in posts) {
    final name = p.restaurant.trim();
    // 既存グループの中から「同じ店」とみなせるものを探す
    final existingIndex = groups.indexWhere(
      (g) =>
          g.name.trim() == name &&
          (p.lat - g.lat).abs() <= nearbyRestaurantCoordThreshold &&
          (p.lng - g.lng).abs() <= nearbyRestaurantCoordThreshold,
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
      final updatedPosts = [...existing.posts, p]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      groups[existingIndex] = RestaurantGroup(
        name: existing.name,
        lat: existing.lat,
        lng: existing.lng,
        posts: updatedPosts,
      );
    }
  }

  groups.sort((a, b) {
    final da = _closestDistanceKm(a, centerLat, centerLng);
    final db = _closestDistanceKm(b, centerLat, centerLng);
    return da.compareTo(db);
  });
  return groups;
}

double _closestDistanceKm(
  RestaurantGroup group,
  double centerLat,
  double centerLng,
) {
  var minDistance = double.infinity;
  for (final post in group.posts) {
    final distance = geoKilometers(
      lat1: centerLat,
      lon1: centerLng,
      lat2: post.lat,
      lon2: post.lng,
    );
    if (distance < minDistance) {
      minDistance = distance;
    }
  }
  return minDistance;
}
