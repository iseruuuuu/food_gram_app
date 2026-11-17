import 'package:food_gram_app/core/model/notification.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/notification/like_notification_keys.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notification_service.g.dart';

/// いいね通知のキー一覧を取得するサービス。
/// 履歴は `like_notifications`、Edge Function は取りこぼしの補完に使う。
class NotificationService {
  NotificationService(this._ref);
  final Ref _ref;
  final _logger = Logger();
  SupabaseClient get _supabase => _ref.read(supabaseProvider);
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// 自分の投稿についたいいねを、いいねした人ごとに返す。
  /// 投稿あたり最新の1人にはまとめない。
  Future<List<NotificationKey>> fetchMyLikeNotificationKeys() async {
    final userId = _currentUserId;
    if (userId == null) {
      return [];
    }
    final fromTable = await _fetchLikeNotificationRows(userId);
    final fromEdge = await _fetchLikeNotificationKeysFromEdge();
    if (_currentUserId != userId) {
      return [];
    }
    return newestLikeNotificationKeys([...fromTable, ...fromEdge]);
  }

  /// `like_notifications` の新しい履歴を [likeNotificationListLimit] 件読む。
  Future<List<NotificationKey>> _fetchLikeNotificationRows(
    String userId,
  ) async {
    try {
      final rows = await _supabase
          .from('like_notifications')
          .select('post_id, liker_user_id, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .order('post_id', ascending: false)
          .order('liker_user_id', ascending: true)
          .limit(likeNotificationListLimit);
      return _keysFromRows(rows);
    } on Exception catch (e) {
      _logger.e('like_notifications の取得に失敗: $e');
      return [];
    }
  }

  List<NotificationKey> _keysFromRows(Iterable<dynamic> rows) {
    final keys = <NotificationKey>[];
    for (final row in rows) {
      if (row is! Map) {
        continue;
      }
      final key = notificationKeyFromLikePayload(row);
      if (key != null) {
        keys.add(key);
      }
    }
    return keys;
  }

  /// `fetch-like-notification` は投稿ごとの最新1人だけを返すことがある。
  /// テーブルに無い人を補うために使い、こちらだけを一覧にはしない。
  Future<List<NotificationKey>> _fetchLikeNotificationKeysFromEdge() async {
    try {
      final res = await _supabase.functions.invoke(
        'fetch-like-notification',
        body: <String, dynamic>{},
      );
      final data = res.data;
      if (data == null || data is! Map<String, dynamic>) {
        return [];
      }
      final list = data['data'];
      if (list is! List) {
        return [];
      }
      return _keysFromRows(list);
    } on Exception catch (e) {
      _logger.e('fetch-like-notification の呼び出しに失敗: $e');
      return [];
    }
  }
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return NotificationService(ref);
}
