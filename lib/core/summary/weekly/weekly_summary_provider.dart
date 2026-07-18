import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/summary/weekly/weekly_summary.dart';
import 'package:food_gram_app/core/summary/weekly/weekly_summary_calculator.dart';
import 'package:food_gram_app/core/summary/weekly/weekly_summary_period.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/user/services/streak_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weekly_summary_provider.g.dart';

/// 先週のまとめを組み立てる（表示セッション中は同じ Random 結果を保持）
@riverpod
Future<WeeklySummary?> weeklySummary(Ref ref) async {
  final userId = ref.watch(currentUserProvider);
  if (userId == null) {
    return null;
  }

  final posts = await ref.watch(myPostStreamProvider.future);
  final streakWeeks =
      await ref.read(streakServiceProvider.notifier).getCurrentStreakWeeks();
  final period = WeeklySummaryPeriod.previousWeek(DateTime.now());
  final summary = calculateWeeklySummary(
    allPosts: posts,
    period: period,
    streakWeeks: streakWeeks,
    random: Random(),
  );
  if (!summary.hasPosts) {
    return null;
  }
  return summary;
}

/// ゲート判定用: 先週に投稿があるか（ストリーム未準備時は false）
bool hasPostsInPreviousWeek(List<Posts>? posts, {DateTime? now}) {
  if (posts == null || posts.isEmpty) {
    return false;
  }
  final period = WeeklySummaryPeriod.previousWeek(now ?? DateTime.now());
  return posts.any((p) => period.contains(p.createdAt));
}
