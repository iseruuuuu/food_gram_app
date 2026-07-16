/// 先週（月〜日）の期間計算
class WeeklySummaryPeriod {
  const WeeklySummaryPeriod({
    required this.weekStart,
    required this.weekEndExclusive,
  });

  /// [now] から見た直前の月曜〜日曜
  factory WeeklySummaryPeriod.previousWeek(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final thisMonday = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );
    final lastMonday = thisMonday.subtract(const Duration(days: 7));
    return WeeklySummaryPeriod(
      weekStart: lastMonday,
      weekEndExclusive: thisMonday,
    );
  }

  /// 先週月曜 00:00（ローカル）
  final DateTime weekStart;

  /// 今週月曜 00:00（ローカル）= 先週の終端（排他）
  final DateTime weekEndExclusive;

  /// 先週日曜（期間表示用）
  DateTime get weekEndInclusive =>
      weekEndExclusive.subtract(const Duration(days: 1));

  /// Preference 保存用キー（先週月曜の yyyy-MM-dd）
  String get preferenceKey {
    final y = weekStart.year.toString().padLeft(4, '0');
    final m = weekStart.month.toString().padLeft(2, '0');
    final d = weekStart.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  bool contains(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    return !day.isBefore(weekStart) && day.isBefore(weekEndExclusive);
  }
}
