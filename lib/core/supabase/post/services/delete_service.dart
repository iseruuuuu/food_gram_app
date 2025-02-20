import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/env.dart';
import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'delete_service.g.dart';

@riverpod
class DeleteService extends _$DeleteService {
  final _cacheManager = CacheManager();

  String? get _currentUserId => ref.read(currentUserProvider);

  SupabaseClient get supabase => ref.read(supabaseProvider);

  @override
  Future<void> build() async {}

  Future<Result<void, Exception>> delete(Posts post) async {
    if (_currentUserId == null) {
      return Failure(Exception('User not authenticated'));
    }
    try {
      if (!_canDelete(post.userId)) {
        return Failure(Exception('Not authorized to delete this post'));
      }
      await _deletePostImage(post.foodImage);
      await _deletePostData(post.id);

      // 投稿削除後、関連する全てのキャッシュを無効化
      _invalidateRelatedCaches(post);

      return const Success(null);
    } on PostgrestException catch (e) {
      logger.e('Failed to delete post: ${e.message}');
      return Failure(e);
    }
  }

  /// 自分の投稿またはマスターアカウントのみ削除可能
  bool _canDelete(String postUserId) {
    final isMaster = _currentUserId == Env.masterAccount;
    return postUserId == _currentUserId || isMaster;
  }

  Future<void> _deletePostImage(String foodImage) async {
    try {
      /// 先頭の'/'を削除し、二重スラッシュを単一スラッシュに置換
      final imagePath = foodImage.substring(1).replaceAll('//', '/');
      await supabase.storage.from('food').remove([imagePath]);
      //TODO おそらく、管理者が消そうとすると、ストレージの削除ができていない気がする
      //TODO 理由としては、Policiesの問題
    } on PostgrestException catch (e) {
      logger.e('Failed to delete image: $e');
    }
  }

  Future<void> _deletePostData(int postId) async {
    await supabase.from('posts').delete().eq('id', postId);
  }

  /// 投稿削除時に関連する全てのキャッシュを無効化
  void _invalidateRelatedCaches(Posts post) {
    // 全体の投稿リストに関連するキャッシュを無効化
    _cacheManager
      ..invalidate('all_posts')
      ..invalidate('map_posts')
      ..invalidate('ramen_posts')

      // 特定の投稿に関連するキャッシュを無効化
      ..invalidate('post_data_${post.id}')

      // 投稿者のユーザー関連キャッシュを無効化
      ..invalidate('user_posts_${post.userId}')
      ..invalidate('heart_amount_${post.userId}')

      // 位置情報に関連するキャッシュを無効化
      ..invalidate('restaurant_posts_${post.lat}_${post.lng}')
      ..invalidate('nearby_posts_${post.lat}_${post.lng}');

    // マスターアカウントによる削除の場合、追加のキャッシュクリアが必要かもしれない
    if (_currentUserId == Env.masterAccount) {
      _cacheManager.clearAll();
    }
  }
}
