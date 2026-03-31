import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';

/// null: 全カテゴリ表示
final selectedMapCategoryProvider = StateProvider<String?>((ref) => null);

final filteredMapPostsProvider = Provider<AsyncValue<List<Posts>>>((ref) {
  final selectedCategory = ref.watch(selectedMapCategoryProvider);
  final postsAsync = ref.watch(mapRepositoryProvider);
  return postsAsync.whenData(
    (posts) => selectedCategory == null
        ? posts
        : posts
            .where((post) => _postMatchesCategory(post, selectedCategory))
            .toList(),
  );
});

bool _postMatchesCategory(Posts post, String selectedCategory) {
  final categoryEmojis = foodCategory[selectedCategory];
  if (categoryEmojis == null || categoryEmojis.isEmpty) {
    return false;
  }
  if (post.foodTag.trim().isEmpty) {
    return false;
  }

  final tags =
      post.foodTag.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
  for (final tag in tags) {
    if (categoryEmojis.contains(tag)) {
      return true;
    }
  }
  return false;
}
