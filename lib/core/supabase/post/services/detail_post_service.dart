import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'detail_post_service.g.dart';

@riverpod
class DetailPostService extends _$DetailPostService {
  final _cacheManager = CacheManager();

  SupabaseClient get supabase => ref.read(supabaseProvider);

  List<String> get blockList =>
      ref.watch(blockListProvider).asData?.value ?? [];

  @override
  Future<void> build() async {}

  /// 特定の投稿を取得
  Future<Result<Map<String, dynamic>, Exception>> getPost(int postId) async {
    try {
      return Success(
        await _cacheManager.get<Map<String, dynamic>>(
          key: 'post_data_$postId',
          fetcher: () async {
            final postData =
                await supabase.from('posts').select().eq('id', postId).single();
            final userData = await supabase
                .from('users')
                .select()
                .eq('user_id', postData['user_id'] as String)
                .single();
            return {
              'post': postData,
              'user': userData,
            };
          },
          duration: const Duration(minutes: 5),
        ),
      );
    } on PostgrestException catch (e) {
      return Failure(e);
    }
  }

  /// 特定ユーザーの投稿を取得（ページング対応・新しい順）
  Future<List<Map<String, dynamic>>> getPostsFromUserPaged(
    String userId, {
    int limit = 30,
    int? beforeId,
  }) async {
    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'user_posts_paged_${userId}_${beforeId ?? 'null'}_$limit',
      fetcher: () async {
        var query = supabase
            .from('posts')
            .select()
            .eq('user_id', userId)
            .eq('is_anonymous', false);
        if (beforeId != null) {
          query = query.lt('id', beforeId);
        }
        final posts = await query.order('id', ascending: false).limit(limit);
        return posts
            .where((post) => !blockList.contains(post['user_id']))
            .toList();
      },
      duration: const Duration(minutes: 2),
    );
  }

  /// ユーザーデータを取得
  Future<Map<String, dynamic>> getUserData(String userId) async {
    return _cacheManager.get<Map<String, dynamic>>(
      key: 'user_data_$userId',
      fetcher: () =>
          supabase.from('users').select().eq('user_id', userId).single(),
      duration: const Duration(minutes: 10),
    );
  }

  /// 指定した投稿IDより新しい投稿のリストを取得する
  Future<Result<List<Map<String, dynamic>>, Exception>> getSequentialPosts({
    required int currentPostId,
    int limit = 15,
  }) async {
    try {
      final nextPosts = await supabase
          .from('posts')
          .select()
          .gt('id', currentPostId)
          .order('id', ascending: true)
          .limit(limit);
      final prevPosts = await supabase
          .from('posts')
          .select()
          .lt('id', currentPostId)
          .order('id', ascending: false)
          .limit(limit);
      final result = <Map<String, dynamic>>[...nextPosts];
      if (result.length < limit) {
        result.addAll(prevPosts.take(limit - result.length));
      }
      return Success(result.take(limit).toList());
    } on PostgrestException catch (e) {
      return Failure(e);
    }
  }

  /// 指定した投稿IDと同じレストランの投稿のリストを取得する
  Future<Result<List<Map<String, dynamic>>, Exception>> getRelatedPosts({
    required int currentPostId,
    required double lat,
    required double lng,
  }) async {
    try {
      final posts = await supabase
          .from('posts')
          .select()
          .neq('id', currentPostId)
          .gte('lat', lat - 0.00001)
          .lte('lat', lat + 0.00001)
          .gte('lng', lng - 0.00001)
          .lte('lng', lng + 0.00001)
          .order('created_at', ascending: false)
          .limit(15);
      return Success(posts);
    } on PostgrestException catch (e) {
      return Failure(e);
    }
  }
}
