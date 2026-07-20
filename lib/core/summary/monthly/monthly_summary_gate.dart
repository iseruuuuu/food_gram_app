import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/summary/monthly/monthly_summary_period.dart';

/// 毎月1日に、未表示かつ先月の投稿がある場合だけ月間まとめを表示する。
Future<bool> shouldShowMonthlySummary({
  required DateTime now,
  required List<Posts> posts,
  Preference? preference,
}) async {
  if (now.day != 1) {
    return false;
  }
  final period = MonthlySummaryPeriod.previousMonth(now);
  final pref = preference ?? Preference();
  final lastShown =
      await pref.getString(PreferenceKey.lastMonthlySummaryMonthStart);
  if (lastShown == period.preferenceKey) {
    return false;
  }
  return posts.any((post) => period.contains(post.createdAt));
}

Future<void> markMonthlySummaryShown({
  required DateTime now,
  Preference? preference,
}) async {
  final period = MonthlySummaryPeriod.previousMonth(now);
  final pref = preference ?? Preference();
  await pref.setString(
    PreferenceKey.lastMonthlySummaryMonthStart,
    period.preferenceKey,
  );
}
