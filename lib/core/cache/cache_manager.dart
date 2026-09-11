class CacheEntry<T> {
  CacheEntry({
    required this.data,
    required this.expiryTime,
  });
  final T data;
  final DateTime expiryTime;

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

class _InflightRequest {
  _InflightRequest({
    required this.generation,
    required this.future,
  });

  final int generation;
  final Future<dynamic> future;
}

class CacheManager {
  factory CacheManager() => _instance;
  CacheManager._internal();
  static final CacheManager _instance = CacheManager._internal();

  final _cache = <String, CacheEntry<dynamic>>{};
  final _inflight = <String, _InflightRequest>{};
  final _keyGeneration = <String, int>{};
  int _epoch = 0;

  // デフォルトのキャッシュ期間
  static const defaultDuration = Duration(minutes: 5);

  int _generationOf(String key) => _epoch + (_keyGeneration[key] ?? 0);

  void _invalidateGeneration(String key) {
    _keyGeneration[key] = (_keyGeneration[key] ?? 0) + 1;
  }

  Future<T> get<T>({
    required String key,
    required Future<T> Function() fetcher,
    Duration? duration,
  }) async {
    final entry = _cache[key];
    if (entry != null) {
      if (!entry.isExpired) {
        return entry.data as T;
      }
      _cache.remove(key);
    }

    final generation = _generationOf(key);
    final existing = _inflight[key];
    if (existing != null && existing.generation == generation) {
      return await existing.future as T;
    }

    final future = fetcher().then((data) {
      if (_generationOf(key) == generation) {
        _cache[key] = CacheEntry<T>(
          data: data,
          expiryTime: DateTime.now().add(duration ?? defaultDuration),
        );
      }
      return data;
    });
    _inflight[key] = _InflightRequest(
      generation: generation,
      future: future,
    );
    try {
      return await future;
    } finally {
      final current = _inflight[key];
      if (current != null &&
          current.generation == generation &&
          identical(current.future, future)) {
        _inflight.remove(key);
      }
    }
  }

  /// 有効なキャッシュがあれば同期的に返す。期限切れ・未登録は null。
  T? getIfPresent<T>(String key) {
    final entry = _cache[key];
    if (entry == null) {
      return null;
    }
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.data as T;
  }

  /// 取得済みデータをキャッシュに載せる（登録確認などで同じ行を再利用する）。
  void put<T>({
    required String key,
    required T data,
    Duration? duration,
  }) {
    _cache[key] = CacheEntry<T>(
      data: data,
      expiryTime: DateTime.now().add(duration ?? defaultDuration),
    );
    _invalidateGeneration(key);
  }

  // 特定のキーのキャッシュを削除
  void invalidate(String key) {
    _cache.remove(key);
    _invalidateGeneration(key);
  }

  // キャッシュ全体をクリア
  void clearAll() {
    _cache.clear();
    _inflight.clear();
    _epoch++;
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

  /// フレンド ID 一覧キャッシュを無効化
  void invalidateFriendIdsCache(String userId) {
    invalidate('friend_ids_$userId');
  }

  /// ユーザー関連のキャッシュを無効化
  void invalidateUserCache(String userId) {
    invalidate('user_$userId');
    invalidate('user_posts_$userId');
    invalidate('user_data_$userId');
    invalidate('heart_amount_${userId}_incl_anon');
    invalidate('heart_amount_${userId}_excl_anon');
    invalidate('post_count_$userId');
    invalidate('post_count_rank_$userId');
    invalidate('my_map_posts_$userId');
  }

  /// レストラン関連のキャッシュを無効化
  void invalidateRestaurantCache(double lat, double lng) {
    invalidate('restaurant_posts_${lat}_$lng');
    invalidate('restaurant_reviews_${lat}_$lng');
    invalidate('story_posts_${lat}_$lng');
  }

  /// 近くの投稿キャッシュキー（小数点4桁に丸めてヒット率を上げる）
  static String nearbyPostsKey(double lat, double lng) {
    final latRounded = (lat * 10000).round() / 10000;
    final lngRounded = (lng * 10000).round() / 10000;
    return 'nearby_posts_${latRounded.toStringAsFixed(4)}_'
        '${lngRounded.toStringAsFixed(4)}';
  }

  /// 近くの投稿キャッシュを無効化
  void invalidateNearbyCache(double lat, double lng) {
    invalidate(nearbyPostsKey(lat, lng));
  }

  /// 現在のユーザーのハート数キャッシュを無効化
  void invalidateCurrentUserHeartCache(String? currentUserId) {
    if (currentUserId != null) {
      invalidate('heart_amount_${currentUserId}_incl_anon');
      invalidate('heart_amount_${currentUserId}_excl_anon');
    }
  }

  /// 投稿関連のキャッシュを無効化（投稿作成・編集後）
  void invalidatePostRelatedCache(String? currentUserId) {
    invalidatePostsCache();
    if (currentUserId != null) {
      invalidateUserCache(currentUserId);
    }
  }

  /// 位置情報関連のキャッシュを無効化（投稿編集後）
  void invalidateLocationRelatedCache(double lat, double lng) {
    invalidateRestaurantCache(lat, lng);
    invalidateNearbyCache(lat, lng);
  }

  /// 投稿削除時に関連する全てのキャッシュを無効化
  void invalidateDeleteRelatedCaches({
    required int postId,
    required String userId,
    required double lat,
    required double lng,
    String? currentUserId,
    String? masterAccount,
  }) {
    // 全体の投稿リストに関連するキャッシュを無効化
    invalidatePostsCache();
    // 特定の投稿に関連するキャッシュを無効化
    invalidatePostCache(postId);
    // 投稿者のユーザー関連キャッシュを無効化
    invalidateUserCache(userId);
    // 位置情報に関連するキャッシュを無効化
    invalidateLocationRelatedCache(lat, lng);
    // マスターアカウントによる削除の場合、追加のキャッシュクリアが必要かもしれない
    if (currentUserId == masterAccount) {
      clearAll();
    }
  }
}
