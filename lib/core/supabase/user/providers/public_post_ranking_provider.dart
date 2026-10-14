import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/post_count_ranking.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/user/repository/user_repository.dart';

/// 投稿の合計数での全体ランキング。ブロックしたユーザーは除く。
final publicPostRankingProvider =
    FutureProvider<List<PostCountRankingEntry>>((ref) async {
  final blocked = await ref.watch(blockListProvider.future);
  final result =
      await ref.read(userRepositoryProvider.notifier).getPublicPostCounts();
  return result.when(
    success: (counts) => rankPublicPostCounts(
      counts,
      excludedUserIds: blocked.toSet(),
    ),
    failure: (error) => throw error,
  );
});
