import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'fetch_post_service.g.dart';

@riverpod
class FetchPostService extends _$FetchPostService {
  @override
  Future<void> build() async {}

  final logger = Logger();
  final _cacheManager = CacheManager();

  String? get _currentUserId => ref.read(currentUserProvider);

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

  /// 自分の全投稿に対するいいね数の合計を取得
  Future<int> getHeartAmount() async {
    if (_currentUserId == null) {
      return 0;
    }
    return _cacheManager.get<int>(
      key: 'heart_amount_${_currentUserId!}',
      fetcher: () async {
        final response = await supabase
            .from('posts')
            .select('heart')
            .eq('user_id', _currentUserId!);
        return response.fold<int>(
          0,
          (sum, post) => sum + ((post['heart'] as int?) ?? 0),
        );
      },
      duration: const Duration(minutes: 2),
    );
  }

  /// 特定ユーザーの投稿のいいねの合計数を取得
  Future<int> getOtherHeartAmount(String userId) async {
    return _cacheManager.get<int>(
      key: 'heart_amount_$userId',
      fetcher: () async {
        final response =
            await supabase.from('posts').select('heart').eq('user_id', userId);
        return response.fold<int>(
          0,
          (sum, post) => sum + ((post['heart'] as int?) ?? 0),
        );
      },
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
    if (postIds.isEmpty) {
      return [];
    }
    // 数値IDへ変換（無効なIDは除外）
    final intIds =
        postIds.map(int.tryParse).whereType<int>().toList(growable: false);
    if (intIds.isEmpty) {
      return [];
    }
    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'saved_posts_${intIds.join('_')}',
      fetcher: () => supabase
          .from('posts')
          .select()
          .inFilter('id', intIds)
          .order('created_at', ascending: false),
      duration: const Duration(minutes: 5),
    );
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
