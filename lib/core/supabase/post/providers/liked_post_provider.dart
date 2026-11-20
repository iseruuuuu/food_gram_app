import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/liked_posts.dart';
import 'package:food_gram_app/core/supabase/user/providers/friend_user_ids_provider.dart';

/// SharedPreferences に保存したいいね投稿 ID。新しいいいねほど先頭。
final FutureProvider<List<String>> likedPostIdsProvider =
    FutureProvider.autoDispose<List<String>>((ref) {
      return readLikedPostIds();
    });

/// ハートした投稿。マイページの「いいねした店」で地図と一覧に使う。
final FutureProvider<List<Posts>> likedPostListProvider =
    FutureProvider.autoDispose<List<Posts>>((ref) async {
      final client = ref.watch(supabaseProvider);
      final viewerId = ref.watch(currentUserProvider);
      final ids = await ref.watch(likedPostIdsProvider.future);
      final friendIds = await ref.watch(friendUserIdsProvider.future);
      return fetchLikedPosts(
        client: client,
        viewerId: viewerId,
        friendUserIds: friendIds,
        postIds: ids,
      );
    });
