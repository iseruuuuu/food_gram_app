import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/notification.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notification_fetch_service.g.dart';

class NotificationFetchService {
  NotificationFetchService(this._ref);
  final Ref _ref;
  final Logger _logger = Logger();
  SupabaseClient get _supabase => _ref.read(supabaseProvider);
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// 自分の投稿についた最新の「いいね通知」キーを返す
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
        final likerUserId = item['likerUserId'] as String?;
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
NotificationFetchService notificationFetchService(
  Ref ref,
) {
  return NotificationFetchService(ref);
}
