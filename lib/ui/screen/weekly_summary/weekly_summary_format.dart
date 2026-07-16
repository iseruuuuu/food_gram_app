import 'package:food_gram_app/core/weekly_summary/weekly_summary_period.dart';
import 'package:food_gram_app/gen/strings.g.dart';

List<String> weeklySummaryWeekdayLabels(Translations t) => [
      t.weeklySummary.weekdayMon,
      t.weeklySummary.weekdayTue,
      t.weeklySummary.weekdayWed,
      t.weeklySummary.weekdayThu,
      t.weeklySummary.weekdayFri,
      t.weeklySummary.weekdaySat,
      t.weeklySummary.weekdaySun,
    ];

String formatWeeklySummaryDay(DateTime date, String weekdayLabel) {
  return '${date.month}/${date.day} ($weekdayLabel)';
}

String formatWeeklySummaryDateRange(
  WeeklySummaryPeriod period,
  Translations t,
) {
  final labels = weeklySummaryWeekdayLabels(t);
  final start = formatWeeklySummaryDay(period.weekStart, labels[0]);
  final end = formatWeeklySummaryDay(period.weekEndInclusive, labels[6]);
  return t.weeklySummary.dateRange
      .replaceAll('{start}', start)
      .replaceAll('{end}', end);
}
