import 'package:flutter/foundation.dart';
import 'package:food_gram_app/core/model/posts.dart';

/// 投稿詳細フィードの追加読み込み方向。
enum PostDetailPageDirection {
  newer,
  older,
}

/// 投稿詳細で上方向（より新しい投稿）に一度に足す件数。
const postDetailNewerPageSize = 5;

/// 投稿詳細で下方向（より古い投稿）に一度に足す件数。
const postDetailOlderPageSize = 10;

/// 投稿詳細フィードの1画面分。
@immutable
class PostDetailListResult {
  const PostDetailListResult({
    required this.posts,
    required this.hasMoreNewer,
    required this.hasMoreOlder,
    this.isLoadingNewer = false,
    this.isLoadingOlder = false,
  });

  /// 新しい順。先頭ほど新しく、[posts] の途中に初期投稿が含まれる。
  final List<Posts> posts;
  final bool hasMoreNewer;
  final bool hasMoreOlder;
  final bool isLoadingNewer;
  final bool isLoadingOlder;

  PostDetailListResult copyWith({
    List<Posts>? posts,
    bool? hasMoreNewer,
    bool? hasMoreOlder,
    bool? isLoadingNewer,
    bool? isLoadingOlder,
  }) {
    return PostDetailListResult(
      posts: posts ?? this.posts,
      hasMoreNewer: hasMoreNewer ?? this.hasMoreNewer,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
      isLoadingNewer: isLoadingNewer ?? this.isLoadingNewer,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
    );
  }
}

int _compareNewestFirst(Posts a, Posts b) {
  final created = b.createdAt.compareTo(a.createdAt);
  if (created != 0) {
    return created;
  }
  return b.id.compareTo(a.id);
}

/// 新しい順のリストから、初期投稿の前後だけを切り出す。
PostDetailListResult takePostsAround({
  required List<Posts> sortedNewestFirst,
  required Posts initial,
  int newerLimit = postDetailNewerPageSize,
  int olderLimit = postDetailOlderPageSize,
}) {
  final seen = <int>{};
  final list = <Posts>[];
  for (final post in sortedNewestFirst) {
    if (seen.add(post.id)) {
      list.add(post);
    }
  }
  if (!seen.contains(initial.id)) {
    list.add(initial);
    list.sort(_compareNewestFirst);
  }

  final index = list.indexWhere((post) => post.id == initial.id);
  if (index < 0) {
    return PostDetailListResult(
      posts: [initial],
      hasMoreNewer: false,
      hasMoreOlder: false,
    );
  }

  final newerStart = index - newerLimit < 0 ? 0 : index - newerLimit;
  final olderEnd = index + 1 + olderLimit > list.length
      ? list.length
      : index + 1 + olderLimit;
  return PostDetailListResult(
    posts: list.sublist(newerStart, olderEnd),
    hasMoreNewer: newerStart > 0,
    hasMoreOlder: olderEnd < list.length,
  );
}

/// [cursor] より新しい投稿を、新しい順で最大 [limit] 件返す。
List<Posts> takeNewerPage({
  required List<Posts> sortedNewestFirst,
  required Posts cursor,
  int limit = postDetailNewerPageSize,
}) {
  final index = sortedNewestFirst.indexWhere((post) => post.id == cursor.id);
  if (index <= 0) {
    return const [];
  }
  final start = index - limit < 0 ? 0 : index - limit;
  return sortedNewestFirst.sublist(start, index);
}

/// [cursor] より古い投稿を、新しい順で最大 [limit] 件返す。
List<Posts> takeOlderPage({
  required List<Posts> sortedNewestFirst,
  required Posts cursor,
  int limit = postDetailOlderPageSize,
}) {
  final index = sortedNewestFirst.indexWhere((post) => post.id == cursor.id);
  if (index < 0 || index + 1 >= sortedNewestFirst.length) {
    return const [];
  }
  final end = index + 1 + limit > sortedNewestFirst.length
      ? sortedNewestFirst.length
      : index + 1 + limit;
  return sortedNewestFirst.sublist(index + 1, end);
}

/// 新しい順のリストへ重複なくマージする。
List<Posts> mergePostsNewestFirst(List<Posts> current, List<Posts> extra) {
  if (extra.isEmpty) {
    return current;
  }
  final seen = {for (final post in current) post.id};
  final merged = [...current];
  for (final post in extra) {
    if (seen.add(post.id)) {
      merged.add(post);
    }
  }
  merged.sort(_compareNewestFirst);
  return merged;
}
