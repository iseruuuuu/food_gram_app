import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/local/post_rank_history.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/supabase/user/providers/post_count_rank_provider.dart';

/// 記録タブを開いたときの投稿数順位と、保存済み順位との差。
final recordPostRankProvider =
    FutureProvider.family<PostRankComparison, String>((ref, userId) async {
  final rank = await ref.watch(postCountRankProvider(userId).future);
  return Preference().recordPostRank(userId: userId, rank: rank);
});
