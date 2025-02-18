import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_service.g.dart';

@riverpod
class UserService extends _$UserService {
  final _cacheManager = CacheManager();

  String get _currentUserId {
    final userId = ref.read(currentUserProvider);
    if (userId == null) {
      throw Exception('User is not logged in');
    }
    return userId;
  }

  SupabaseClient get supabase => ref.read(supabaseProvider);

  @override
  Future<void> build() async {}

  /// 自分のユーザー情報を取得
  Future<Map<String, dynamic>> getCurrentUser() async {
    return _cacheManager.get<Map<String, dynamic>>(
      key: 'user_$_currentUserId',
      fetcher: () => supabase
          .from('users')
          .select()
          .eq('user_id', _currentUserId)
          .single(),
    );
  }

  /// 他のユーザー情報を取得
  Future<Map<String, dynamic>> getOtherUser(String userId) async {
    return _cacheManager.get<Map<String, dynamic>>(
      key: 'user_$userId',
      fetcher: () =>
          supabase.from('users').select().eq('user_id', userId).single(),
    );
  }

  /// 自分のユーザーの投稿数を取得
  Future<int> getCurrentUserPostCount() async {
    return _cacheManager.get<int>(
      key: 'post_count_$_currentUserId',
      fetcher: () async {
        final response =
            await supabase.from('posts').select().eq('user_id', _currentUserId);
        return response.length;
      },

      /// 投稿数は頻繁に変わる可能性があるため、短めの期間を設定
      duration: const Duration(minutes: 2),
    );
  }

  /// 指定したユーザーの投稿数を取得
  Future<int> getOtherUserPostCount(String userId) async {
    return _cacheManager.get<int>(
      key: 'post_count_$userId',
      fetcher: () async {
        final response =
            await supabase.from('posts').select().eq('user_id', userId);
        return response.length;
      },

      /// 投稿数は頻繁に変わる可能性があるため、短めの期間を設定
      duration: const Duration(minutes: 2),
    );
  }

  /// 投稿から指定したユーザー情報を取得
  Future<Map<String, dynamic>> getUserFromPost(Posts post) async {
    return supabase.from('users').select().eq('user_id', post.userId).single();
  }

  /// キャッシュを無効化するメソッド
  void invalidateUserCache(String userId) {
    _cacheManager.invalidate('user_$userId');
  }

  void invalidatePostCountCache(String userId) {
    _cacheManager.invalidate('post_count_$userId');
  }
}
