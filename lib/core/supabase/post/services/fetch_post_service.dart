import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'fetch_post_service.g.dart';

/// 保存した投稿 ID 列から `posts` 行を取得する
Future<List<Map<String, dynamic>>> fetchStoredPostRowsForIds(
  SupabaseClient supabase,
  List<String> postIds,
) async {
  if (postIds.isEmpty) {
    return [];
  }
  final intIds =
      postIds.map(int.tryParse).whereType<int>().toList(growable: false);
  if (intIds.isEmpty) {
    return [];
  }
  final sortedIds = List<int>.from(intIds)..sort();
  // 表示順は呼び出し側の ID 列で決める。.order は通知取得と同形のクエリに寄せる。
  return CacheManager().get<List<Map<String, dynamic>>>(
    key: 'saved_posts_${sortedIds.join('_')}',
    fetcher: () async {
      final rows =
          await supabase.from('posts').select().inFilter('id', sortedIds);
      final out = <Map<String, dynamic>>[];
      for (final row in rows) {
        out.add(Map<String, dynamic>.from(row as Map));
      }
      return out;
    },
    duration: const Duration(minutes: 5),
  );
}

@riverpod
class FetchPostService extends _$FetchPostService {
  @override
  Future<void> build() async {}

  final logger = Logger();
  final _cacheManager = CacheManager();

  SupabaseClient get supabase => ref.read(supabaseProvider);

  List<String> get blockList =>
      ref.watch(blockListProvider).asData?.value ?? [];

  /// 全ての投稿を取得
  Future<List<Map<String, dynamic>>> getPosts() async {
    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'all_posts',
      fetcher: () =>
          supabase.from('posts').select().order('created_at', ascending: false),
      duration: const Duration(minutes: 2),
    );
  }

  /// 特定ユーザーの投稿を取得
  Future<List<Map<String, dynamic>>> getPostsFromUser(String userId) async {
    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'user_posts_$userId',
      fetcher: () => supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .eq('is_anonymous', false)
          .order('created_at', ascending: false),
      duration: const Duration(minutes: 5),
    );
  }

  /// 保存した投稿IDのリストから投稿を取得
  Future<List<Map<String, dynamic>>> getStoredPosts(
    List<String> postIds,
  ) async {
    return fetchStoredPostRowsForIds(supabase, postIds);
  }

  /// レストラン名で投稿を取得（新しい順）
  Future<List<Map<String, dynamic>>> getPostsByRestaurantName(
    String restaurant,
  ) async {
    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'restaurant_name_posts_$restaurant',
      fetcher: () async {
        final posts = await supabase
            .from('posts')
            .select()
            .eq('restaurant', restaurant)
            .order('created_at', ascending: false);
        return posts
            .where((post) => !blockList.contains(post['user_id']))
            .toList();
      },
      duration: const Duration(minutes: 5),
    );
  }
}
