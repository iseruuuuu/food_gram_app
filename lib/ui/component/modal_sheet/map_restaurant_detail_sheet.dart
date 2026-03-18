import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant_group.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/repository/user_repository.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_error_widget.dart';
import 'package:food_gram_app/ui/component/common/app_skeleton.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_map_restaurant_overview_modal_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// マップ画面から投稿を選択したときに表示する詳細のモーダル
class MapRestaurantDetailSheet extends HookConsumerWidget {
  const MapRestaurantDetailSheet({super.key});

  /// Repository経由で特定店舗（位置）の投稿を取得
  static final restaurantPostsProvider =
      FutureProvider.family<List<Posts>, (String, double, double)>(
    (ref, key) async {
      final (_, lat, lng) = key;
      final repo = ref.read(mapPostRepositoryProvider.notifier);
      final result = await repo.getRestaurantPosts(lat: lat, lng: lng);
      return result.when(
        success: (data) => data,
        failure: (_) => <Posts>[],
      );
    },
  );

  /// 選択中店舗に紐づく投稿と関連ストリームをまとめてリフレッシュ
  void _refreshRestaurantPosts(WidgetRef ref, MapModalSelection selection) {
    ref
      ..invalidate(
        MapRestaurantDetailSheet.restaurantPostsProvider(
          (selection.name, selection.lat, selection.lng),
        ),
      )
      ..invalidate(postsStreamProvider)
      ..invalidate(blockListProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(mapModalSelectionProvider);
    if (selection == null) {
      return const AppMapRestaurantOverviewModalSheet();
    }
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
        final postsAsync = ref.watch(
          MapRestaurantDetailSheet.restaurantPostsProvider(
            (selection.name, selection.lat, selection.lng),
          ),
        );
        final supabase = ref.watch(supabaseProvider);

        final slivers = <Widget>[
          // ドラッグハンドル
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
          // レストラン名 + 右上バツボタン（常に表示）
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selection.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: sheetFg,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref
                        .read(
                          mapModalSelectionProvider.notifier,
                        )
                        .state = null,
                    icon: Icon(
                      Icons.close,
                      color: sheetFg,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 投稿一覧（selection + restaurantPostsProvider にのみ依存）
          postsAsync.when(
            data: (postsByRestaurant) {
              if (postsByRestaurant.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: MapEmptyNearby(),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final postItem = postsByRestaurant[index];
                      final firstImage =
                          postItem.firstFoodImage; // 拡張から取得
                      final imageUrl = firstImage.isEmpty
                          ? null
                          : supabase.storage
                              .from('food')
                              .getPublicUrl(firstImage);
                      return GestureDetector(
                        onTap: () {
                          EasyDebounce.debounce(
                            'click map sheet detail grid',
                            Duration.zero,
                            () async {
                              final userResult = await ref
                                  .read(
                                    userRepositoryProvider.notifier,
                                  )
                                  .getUserFromPost(postItem);
                              await userResult.whenOrNull(
                                success: (postUsers) async {
                                  final model = Model(postUsers, postItem);
                                  await context
                                      .pushNamed(
                                    RouterPath.mapDetail,
                                    extra: model,
                                  )
                                      .then((value) {
                                    if (value != null) {
                                      _refreshRestaurantPosts(
                                        ref,
                                        selection,
                                      );
                                    }
                                  });
                                },
                              );
                            },
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imageUrl == null
                              ? Image.asset(
                                  isDark
                                      ? Assets.image.emptyDark.path
                                      : Assets.image.empty.path,
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Image.asset(
                                    isDark
                                        ? Assets.image.emptyDark.path
                                        : Assets.image.empty.path,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      );
                    },
                    childCount: postsByRestaurant.length,
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
                  onRetry: () {
                    _refreshRestaurantPosts(ref, selection);
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
