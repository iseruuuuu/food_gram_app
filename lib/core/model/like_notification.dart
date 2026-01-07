import 'package:food_gram_app/core/model/posts.dart';

/// 通知一覧のキー（postId / 更新時刻 / いいねした人のID）
class LikeNotificationKey {
  LikeNotificationKey({
    required this.postId,
    required this.updatedAt,
    this.likerUserId,
  });
  final int postId;
  final DateTime updatedAt;
  final String? likerUserId;
}

/// 通知一覧の表示用モデル（投稿 / 更新時刻 / いいねした人のID）
class LikeNotification {
  LikeNotification({
    required this.post,
    required this.updatedAt,
    this.likerUserId,
  });
  final Posts post;
  final DateTime updatedAt;
  final String? likerUserId;
}
