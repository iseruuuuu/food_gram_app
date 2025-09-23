import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/services/delete_service.dart';
import 'package:food_gram_app/env.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_repository.g.dart';

@riverpod
class DeleteRepository extends _$DeleteRepository {
  final logger = Logger();
  final _cacheManager = CacheManager();

  String? get _currentUserId => ref.read(currentUserProvider);
  DeleteService get _deleteService => ref.read(deleteServiceProvider.notifier);

  @override
  Future<void> build() async {}

  /// 投稿を削除（ビジネスロジック）
  Future<Result<void, Exception>> deletePost(Posts post) async {
    if (_currentUserId == null) {
      return Failure(Exception('User not authenticated'));
    }
    try {
      // 削除権限チェック
      if (!_canDelete(post.userId)) {
        return Failure(Exception('Not authorized to delete this post'));
      }
      // Serviceに削除処理を依頼
      final result = await _deleteService.deletePost(post);
      if (result is Success) {
        // キャッシュの無効化
        _cacheManager.invalidateDeleteRelatedCaches(
          postId: post.id,
          userId: post.userId,
          lat: post.lat,
          lng: post.lng,
          currentUserId: _currentUserId,
          masterAccount: Env.masterAccount,
        );
      }
      return result;
    } on Exception catch (e) {
      logger.e('Failed to delete post: $e');
      return Failure(e);
    }
  }

  /// 自分の投稿またはマスターアカウントのみ削除可能
  bool _canDelete(String postUserId) {
    final isMaster = _currentUserId == Env.masterAccount;
    return postUserId == _currentUserId || isMaster;
  }
}
