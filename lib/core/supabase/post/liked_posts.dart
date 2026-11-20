import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/post_visibility.dart';
import 'package:food_gram_app/core/supabase/post/services/fetch_post_service.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 保存列は古い順。表示は新しいいいねを先頭にする。重複は新しい方を残す。
List<String> orderedLikedPostIds(List<String> storedIds) {
  final seen = <String>{};
  final ordered = <String>[];
  for (final raw in storedIds.reversed) {
    final id = raw.trim();
    if (id.isEmpty || !seen.add(id)) {
      continue;
    }
    ordered.add(id);
  }
  return ordered;
}

/// SharedPreferences のいいね投稿 ID。新しいいいねほど先頭。
Future<List<String>> readLikedPostIds() async {
  final heartList = await Preference().getStringList(PreferenceKey.heartList);
  return orderedLikedPostIds(heartList);
}

/// 自分がハートした、いま見られる他人の投稿。
///
/// [postIds] を渡さないときは SharedPreferences から読む。
/// 並びはいいねした順（新しいものが先頭）。
Future<List<Posts>> fetchLikedPosts({
  required SupabaseClient client,
  required String? viewerId,
  Iterable<String> friendUserIds = const [],
  Iterable<String> blockedUserIds = const [],
  List<String>? postIds,
}) async {
  final orderedIds = postIds ?? await readLikedPostIds();
  if (orderedIds.isEmpty) {
    return const [];
  }
  try {
    final rows = await fetchStoredPostRowsForIds(
      client,
      orderedIds,
    ).timeout(const Duration(seconds: 45));
    final byId = <int, Posts>{};
    for (final row in rows) {
      try {
        final post = Posts.fromJson(row);
        if (!isVisibleLikedPost(
          post: post,
          viewerId: viewerId,
          friendUserIds: friendUserIds,
          blockedUserIds: blockedUserIds,
        )) {
          continue;
        }
        byId[post.id] = post;
      } on Object catch (e, st) {
        Logger().w('liked posts: skip row parse error: $e\n$st');
      }
    }
    final ordered = <Posts>[];
    for (final idStr in orderedIds) {
      final id = int.tryParse(idStr);
      if (id == null) {
        continue;
      }
      final post = byId[id];
      if (post != null) {
        ordered.add(post);
      }
    }
    return ordered;
  } on Object catch (e, st) {
    Logger().e('liked posts: $e\n$st');
    rethrow;
  }
}

/// いいねした店は、他人の投稿で気になった店。
/// 自分の投稿と、ブロックした人の投稿は出さない。
bool isVisibleLikedPost({
  required Posts post,
  required String? viewerId,
  required Iterable<String> friendUserIds,
  required Iterable<String> blockedUserIds,
}) {
  if (viewerId != null && viewerId.isNotEmpty && post.userId == viewerId) {
    return false;
  }
  if (blockedUserIds.contains(post.userId)) {
    return false;
  }
  return isPostVisibleToViewer(
    isPrivate: post.isAnonymous,
    authorId: post.userId,
    viewerId: viewerId,
    friendUserIds: friendUserIds,
  );
}
