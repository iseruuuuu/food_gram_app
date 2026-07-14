import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';

/// マップのカテゴリフィルター
/// mainCategory が null のとき全カテゴリ表示
/// subTagId が null のとき大カテゴリ全体、非 null のとき特定サブタグのみ
typedef MapCategoryFilter = ({String? mainCategory, String? subTagId});

final mapCategoryFilterProvider = StateProvider<MapCategoryFilter>(
  (ref) => (mainCategory: null, subTagId: null),
);

final filteredMapPostsProvider = Provider<AsyncValue<List<Posts>>>((ref) {
  final filter = ref.watch(mapCategoryFilterProvider);
  final postsAsync = ref.watch(mapRepositoryProvider);
  return postsAsync.whenData(
    (posts) => filter.mainCategory == null
        ? posts
        : posts.where((post) => _postMatchesFilter(filter, post)).toList(),
  );
});

bool _postMatchesFilter(MapCategoryFilter filter, Posts post) {
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
