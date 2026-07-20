import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/summary/monthly/monthly_summary_gate.dart';
import 'package:food_gram_app/core/summary/weekly/weekly_summary_gate.dart';

/// 起動時に出すまとめの種類。
enum SummaryLaunchType {
  monthly,
  weekly,
}

/// デバッグ用の強制表示。
/// 確認したい方のコメントを外す（本番では必ず `null` のまま）。
///
/// 例:
/// ```dart
/// SummaryLaunchType.monthly; // 月間を強制
/// // SummaryLaunchType.weekly; // 週間を強制
/// // null;
/// ```
const SummaryLaunchType? debugForceSummaryLaunch = null;
// SummaryLaunchType.monthly;
// SummaryLaunchType.weekly;

/// 月間と週間の優先度を解決する。
///
/// - 毎月1日: 月間を優先。同日は週間を出さない
/// - それ以外: 週間のみ判定
Future<SummaryLaunchType?> resolveSummaryLaunch({
  required DateTime now,
  required List<Posts> posts,
  Preference? preference,
}) async {
  const debugForce = debugForceSummaryLaunch;
  if (debugForce != null) {
    return debugForce;
  }

  if (now.day == 1) {
    final shouldShowMonthly = await shouldShowMonthlySummary(
      now: now,
      posts: posts,
      preference: preference,
    );
    return shouldShowMonthly ? SummaryLaunchType.monthly : null;
  }

  final shouldShowWeekly = await shouldShowWeeklySummary(
    now: now,
    posts: posts,
    preference: preference,
  );
  return shouldShowWeekly ? SummaryLaunchType.weekly : null;
}

Future<void> markSummaryLaunchShown({
  required SummaryLaunchType type,
  required DateTime now,
  Preference? preference,
}) async {
  // デバッグ強制表示中は「表示済み」を残さない（何度でも出る）
  if (debugForceSummaryLaunch != null) {
    return;
  }
  switch (type) {
    case SummaryLaunchType.monthly:
      await markMonthlySummaryShown(now: now, preference: preference);
    case SummaryLaunchType.weekly:
      await markWeeklySummaryShown(now: now, preference: preference);
  }
}
