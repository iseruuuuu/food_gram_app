import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/notification.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notification_service.g.dart';

/// いいね通知のキー一覧を Edge Function 経由で取得するサービス
/// クライアントから DB へ直接アクセスしないため、テーブル構造の露出を防ぐ
class NotificationService {
  NotificationService(this._ref);
  final Ref _ref;
  final Logger _logger = Logger();
  SupabaseClient get _supabase => _ref.read(supabaseProvider);
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// 自分の投稿についた最新の「いいね通知」キー（postId / updatedAt / likerUserId）を返す
  /// 取得は `fetch-like-notification` Edge Function に委譲する
  Future<List<NotificationKey>> fetchMyLikeNotificationKeys() async {
    if (_currentUserId == null) {
      return [];
    }
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
      final keys = <NotificationKey>[];
      for (final item in list) {
        if (item is! Map<String, dynamic>) {
          continue;
        }
        final postId = item['postId'];
        final updatedAtRaw = item['updatedAt'];
        final likerUserIdRaw = item['likerUserId'];
        final likerUserId = likerUserIdRaw is String
            ? likerUserIdRaw
            : (likerUserIdRaw is int ? likerUserIdRaw.toString() : null);
        if (postId is! int) {
          continue;
        }
        final updatedAt =
            updatedAtRaw is String ? DateTime.tryParse(updatedAtRaw) : null;
        if (updatedAt == null) {
          continue;
        }
        keys.add(
          NotificationKey(
            postId: postId,
            updatedAt: updatedAt,
            likerUserId: likerUserId,
          ),
        );
      }
      keys.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return keys;
    } on Exception catch (e) {
      _logger.e('fetch-like-notification の呼び出しに失敗: $e');
      return [];
    }
  }
}

@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationService(ref);
}
