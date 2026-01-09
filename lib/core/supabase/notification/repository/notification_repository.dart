import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/notification.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/notification/services/notification_fetch_service.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notification_repository.g.dart';

class NotificationRepository {
  NotificationRepository(this._ref);
  final Ref _ref;
  final Logger _logger = Logger();

  SupabaseClient get _supabase => _ref.read(supabaseProvider);
  NotificationFetchService get _service =>
      _ref.read(notificationFetchServiceProvider);

  /// 自分の投稿に届いた「いいね」通知（投稿＋最新時刻）を取得
  Future<List<LikeNotification>> getMyLikeNotifications() async {
    final keys = await _service.fetchMyLikeNotificationKeys();
    if (keys.isEmpty) {
      return [];
    }
    final postIdToUpdatedAt = {
      for (final k in keys) k.postId: k.updatedAt,
    };
    final postIdToLikerId = {
      for (final k in keys) k.postId: k.likerUserId,
    };
    final ids = postIdToUpdatedAt.keys.toList();
    try {
      final rows = await _supabase.from('posts').select().inFilter('id', ids);
      final notifications = rows.map<LikeNotification>((row) {
        final map = Map<String, dynamic>.from(row as Map);
        final post = Posts.fromJson(map);
        final updatedAt = postIdToUpdatedAt[post.id]!;
        final likerId = postIdToLikerId[post.id];
        return LikeNotification(
          post: post,
          updatedAt: updatedAt,
          likerUserId: likerId,
        );
      }).toList();
      notifications.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return notifications;
    } on Exception catch (e) {
      _logger.e('通知用投稿の取得に失敗: $e');
      return [];
    }
  }
}

@riverpod
NotificationRepository notificationRepository(NotificationRepositoryRef ref) {
  return NotificationRepository(ref);
}

@riverpod
Future<List<LikeNotification>> myLikeNotifications(
  MyLikeNotificationsRef ref,
) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getMyLikeNotifications();
}
