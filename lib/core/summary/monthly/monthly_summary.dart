import 'package:food_gram_app/core/summary/monthly/monthly_summary_period.dart';
import 'package:food_gram_app/core/summary/weekly/weekly_summary.dart';

/// 月次まとめの集計結果
class MonthlySummary {
  const MonthlySummary({
    required this.period,
    required this.postCount,
    required this.previousPostCount,
    required this.newRestaurantCount,
    required this.previousNewRestaurantCount,
    required this.averageStar,
    required this.previousAverageStar,
    required this.topGenres,
    required this.visitedPrefectures,
    required this.newPrefecturesThisMonth,
    required this.visitedCountries,
    required this.newCountriesThisMonth,
  });

  final MonthlySummaryPeriod period;
  final int postCount;
  final int previousPostCount;
  final int newRestaurantCount;
  final int previousNewRestaurantCount;
  final double averageStar;
  final double previousAverageStar;
  final List<WeeklySummaryGenreRank> topGenres;

  /// 対象月末時点までの累積訪問都道府県（北から順）
  final List<String> visitedPrefectures;

  /// 対象月に初めて訪れた都道府県
  final List<String> newPrefecturesThisMonth;

  /// 対象月末時点までの累積訪問国（日本除く）
  final List<String> visitedCountries;

  /// 対象月に初めて訪れた国（日本除く）
  final List<String> newCountriesThisMonth;

  int get postCountDifference => postCount - previousPostCount;
  int get newRestaurantDifference =>
      newRestaurantCount - previousNewRestaurantCount;
  double get averageStarDifference => averageStar - previousAverageStar;
  bool get hasPosts => postCount > 0;
  bool get hasVisitFootprint =>
      visitedPrefectures.isNotEmpty || visitedCountries.isNotEmpty;
}
