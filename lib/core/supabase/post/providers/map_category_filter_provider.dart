import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';

/// マップのカテゴリフィルター
/// mainCategory が null のとき全カテゴリ表示
/// subTagId が null のとき大カテゴリ全体、非 null のとき特定サブタグのみ
typedef MapCategoryFilter = ({String? mainCategory, String? subTagId});

final mapCategoryFilterProvider = StateProvider<MapCategoryFilter>(
  (ref) => (mainCategory: null, subTagId: null),
);

/// true のときマップピン・一覧を自分の投稿だけにする
final mapMyPostsOnlyProvider = StateProvider<bool>((ref) => false);

final filteredMapPostsProvider = Provider<AsyncValue<List<Posts>>>((ref) {
  final filter = ref.watch(mapCategoryFilterProvider);
  final myPostsOnly = ref.watch(mapMyPostsOnlyProvider);
  final currentUserId = ref.watch(currentUserProvider);
  final postsAsync = ref.watch(mapRepositoryProvider);
  return postsAsync.whenData(
    (posts) => posts
        .where(
          (post) => postVisibleOnMap(
            post: post,
            filter: filter,
            myPostsOnly: myPostsOnly,
            currentUserId: currentUserId,
          ),
        )
        .toList(),
  );
});

/// カテゴリと「自分の投稿」フィルターをまとめて判定する
bool postVisibleOnMap({
  required Posts post,
  required MapCategoryFilter filter,
  required bool myPostsOnly,
  required String? currentUserId,
}) {
  if (!postMatchesMapOwner(
    post: post,
    myPostsOnly: myPostsOnly,
    currentUserId: currentUserId,
  )) {
    return false;
  }
  return postMatchesMapFilter(filter, post);
}

/// 「自分の投稿だけ」が ON なら、現在ユーザーの投稿のみ通す
bool postMatchesMapOwner({
  required Posts post,
  required bool myPostsOnly,
  required String? currentUserId,
}) {
  if (!myPostsOnly) {
    return true;
  }
  if (currentUserId == null) {
    return false;
  }
  return post.userId == currentUserId;
}

/// マップのカテゴリ / food_tag フィルターに投稿が合うか
bool postMatchesMapFilter(MapCategoryFilter filter, Posts post) {
  if (filter.mainCategory == null) {
    return true;
  }

  if (filter.subTagId != null) {
    return parseFoodTagIds(post.foodTag).contains(filter.subTagId);
  }

  final categoryTagIds = foodCategory[filter.mainCategory];
  if (categoryTagIds == null || categoryTagIds.isEmpty) {
    return false;
  }
  for (final tag in parseFoodTagIds(post.foodTag)) {
    if (categoryTagIds.contains(tag)) {
      return true;
    }
  }
  return false;
}
