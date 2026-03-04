import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/notification.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/notification/services/notification_service.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notification_repository.g.dart';

/// いいね通知キーと投稿を組み合わせ、通知一覧を返す Repository
class NotificationRepository {
  NotificationRepository(this._ref);
  final Ref _ref;
  final Logger _logger = Logger();
  SupabaseClient get _supabase => _ref.read(supabaseProvider);
  NotificationService get _service => _ref.read(notificationServiceProvider);

  /// 自分の投稿に届いた「いいね」通知の一覧を返す
  Future<List<Notification>> getMyLikeNotifications() async {
    final keys = await _service.fetchMyLikeNotificationKeys();
    if (keys.isEmpty) {
      return [];
    }
    final ids = keys.map((k) => k.postId).toSet().toList();
    try {
      final rows = await _supabase.from('posts').select().inFilter('id', ids);
      final postsById = <int, Posts>{};
      for (final row in rows) {
        final map = Map<String, dynamic>.from(row as Map);
        final post = Posts.fromJson(map);
        postsById[post.id] = post;
      }
      final notifications = keys
          .map<Notification?>((key) {
            final post = postsById[key.postId];
            if (post == null) {
              _logger.w('通知用投稿が見つかりませんでした: postId=${key.postId}');
              return null;
            }
            return Notification(
              post: post,
              updatedAt: key.updatedAt,
              likerUserId: key.likerUserId,
            );
          })
          .whereType<Notification>()
          .toList();
      notifications.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return notifications;
    } on Exception catch (e) {
      _logger.e('通知用投稿の取得に失敗: $e');
      return [];
    }
  }
}

@riverpod
Future<List<Notification>> myLikeNotifications(
  Ref ref,
) async {
  final repo = NotificationRepository(ref);
  return repo.getMyLikeNotifications();
}
