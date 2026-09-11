import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/analyzer/record_food_traits_analyzer.dart';
import 'package:food_gram_app/core/utils/location/country_detector.dart';
import 'package:food_gram_app/core/utils/location/prefecture_detector.dart';

class RecordFirstVisitPlace {
  const RecordFirstVisitPlace({
    required this.label,
    required this.firstVisitedAt,
    required this.isPrefecture,
    required this.firstPost,
  });

  final String label;
  final DateTime firstVisitedAt;
  final bool isPrefecture;
  final Posts firstPost;
}

/// 1年分の食体験。シェア用カードにも転用できるよう年単位で完結させる。
class RecordYearRecap {
  const RecordYearRecap({
    required this.year,
    required this.mealsCount,
    required this.shopsCount,
    required this.prefecturesCount,
    required this.countriesCount,
    required this.monthlyCounts,
    this.topGenre,
    this.topGenreCount = 0,
    this.topArea,
    this.topAreaCount = 0,
    this.favoritePost,
    this.newPrefectures = const [],
    this.newCountries = const [],
    this.previousYearMeals,
  });

  final int year;
  final int mealsCount;
  final int shopsCount;
  final int prefecturesCount;
  final int countriesCount;
  final List<int> monthlyCounts;
  final String? topGenre;
  final int topGenreCount;
  final String? topArea;
  final int topAreaCount;
  final Posts? favoritePost;
  final List<String> newPrefectures;
  final List<String> newCountries;
  final int? previousYearMeals;
}

/// お気に入り判定。自分の星が最優先、なければいいね。
Posts? recordFavoriteDish(List<Posts> posts) {
  if (posts.isEmpty) {
    return null;
  }
  final ranked = [...posts]..sort((a, b) {
      final starCompare = b.star.compareTo(a.star);
      if (starCompare != 0) {
        return starCompare;
      }
      final heartCompare = b.heart.compareTo(a.heart);
      if (heartCompare != 0) {
        return heartCompare;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
  final top = ranked.first;
  if (top.star <= 0 && top.heart <= 0) {
    return null;
  }
  return top;
}

/// 初めて訪れた都道府県・国を新しい順に返す。日本は県で見る。
List<RecordFirstVisitPlace> recordRecentFirstVisits(
  List<Posts> posts, {
  int? limit = 8,
}) {
  final prefectures = <String, RecordFirstVisitPlace>{};
  final countries = <String, RecordFirstVisitPlace>{};
  final sorted = [...posts]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  for (final post in sorted) {
    if (post.lat == 0 && post.lng == 0) {
      continue;
    }
    final prefecture = PrefectureDetector.detectPrefecture(post.lat, post.lng);
    if (prefecture != null && prefecture.isNotEmpty) {
      prefectures.putIfAbsent(
        prefecture,
        () => RecordFirstVisitPlace(
          label: prefecture,
          firstVisitedAt: post.createdAt,
          isPrefecture: true,
          firstPost: post,
        ),
      );
    }
    final country = CountryDetector.detectCountry(post.lat, post.lng);
    if (country != null && country != 'その他' && country != '日本') {
      countries.putIfAbsent(
        country,
        () => RecordFirstVisitPlace(
          label: country,
          firstVisitedAt: post.createdAt,
          isPrefecture: false,
          firstPost: post,
        ),
      );
    }
  }
  final visits = [...prefectures.values, ...countries.values]
    ..sort((a, b) => b.firstVisitedAt.compareTo(a.firstVisitedAt));
  if (limit == null || visits.length <= limit) {
    return visits;
  }
  return visits.sublist(0, limit);
}

/// 指定年の月ごとの投稿数（1月始まり、長さ12）。ローカル日時で集計する。
List<int> recordMonthlyPostCounts(List<Posts> posts, int year) {
  final monthlyCounts = List<int>.filled(12, 0);
  for (final post in posts) {
    final local = post.createdAt.toLocal();
    if (local.year != year) {
      continue;
    }
    monthlyCounts[local.month - 1]++;
  }
  return monthlyCounts;
}

/// 指定年の食体験サマリー。
RecordYearRecap? analyzeYearRecap(
  List<Posts> posts,
  int year,
) {
  final yearPosts =
      posts.where((post) => post.createdAt.toLocal().year == year).toList();
  if (yearPosts.isEmpty) {
    return null;
  }
  final summary = analyzeRecordFoodTraits(yearPosts);
  final monthlyCounts = recordMonthlyPostCounts(posts, year);
  final previousCount =
      posts.where((post) => post.createdAt.toLocal().year == year - 1).length;
  final newPlaces = recordRecentFirstVisits(posts, limit: null)
      .where((place) => place.firstVisitedAt.toLocal().year == year)
      .toList();
  return RecordYearRecap(
    year: year,
    mealsCount: yearPosts.length,
    shopsCount: recordUniqueRestaurantsCount(yearPosts),
    prefecturesCount: recordVisitedPrefecturesCount(yearPosts),
    countriesCount: recordVisitedCountriesCount(yearPosts),
    monthlyCounts: monthlyCounts,
    topGenre: summary.topGenre,
    topGenreCount: summary.topGenreCount,
    topArea: summary.topArea,
    topAreaCount: summary.topAreaCount,
    favoritePost: recordFavoriteDish(yearPosts),
    newPrefectures: newPlaces
        .where((place) => place.isPrefecture)
        .map((place) => place.label)
        .toList(),
    newCountries: newPlaces
        .where((place) => !place.isPrefecture)
        .map((place) => place.label)
        .toList(),
    previousYearMeals: previousCount == 0 ? null : previousCount,
  );
}

/// 記録がある年を新しい順に返す。
List<int> recordSortedYears(List<Posts> posts) {
  final years = posts
      .map((post) => post.createdAt.toLocal().year)
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));
  return years;
}
