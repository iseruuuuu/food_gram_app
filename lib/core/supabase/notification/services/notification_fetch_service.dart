import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/like_notification.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationFetchService {
  NotificationFetchService(this._ref);
  final Ref _ref;

  final Logger _logger = Logger();

  SupabaseClient get _supabase => _ref.read(supabaseProvider);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// 自分の投稿に届いた最新の「いいね」が付いた投稿一覧を取得する
  /// 取得ソース:
  /// - まず Edge Function（FirebaseMessaging, type=fetch_likes）を呼び出す
  /// - 失敗時や未実装時はフォールバックで `user_fcm_tokens` を直接参照（RLS 前提）
  /// 返却: 重複を排除した投稿（最新更新順）
  Future<List<Posts>> fetchMyLikedPosts() async {
    if (_currentUserId == null) {
      return [];
    }
    final likedRows =
        await _fetchLikedTokenRowsForUserViaEdgeFunction(_currentUserId!);
    final distinctByPostId = <int, DateTime>{};
    for (final row in likedRows) {
      if (row.postId == null) {
        continue;
      }
      final pid = row.postId!;
      final updatedAt = row.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final existing = distinctByPostId[pid];
      if (existing == null || updatedAt.isAfter(existing)) {
        distinctByPostId[pid] = updatedAt;
      }
    }
    if (distinctByPostId.isEmpty) {
      return [];
    }
    final postIds = distinctByPostId.keys.toList();
    // 投稿をまとめて取得
    final postsData =
        await _supabase.from('posts').select().inFilter('id', postIds);
    final posts = postsData
        .map<Posts>((json) => Posts.fromJson(Map<String, dynamic>.from(json)))
        .toList();
    // 最新のいいね更新順に並べ替え
    posts.sort((a, b) {
      final aTime = distinctByPostId[a.id]!;
      final bTime = distinctByPostId[b.id]!;
      return bTime.compareTo(aTime);
    });
    return posts;
  }

  /// 通知表示用のキー（postId と更新時刻）の一覧を返す（降順ソート・重複集約済み）
  Future<List<LikeNotificationKey>> fetchMyLikeNotificationKeys() async {
    if (_currentUserId == null) {
      return [];
    }
    final likedRows =
        await _fetchLikedTokenRowsForUserViaEdgeFunction(_currentUserId!);
    final latestByPostId = <int, _LatestLike>{};
    for (final row in likedRows) {
      if (row.postId == null) {
        continue;
      }
      final pid = row.postId!;
      final updatedAt = row.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final existing = latestByPostId[pid]?.updatedAt;
      if (existing == null || updatedAt.isAfter(existing)) {
        latestByPostId[pid] = _LatestLike(
          updatedAt: updatedAt,
          likerUserId: row.likerUserId,
        );
      }
    }
    final keys = latestByPostId.entries
        .map(
          (e) => LikeNotificationKey(
            postId: e.key,
            updatedAt: e.value.updatedAt,
            likerUserId: e.value.likerUserId,
          ),
        )
        .toList();
    keys.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return keys;
  }

  /// Edge Function(UserFcmTokens) 経由で user_fcm_tokens の
  /// [fcm_token, post_id, updated_at, liker_id] を取得
  /// 戻りは柔軟にパース（{data:[...]} または [...]）に対応
  Future<List<_TokenRow>> _fetchLikedTokenRowsForUserViaEdgeFunction(
    String userId,
  ) async {
    try {
      // POST で user_id を渡して Function 呼び出し
      final res = await _supabase.functions.invoke(
        'UserFcmTokens',
        body: <String, dynamic>{
          'user_id': userId,
          'order': 'desc',
          'limit': 200,
        },
      );
      final dynamic data = res.data;
      final rows = _unwrapRows(data);
      // 念のためサーバー返却を二重フィルタ（自分宛のみ、post_id があるもののみ）
      final filtered = rows.where((r) {
        if (r is Map<String, dynamic>) {
          final m = r;
          final rowUserId = m['user_id'] as String?;
          final hasPostId = m['post_id'] != null;
          return rowUserId == userId && hasPostId;
        }
        return false;
      }).toList();
      if (filtered.isEmpty) {
        // フォールバック
        return _fetchLikedTokenRowsFallback(userId);
      }
      return filtered.map<_TokenRow>(_TokenRow.fromDynamic).toList();
    } on Exception catch (e) {
      _logger.w('EdgeFunction fetch_likes に失敗したためフォールバックします: $e');
      return _fetchLikedTokenRowsFallback(userId);
    }
  }

  /// エッジ未対応時のフォールバック: クライアントで自分の行のみ参照
  Future<List<_TokenRow>> _fetchLikedTokenRowsFallback(String userId) async {
    try {
      final rows = await _supabase
          .from('user_fcm_tokens')
          .select('fcm_token, post_id, like_id, updated_at')
          .not('post_id', 'is', null)
          .eq('user_id', userId);
      return rows.map<_TokenRow>(_TokenRow.fromDynamic).toList();
    } on Exception catch (e) {
      _logger.e('user_fcm_tokens のフォールバック取得に失敗: $e');
      return [];
    }
  }

  List<dynamic> _unwrapRows(dynamic data) {
    if (data == null) {
      return const [];
    }
    if (data is List) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      final d = data['data'];
      if (d is List) {
        return d;
      }
    }
    return const [];
  }
}

class _TokenRow {
  _TokenRow({
    required this.fcmToken,
    required this.postId,
    required this.updatedAt,
    required this.likerUserId,
  });
  final String? fcmToken;
  final int? postId;
  final DateTime? updatedAt;
  final String? likerUserId;

  static _TokenRow fromDynamic(dynamic row) {
    if (row is Map) {
      final map = Map<String, dynamic>.from(row);
      final token = map['fcm_token'] as String?;
      final pidRaw =
          map.containsKey('post_id') ? map['post_id'] : map['postId'];
      final pid = pidRaw is int
          ? pidRaw
          : (pidRaw is String ? int.tryParse(pidRaw) : null);
      final updatedRaw = map['updated_at'];
      final updatedAt = updatedRaw is String
          ? DateTime.tryParse(updatedRaw)
          : (updatedRaw is DateTime ? updatedRaw : null);
      // いいねしたユーザーIDを優先順で抽出: like_id → liker_id → likerUserId → id
      final likerId = (map['like_id'] ??
          map['liker_id'] ??
          map['likerUserId'] ??
          map['id']) as String?;
      return _TokenRow(
        fcmToken: token,
        postId: pid,
        updatedAt: updatedAt,
        likerUserId: likerId,
      );
    }
    return _TokenRow(
      fcmToken: null,
      postId: null,
      updatedAt: null,
      likerUserId: null,
    );
  }
}

final notificationFetchServiceProvider =
    Provider<NotificationFetchService>((ref) {
  return NotificationFetchService(ref);
});

class _LatestLike {
  _LatestLike({
    required this.updatedAt,
    required this.likerUserId,
  });
  final DateTime updatedAt;
  final String? likerUserId;
}
