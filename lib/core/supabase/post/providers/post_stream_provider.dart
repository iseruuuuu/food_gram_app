import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_stream_provider.g.dart';

/// 投稿のキャッシュを保持するプロバイダー
final postCacheProvider = StateProvider<List<Posts>>((ref) => []);

/// カテゴリー内の全ての絵文字を対象にフィルタリングするプロバイダー
@riverpod
Stream<List<Posts>> postsStream(
  Ref ref,
  String categoryName,
) {
  final blockList = ref.watch(blockListProvider).asData?.value ?? [];
  final supabase = ref.read(supabaseProvider);
  final cachedPosts = ref.watch(postCacheProvider);

  // キャッシュされた投稿がある場合は、それを使用
  if (cachedPosts.isNotEmpty) {
    return Stream.value(
      cachedPosts.where((post) {
        if (categoryName.isEmpty) {
          return true;
        }
        final foodEmojis = foodCategory[categoryName] ?? [];
        return foodEmojis.contains(post.foodTag);
      }).toList(),
    );
  }

  // 全ての投稿を取得
  final query =
      supabase.from('posts').stream(primaryKey: ['id']).order('created_at');
  return query.asyncMap(
    (events) {
      // ブロックリストでフィルタリング（Mapのまま）
      final filtered = events.where((post) {
        return !blockList.contains(post['user_id']);
      }).toList();

      // 型変換
      final typed = filtered.map(Posts.fromJson).toList();

      // カテゴリー名が空でない場合は、そのカテゴリーに含まれる全ての絵文字でフィルタリング
      if (categoryName.isNotEmpty) {
        final foodEmojis = foodCategory[categoryName] ?? [];
        final result =
            typed.where((post) => foodEmojis.contains(post.foodTag)).toList();
        // キャッシュを更新
        ref.read(postCacheProvider.notifier).state = result;
        return result;
      }

      // キャッシュを更新
      ref.read(postCacheProvider.notifier).state = typed;
      return typed;
    },
  );
}

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
