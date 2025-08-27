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

  /// 全ユーザー情報を取得
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'all_users',
      fetcher: () async {
        final response = await supabase
            .from('users')
            .select()
            .order('created_at', ascending: false);
        return response;
      },
      duration: const Duration(minutes: 5),
    );
  }

  /// ユーザーの最新投稿を取得(匿名ユーザーを除く)
  Future<List<Map<String, dynamic>>> getUserLatestPosts(String userId) async {
    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'user_latest_posts_$userId',
      fetcher: () async {
        final response = await supabase
            .from('posts')
            .select()
            .eq('user_id', userId)
            .eq('is_anonymous', false)
            .order('created_at', ascending: false);
        return response;
      },
      duration: const Duration(minutes: 2),
    );
  }

  /// ユーザー情報と投稿数を含むデータを取得
  Future<List<Map<String, dynamic>>> getUsersWithPostCount() async {
    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'users_with_post_count_optimized',
      fetcher: () async {
        final postsResponse = await supabase
            .from('posts')
            .select('user_id, food_image, created_at')
            .eq('is_anonymous', false)
            .order('created_at', ascending: false)
            .limit(3000);
        final userIds = <String>{};
        final userPostCounts = <String, int>{};
        final userLatestPosts = <String, List<Map<String, dynamic>>>{};
        for (final post in postsResponse) {
          final userId = post['user_id'] as String;
          userIds.add(userId);
          userPostCounts[userId] = (userPostCounts[userId] ?? 0) + 1;
          // 最新投稿を保存（最大4件まで）
          if (!userLatestPosts.containsKey(userId)) {
            userLatestPosts[userId] = [];
          }
          if (userLatestPosts[userId]!.length < 4) {
            userLatestPosts[userId]!.add({
              'food_image': post['food_image'],
              'created_at': post['created_at'],
            });
          }
        }

        if (userIds.isEmpty) {
          return [];
        }
        final usersResponse = await supabase
            .from('users')
            .select()
            .inFilter('user_id', userIds.toList());
        final usersWithCount = <Map<String, dynamic>>[];
        for (final user in usersResponse) {
          final userId = user['user_id'] as String;
          final postCount = userPostCounts[userId] ?? 0;
          final latestPosts = userLatestPosts[userId] ?? [];
          if (postCount > 0 && latestPosts.isNotEmpty) {
            usersWithCount.add({
              ...user,
              'post_count': postCount,
              'latest_posts': latestPosts,
            });
          }
        }
        usersWithCount.sort(
          (a, b) => (b['post_count'] as int).compareTo(a['post_count'] as int),
        );
        return usersWithCount.take(50).toList();
      },
      duration: const Duration(minutes: 3),
    );
  }
}
