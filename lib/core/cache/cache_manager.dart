import 'dart:async';

class CacheEntry<T> {
  CacheEntry({
    required this.data,
    required this.expiryTime,
  });
  final T data;
  final DateTime expiryTime;

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

class CacheManager {
  factory CacheManager() => _instance;
  CacheManager._internal();
  static final CacheManager _instance = CacheManager._internal();

  final _cache = <String, CacheEntry<dynamic>>{};

  // デフォルトのキャッシュ期間
  static const defaultDuration = Duration(minutes: 5);

  Future<T> get<T>({
    required String key,
    required Future<T> Function() fetcher,
    Duration? duration,
  }) async {
    // キャッシュが存在し、有効期限内の場合はキャッシュから返す
    if (_cache.containsKey(key)) {
      final entry = _cache[key]!;
      if (!entry.isExpired) {
        return entry.data as T;
      }
      // 期限切れの場合はキャッシュを削除
      _cache.remove(key);
    }

    // データを取得して新しくキャッシュに保存
    final data = await fetcher();
    _cache[key] = CacheEntry<T>(
      data: data,
      expiryTime: DateTime.now().add(duration ?? defaultDuration),
    );

    return data;
  }

  // 特定のキーのキャッシュを削除
  void invalidate(String key) {
    _cache.remove(key);
  }

  // キャッシュ全体をクリア
  void clearAll() {
    _cache.clear();
  }

  // 期限切れのキャッシュをクリア
  void clearExpired() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }

  /// 特定の投稿のキャッシュを無効化
  void invalidatePostCache(int postId) {
    invalidate('post_data_$postId');
  }

  /// 全投稿のキャッシュを無効化
  void invalidatePostsCache() {
    invalidate('all_posts');
    invalidate('map_posts');
    invalidate('ramen_posts');
  }

  /// ユーザー関連のキャッシュを無効化
  void invalidateUserCache(String userId) {
    invalidate('user_posts_$userId');
    invalidate('user_data_$userId');
    invalidate('heart_amount_$userId');
    invalidate('post_count_$userId');
  }

  /// レストラン関連のキャッシュを無効化
  void invalidateRestaurantCache(double lat, double lng) {
    invalidate('restaurant_posts_${lat}_$lng');
    invalidate('restaurant_reviews_${lat}_$lng');
    invalidate('story_posts_${lat}_$lng');
  }

  /// 近くの投稿キャッシュを無効化
  void invalidateNearbyCache(double lat, double lng) {
    invalidate('nearby_posts_${lat}_$lng');
  }

  /// 現在のユーザーのハート数キャッシュを無効化
  void invalidateCurrentUserHeartCache(String? currentUserId) {
    if (currentUserId != null) {
      invalidate('heart_amount_$currentUserId');
    }
  }
}
