import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_stream_provider.g.dart';

/// 全取得・カテゴリーごとの取得のためのStreamProvider
@riverpod
Stream<List<Posts>> postsStream(
  Ref ref,
  String categoryName,
) {
  final blockList = ref.watch(blockListProvider).asData?.value ?? [];
  final supabase = ref.read(supabaseProvider);
  final query =
      supabase.from('posts').stream(primaryKey: ['id']).order('created_at');
  return query.asyncMap(
    (events) {
      final mapped = events.map(Posts.fromJson).toList();
      final filtered =
          mapped.where((post) => !blockList.contains(post.userId)).toList();
      if (categoryName.isNotEmpty) {
        final foodEmojis = foodCategory[categoryName] ?? [];
        final result = filtered
            .where((post) => foodEmojis.contains(post.foodTag))
            .toList();
        return result;
      }
      return filtered;
    },
  );
}

/// 自分の投稿の取得のためのStreamProvider
@riverpod
Stream<List<Posts>> myPostStream(Ref ref) {
  final supabase = ref.read(supabaseProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const Stream<List<Posts>>.empty();
  }
  return supabase
      .from('posts')
      .stream(primaryKey: ['id'])
      .eq('user_id', user)
      .order('created_at')
      .map((events) => events.map(Posts.fromJson).toList());
}
