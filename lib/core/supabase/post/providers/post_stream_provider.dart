import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_stream_provider.g.dart';

/// 投稿のキャッシュを保持するプロバイダー
final postCacheProvider =
    StateProvider<List<Map<String, dynamic>>>((ref) => []);

/// フード全体の投稿のストリームを提供
@riverpod
Stream<List<Map<String, dynamic>>> postStream(Ref ref) {
  final blockList = ref.watch(blockListProvider).asData?.value ?? [];
  final cachedPosts = ref.watch(postCacheProvider);

  if (cachedPosts.isNotEmpty) {
    return Stream.value(cachedPosts);
  }

  return _filteredPostStream(null, blockList, ref).map((posts) {
    ref.read(postCacheProvider.notifier).state = posts;
    return posts;
  });
}

/// 自分の投稿のストリームを提供
@riverpod
Stream<List<Map<String, dynamic>>> myPostStream(Ref ref) {
  final supabase = ref.read(supabaseProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const Stream.empty();
  }
  return supabase
      .from('posts')
      .stream(primaryKey: ['id'])
      .eq('user_id', user)
      .order('created_at');
}

/// 投稿のストリームをフィルタリングするヘルパー関数
Stream<List<Map<String, dynamic>>> _filteredPostStream(
  String? restaurantFilter,
  List<String> blockList,
  Ref ref,
) {
  final supabase = ref.read(supabaseProvider);
  final query = supabase.from('posts').stream(primaryKey: ['id']);
  if (restaurantFilter != null) {
    query.eq('restaurant', restaurantFilter);
  } else {
    query.neq('restaurant', '自炊');
  }
  return query.order('created_at').asyncMap(
        (events) => events.where((post) {
          return !blockList.contains(post['user_id']);
        }).toList(),
      );
}

/// カテゴリー内の全ての絵文字を対象にフィルタリングするプロバイダー
@riverpod
Stream<List<Map<String, dynamic>>> postStreamByCategory(
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
        final foodTag = post['food_tag'] as String;
        return foodEmojis.contains(foodTag);
      }).toList(),
    );
  }

  // レストランが'自炊'でなく、全ての投稿を取得
  final query = supabase
      .from('posts')
      .stream(primaryKey: ['id'])
      .neq('restaurant', '自炊')
      .order('created_at');

  return query.asyncMap(
    (events) {
      // ブロックリストでフィルタリング
      final filtered = events.where((post) {
        return !blockList.contains(post['user_id']);
      }).toList();

      // カテゴリー名が空でない場合は、そのカテゴリーに含まれる全ての絵文字でフィルタリング
      if (categoryName.isNotEmpty) {
        // foodCategoryからそのカテゴリーに属する絵文字リストを取得
        final foodEmojis = foodCategory[categoryName] ?? [];

        // カテゴリー内のいずれかの絵文字を含む投稿をフィルタリング
        return filtered.where((post) {
          final foodTag = post['food_tag'] as String;
          return foodEmojis.contains(foodTag);
        }).toList();
      }

      // キャッシュを更新
      ref.read(postCacheProvider.notifier).state = filtered;
      return filtered;
    },
  );
}
