/// 非公開投稿の閲覧判定。
///
/// 保存列は既存の `is_anonymous`。公開投稿は誰でも見える。
/// 非公開投稿は投稿者本人と、[friendUserIds] に含まれる相手だけが見られる。
bool isPostVisibleToViewer({
  required bool isPrivate,
  required String authorId,
  required String? viewerId,
  Iterable<String> friendUserIds = const [],
}) {
  if (!isPrivate) {
    return true;
  }
  if (viewerId == null || viewerId.isEmpty) {
    return false;
  }
  if (authorId == viewerId) {
    return true;
  }
  return friendUserIds.contains(authorId);
}

/// キャッシュキー用。フレンド一覧の並びが違っても同じキーになる。
String friendIdsCacheToken(Iterable<String> friendUserIds) {
  final ids = friendUserIds.toList()..sort();
  return ids.join(',');
}
