import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/liked_posts.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/services/fetch_post_service.dart';
import 'package:food_gram_app/core/supabase/user/providers/friend_user_ids_provider.dart';

/// SharedPreferences に保存したいいね投稿 ID。新しいいいねほど先頭。
final FutureProvider<List<String>> likedPostIdsProvider =
    FutureProvider.autoDispose<List<String>>((ref) {
      return readLikedPostIds();
    });

/// ハートした投稿。マイページの「いいねしたお店」で一覧に使う。
final FutureProvider<List<Posts>> likedPostListProvider =
    FutureProvider.autoDispose<List<Posts>>((ref) async {
      final client = ref.watch(supabaseProvider);
      final viewerId = ref.watch(currentUserProvider);
      final idsFuture = ref.watch(likedPostIdsProvider.future);
      final friendIdsFuture = ref.watch(friendUserIdsProvider.future);
      final blockedIdsFuture = ref.watch(blockListProvider.future);
      final ids = await idsFuture;
      final friendIds = await friendIdsFuture;
      final blockedIds = await blockedIdsFuture;
      return fetchLikedPosts(
        client: client,
        viewerId: viewerId,
        friendUserIds: friendIds,
        blockedUserIds: blockedIds,
        postIds: ids,
      );
    });

/// いいね一覧を取り直す。次に読む ID 列の行キャッシュだけを捨ててから再構築する。
/// 通常の取得はキャッシュを残す。
Future<void> rebuildLikedPostProviders(
  void Function() invalidateIds,
) async {
  invalidateSavedPostsCache(await readLikedPostIds());
  invalidateIds();
}
