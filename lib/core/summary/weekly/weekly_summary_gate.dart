import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/summary/weekly/weekly_summary_period.dart';
import 'package:food_gram_app/core/summary/weekly/weekly_summary_provider.dart';

/// 「今週のまとめ」を出すかの判定。
/// 先週分をまだ見ておらず、先週に投稿があるとき（曜日は問わない）。
Future<bool> shouldShowWeeklySummary({
  required DateTime now,
  required List<Posts> posts,
  Preference? preference,
}) async {
  final period = WeeklySummaryPeriod.previousWeek(now);
  final pref = preference ?? Preference();
  final lastShown =
      await pref.getString(PreferenceKey.lastWeeklySummaryWeekStart);
  if (lastShown == period.preferenceKey) {
    return false;
  }
  return hasPostsInPreviousWeek(posts, now: now);
}

Future<void> markWeeklySummaryShown({
  required DateTime now,
  Preference? preference,
}) async {
  final period = WeeklySummaryPeriod.previousWeek(now);
  final pref = preference ?? Preference();
  await pref.setString(
    PreferenceKey.lastWeeklySummaryWeekStart,
    period.preferenceKey,
  );
}
