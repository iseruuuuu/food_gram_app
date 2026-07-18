import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/summary/monthly/monthly_summary.dart';
import 'package:food_gram_app/core/summary/monthly/monthly_summary_calculator.dart';
import 'package:food_gram_app/core/summary/monthly/monthly_summary_period.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';

final monthlySummaryProvider = FutureProvider.autoDispose<MonthlySummary?>(
  (ref) async {
    final userId = ref.watch(currentUserProvider);
    if (userId == null) {
      return null;
    }
    final posts = await ref.watch(myPostStreamProvider.future);
    final summary = calculateMonthlySummary(
      allPosts: posts,
      period: MonthlySummaryPeriod.previousMonth(DateTime.now()),
    );
    return summary.hasPosts ? summary : null;
  },
);
