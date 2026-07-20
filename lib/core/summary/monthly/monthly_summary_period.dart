/// 先月（月初〜月末）の期間計算
class MonthlySummaryPeriod {
  const MonthlySummaryPeriod({
    required this.monthStart,
    required this.monthEndExclusive,
  });

  factory MonthlySummaryPeriod.previousMonth(DateTime now) {
    final thisMonth = DateTime(now.year, now.month);
    final previousMonth = DateTime(now.year, now.month - 1);
    return MonthlySummaryPeriod(
      monthStart: previousMonth,
      monthEndExclusive: thisMonth,
    );
  }

  final DateTime monthStart;
  final DateTime monthEndExclusive;

  DateTime get monthEndInclusive =>
      DateTime(monthEndExclusive.year, monthEndExclusive.month, 0);

  String get preferenceKey {
    final year = monthStart.year.toString().padLeft(4, '0');
    final month = monthStart.month.toString().padLeft(2, '0');
    return '$year-$month';
  }

  bool contains(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    return !day.isBefore(monthStart) && day.isBefore(monthEndExclusive);
  }
}
