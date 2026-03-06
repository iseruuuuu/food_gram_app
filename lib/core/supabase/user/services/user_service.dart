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

  /// 特定のユーザー情報を取得
  Future<Map<String, dynamic>> getOtherUser(String userId) async {
    return _cacheManager.get<Map<String, dynamic>>(
      key: 'user_$userId',
      fetcher: () =>
          supabase.from('users').select().eq('user_id', userId).single(),
    );
  }

  /// ユーザーの統計情報を取得(Edge Function 経由)
  Future<Map<String, dynamic>> getUserStats({
    required String userId,
    required bool includeAnonymous,
    int latestLimit = 0,
  }) async {
    final res = await supabase.functions.invoke(
      'user-stats',
      body: {
        'user_id': userId,
        'include_anonymous': includeAnonymous,
        'latest_limit': latestLimit,
      },
    );
    final data = res.data;
    if (data is! Map<String, dynamic> || data['ok'] != true) {
      throw Exception('user-stats failed: $data');
    }
    return data;
  }

  /// 自分の全投稿に対するいいね数の合計を取得（匿名投稿含む）
  Future<int> getCurrentUserHeartAmount() async {
    return _cacheManager.get<int>(
      key: 'heart_amount_${_currentUserId}_incl_anon',
      fetcher: () async {
        final stats = await getUserStats(
          userId: _currentUserId,
          includeAnonymous: true,
        );
        return stats['heartTotal'] as int? ?? 0;
      },
      duration: const Duration(minutes: 2),
    );
  }

  /// 特定ユーザーの投稿のいいねの合計数を取得（匿名投稿除く）
  Future<int> getOtherUserHeartAmount(String userId) async {
    return _cacheManager.get<int>(
      key: 'heart_amount_${userId}_excl_anon',
      fetcher: () async {
        final stats = await getUserStats(
          userId: userId,
          includeAnonymous: false,
        );
        return stats['heartTotal'] as int? ?? 0;
      },
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
}
