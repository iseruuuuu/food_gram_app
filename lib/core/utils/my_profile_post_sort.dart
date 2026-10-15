import 'package:food_gram_app/core/model/posts.dart';

/// マイページの投稿一覧のソート順
enum MyProfilePostSortOrder {
  /// 新しい順（投稿日時の降順）
  newest,

  /// 古い順（投稿日時の昇順）
  oldest,

  /// 高評価順（★の降順）
  starHigh,

  /// 低評価順（評価ありの★昇順 → 未評価は末尾）
  starLow,

  /// いいね順（いいね数の降順）
  likesHigh,
}

int _compareNewestFirst(Posts a, Posts b) {
  final created = b.createdAt.compareTo(a.createdAt);
  if (created != 0) {
    return created;
  }
  return b.id.compareTo(a.id);
}

int _compareOldestFirst(Posts a, Posts b) {
  final created = a.createdAt.compareTo(b.createdAt);
  if (created != 0) {
    return created;
  }
  return a.id.compareTo(b.id);
}

/// [order] に従って投稿リストをソートした新しいリストを返す
List<Posts> sortMyProfilePosts(
  List<Posts> posts,
  MyProfilePostSortOrder order,
) {
  if (posts.length <= 1) {
    return List<Posts>.from(posts);
  }
  final sorted = List<Posts>.from(posts);
  switch (order) {
    case MyProfilePostSortOrder.newest:
      sorted.sort(_compareNewestFirst);
    case MyProfilePostSortOrder.oldest:
      sorted.sort(_compareOldestFirst);
    case MyProfilePostSortOrder.starHigh:
      sorted.sort((a, b) {
        final starCompare = b.star.compareTo(a.star);
        if (starCompare != 0) {
          return starCompare;
        }
        return _compareNewestFirst(a, b);
      });
    case MyProfilePostSortOrder.starLow:
      sorted.sort((a, b) {
        final aRated = a.star > 0;
        final bRated = b.star > 0;
        if (aRated != bRated) {
          return aRated ? -1 : 1;
        }
        final starCompare = a.star.compareTo(b.star);
        if (starCompare != 0) {
          return starCompare;
        }
        return _compareNewestFirst(a, b);
      });
    case MyProfilePostSortOrder.likesHigh:
      sorted.sort((a, b) {
        final heartCompare = b.heart.compareTo(a.heart);
        if (heartCompare != 0) {
          return heartCompare;
        }
        return _compareNewestFirst(a, b);
      });
  }
  return sorted;
}
