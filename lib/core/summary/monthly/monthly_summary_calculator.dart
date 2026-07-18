import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/summary/monthly/monthly_summary.dart';
import 'package:food_gram_app/core/summary/monthly/monthly_summary_period.dart';
import 'package:food_gram_app/core/summary/weekly/weekly_summary_calculator.dart';
import 'package:food_gram_app/core/utils/location/country_detector.dart';
import 'package:food_gram_app/core/utils/location/prefecture_detector.dart';

MonthlySummary calculateMonthlySummary({
  required List<Posts> allPosts,
  required MonthlySummaryPeriod period,
}) {
  final monthPosts =
      allPosts.where((post) => period.contains(post.createdAt)).toList();
  final previousPeriod = MonthlySummaryPeriod(
    monthStart: DateTime(
      period.monthStart.year,
      period.monthStart.month - 1,
    ),
    monthEndExclusive: period.monthStart,
  );
  final previousMonthPosts = allPosts
      .where((post) => previousPeriod.contains(post.createdAt))
      .toList();

  final priorPosts = allPosts
      .where((post) => post.createdAt.toLocal().isBefore(period.monthStart))
      .toList();
  final cumulativePosts = allPosts
      .where(
          (post) => post.createdAt.toLocal().isBefore(period.monthEndExclusive))
      .toList();

  final priorPrefectures = _visitedPrefectures(priorPosts);
  final cumulativePrefectures = _visitedPrefectures(cumulativePosts);
  final newPrefectures = cumulativePrefectures
      .where((name) => !priorPrefectures.contains(name))
      .toList(growable: false);

  final priorCountries = _visitedCountries(priorPosts);
  final cumulativeCountries = _visitedCountries(cumulativePosts);
  final newCountries = cumulativeCountries
      .where((name) => !priorCountries.contains(name))
      .toList(growable: false);

  return MonthlySummary(
    period: period,
    postCount: monthPosts.length,
    previousPostCount: previousMonthPosts.length,
    newRestaurantCount: _newRestaurantCount(
      allPosts: allPosts,
      periodPosts: monthPosts,
      periodStart: period.monthStart,
    ),
    previousNewRestaurantCount: _newRestaurantCount(
      allPosts: allPosts,
      periodPosts: previousMonthPosts,
      periodStart: previousPeriod.monthStart,
    ),
    averageStar: _averageStar(monthPosts),
    previousAverageStar: _averageStar(previousMonthPosts),
    topGenres: topGenresFromPosts(monthPosts),
    visitedPrefectures: _orderedPrefectures(cumulativePrefectures),
    newPrefecturesThisMonth: _orderedPrefectures(newPrefectures.toSet()),
    visitedCountries: (cumulativeCountries.toList()..sort()),
    newCountriesThisMonth: (newCountries.toList()..sort()),
  );
}

Set<String> _visitedPrefectures(List<Posts> posts) {
  final result = <String>{};
  for (final post in posts) {
    if (post.lat == 0 || post.lng == 0) {
      continue;
    }
    final prefecture = PrefectureDetector.detectPrefecture(post.lat, post.lng);
    if (prefecture != null && prefecture.isNotEmpty) {
      result.add(prefecture);
    }
  }
  return result;
}

Set<String> _visitedCountries(List<Posts> posts) {
  final result = <String>{};
  for (final post in posts) {
    if (post.lat == 0 || post.lng == 0) {
      continue;
    }
    final country = CountryDetector.detectCountry(post.lat, post.lng);
    if (country == null || country == 'その他' || country == '日本') {
      continue;
    }
    result.add(country);
  }
  return result;
}

/// PrefectureDetector の北→南順で並べる
List<String> _orderedPrefectures(Set<String> names) {
  return PrefectureDetector.prefectures
      .map((p) => p.name)
      .where(names.contains)
      .toList(growable: false);
}

int _newRestaurantCount({
  required List<Posts> allPosts,
  required List<Posts> periodPosts,
  required DateTime periodStart,
}) {
  final knownRestaurants = allPosts
      .where((post) => post.createdAt.toLocal().isBefore(periodStart))
      .map((post) => post.restaurant.trim())
      .where((name) => name.isNotEmpty)
      .toSet();
  return periodPosts
      .map((post) => post.restaurant.trim())
      .where((name) => name.isNotEmpty && !knownRestaurants.contains(name))
      .toSet()
      .length;
}

double _averageStar(List<Posts> posts) {
  if (posts.isEmpty) {
    return 0;
  }
  return posts.fold<double>(0, (sum, post) => sum + post.star) / posts.length;
}
