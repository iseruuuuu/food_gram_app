import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/notification.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/notification/edge_client/notification_edge_client.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notification_fetch_service.g.dart';

class NotificationFetchService {
  NotificationFetchService(this._ref);
  final Ref _ref;
  final Logger _logger = Logger();
  SupabaseClient get _supabase => _ref.read(supabaseProvider);
  NotificationEdgeClient get _edgeClient =>
      _ref.read(notificationEdgeClientProvider);
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Repository 層向け: 自分の投稿についた最新の「いいね通知」キーを返す
  /// （postId / 最新更新時刻 / 直近でいいねしたユーザーID）
  Future<List<NotificationKey>> fetchMyLikeNotificationKeys() async {
    if (_currentUserId == null) {
      return [];
    }
    final edgeRows = await _edgeClient.fetchUserFcmTokenRows(_currentUserId!);
    final edgeTokenRows = edgeRows
        .where((m) => m['user_id'] == _currentUserId && m['post_id'] != null)
        .map<_TokenRow>(_TokenRow.fromDynamic)
        .toList();
    final tokenRows = edgeTokenRows.isNotEmpty
        ? edgeTokenRows
        : await _fetchLikeRowsFromTable(_currentUserId!);
    final latestByPostId = <int, _LatestLike>{};
    for (final row in tokenRows) {
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
          (e) => NotificationKey(
            postId: e.key,
            updatedAt: e.value.updatedAt,
            likerUserId: e.value.likerUserId,
          ),
        )
        .toList();
    keys.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return keys;
  }

  /// エッジ未対応/失敗時のフォールバック: user_fcm_tokens を直接参照
  Future<List<_TokenRow>> _fetchLikeRowsFromTable(String userId) async {
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
}

class _TokenRow {
  _TokenRow({
    required this.fcmToken,
    required this.postId,
    required this.updatedAt,
    required this.likerUserId,
  });
  factory _TokenRow.fromDynamic(dynamic row) {
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
      // いいねを送ったユーザーIDを取得する優先順位:
      // like_id → liker_id → likerUserId
      // テーブルの id は行の主キーであってユーザーIDではないため除外する
      final rawLikerId =
          map['like_id'] ?? map['liker_id'] ?? map['likerUserId'];
      final likerId = rawLikerId is String
          ? rawLikerId
          : (rawLikerId is int ? rawLikerId.toString() : null);
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
  final String? fcmToken;
  final int? postId;
  final DateTime? updatedAt;
  final String? likerUserId;
}

@riverpod
NotificationFetchService notificationFetchService(
  NotificationFetchServiceRef ref,
) {
  return NotificationFetchService(ref);
}

class _LatestLike {
  _LatestLike({
    required this.updatedAt,
    required this.likerUserId,
  });
  final DateTime updatedAt;
  final String? likerUserId;
}
