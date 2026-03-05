import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/services/heart_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'heart_repository.g.dart';

@riverpod
class HeartRepository extends _$HeartRepository {
  final _cacheManager = CacheManager();

  String? get _currentUserId => ref.read(currentUserProvider);
  HeartService get _heartService => ref.read(heartServiceProvider.notifier);

  @override
  Future<void> build() async {}

  /// いいねを付ける（自分の投稿には不可）
  Future<Result<void, Exception>> incrementHeart(Posts post) async {
    if (_currentUserId == null) {
      return Failure(Exception('User not authenticated'));
    }
    if (post.userId == _currentUserId) {
      return Failure(Exception('Cannot like own post'));
    }
    final result = await _heartService.incrementHeart(post.id);
    if (result is Success) {
      _cacheManager.invalidateUserCache(post.userId);
    }
    return result;
  }

  /// いいねを外す
  Future<Result<void, Exception>> decrementHeart(Posts post) async {
    if (_currentUserId == null) {
      return Failure(Exception('User not authenticated'));
    }
    final result = await _heartService.decrementHeart(post.id);
    if (result is Success) {
      _cacheManager.invalidateUserCache(post.userId);
    }
    return result;
  }
}
