import 'package:food_gram_app/core/model/notification.dart';

/// `like_notifications` 行と Edge Function のレスポンスを同じキーに揃える。
NotificationKey? notificationKeyFromLikePayload(Map<dynamic, dynamic> raw) {
  final item = Map<String, dynamic>.from(raw);
  final postIdRaw = item['postId'] ?? item['post_id'];
  final postId = switch (postIdRaw) {
    final int value => value,
    final String value => int.tryParse(value),
    _ => null,
  };
  if (postId == null) {
    return null;
  }
  final updatedAtRaw =
      item['updatedAt'] ??
      item['updated_at'] ??
      item['createdAt'] ??
      item['created_at'];
  final updatedAt = switch (updatedAtRaw) {
    final DateTime value => value,
    final String value => DateTime.tryParse(value),
    _ => null,
  };
  if (updatedAt == null) {
    return null;
  }
  final likerRaw =
      item['likerUserId'] ?? item['liker_user_id'] ?? item['liker_id'];
  final likerUserId = switch (likerRaw) {
    final String value => value,
    final int value => value.toString(),
    _ => null,
  };
  return NotificationKey(
    postId: postId,
    updatedAt: updatedAt,
    likerUserId: likerUserId,
  );
}

/// 通知欄に出すいいねの上限。新しいものからこの件数まで。
const likeNotificationListLimit = 100;

/// 投稿ごとの最新1人には畳まず、いいねした人を1人ずつ残す。
/// 同じ投稿・同じ人の重複だけ新しい時刻を残して除く。
List<NotificationKey> mergeLikeNotificationKeys(List<NotificationKey> keys) {
  final byPerson = <String, NotificationKey>{};
  for (final key in keys) {
    final likerUserId = key.likerUserId;
    final dedupeKey = likerUserId == null || likerUserId.isEmpty
        ? 'post:${key.postId}'
        : 'post:${key.postId}:user:$likerUserId';
    final existing = byPerson[dedupeKey];
    if (existing == null || key.updatedAt.isAfter(existing.updatedAt)) {
      byPerson[dedupeKey] = key;
    }
  }
  final merged = byPerson.values.toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return merged;
}

/// 重複を除いたあと、新しい順に [limit] 件まで残す。
List<NotificationKey> newestLikeNotificationKeys(
  List<NotificationKey> keys, {
  int limit = likeNotificationListLimit,
}) {
  final merged = mergeLikeNotificationKeys(keys);
  if (merged.length <= limit) {
    return merged;
  }
  return merged.sublist(0, limit);
}
