import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/analyzer/record_food_traits_analyzer.dart';
import 'package:food_gram_app/core/utils/location/country_detector.dart';
import 'package:food_gram_app/core/utils/location/prefecture_detector.dart';
import 'package:food_gram_app/gen/strings.g.dart';

/// 記録タブの「食の発見」として使えるハイライト一式
class RecordInsightSnapshot {
  const RecordInsightSnapshot({
    required this.totalPosts,
    required this.topGenre,
    required this.topGenreCount,
    required this.topArea,
    required this.topAreaCount,
    required this.busiestYearMonth,
    required this.topRestaurant,
    required this.topRestaurantCount,
    required this.topWeekday,
    required this.topWeekdayCount,
    required this.topTimeSlot,
    required this.topTimeCount,
    required this.yoy,
    required this.favoritePost,
    required this.uniqueGenreCount,
    required this.firstPost,
    required this.oneYearAgoPost,
    required this.usageDays,
    required this.persona,
  });

  final int totalPosts;
  final String? topGenre;
  final int topGenreCount;
  final String? topArea;
  final int topAreaCount;
  final RecordYearMonthCount? busiestYearMonth;
  final String? topRestaurant;
  final int topRestaurantCount;
  final int? topWeekday;
  final int topWeekdayCount;
  final RecordMealTimeSlot? topTimeSlot;
  final int topTimeCount;
  final RecordYoyInsight? yoy;
  final Posts? favoritePost;
  final int uniqueGenreCount;
  final Posts? firstPost;
  final Posts? oneYearAgoPost;
  final int usageDays;
  final RecordFoodPersonaInsight? persona;
}

class RecordYearMonthCount {
  const RecordYearMonthCount({
    required this.year,
    required this.month,
    required this.count,
  });

  final int year;
  final int month;
  final int count;
}

enum RecordYoyKind { genreUp, genreNew, postsUp, postsDown }

class RecordYoyInsight {
  const RecordYoyInsight({
    required this.kind,
    required this.delta,
    this.genreId,
  });

  final RecordYoyKind kind;
  final int delta;
  final String? genreId;
}

enum RecordFoodPersona {
  explorer,
  traveler,
  specialist,
  lunchLover,
  nightOwl,
  balanced,
}

class RecordFoodPersonaInsight {
  const RecordFoodPersonaInsight({
    required this.type,
    this.genreId,
  });

  final RecordFoodPersona type;
  final String? genreId;
}

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

/// 投稿一覧から記録タブ用の発見データをまとめて作る。
RecordInsightSnapshot analyzeRecordInsights(
  List<Posts> posts, {
  DateTime? now,
}) {
  final summary = analyzeRecordFoodTraits(posts);
  final weekday = _topWeekday(posts);
  return RecordInsightSnapshot(
    totalPosts: posts.length,
    topGenre: summary.topGenre,
    topGenreCount: summary.topGenreCount,
    topArea: summary.topArea,
    topAreaCount: summary.topAreaCount,
    busiestYearMonth: recordBusiestYearMonth(posts),
    topRestaurant: summary.topRestaurant,
    topRestaurantCount: summary.topRestaurantCount,
    topWeekday: weekday?.$1,
    topWeekdayCount: weekday?.$2 ?? 0,
    topTimeSlot: summary.topTimeSlot,
    topTimeCount: summary.topTimeCount,
    yoy: recordYoyInsight(posts, now: now),
    favoritePost: recordFavoriteDish(posts),
    uniqueGenreCount: recordUniqueGenreCount(posts),
    firstPost: recordFirstPost(posts),
    oneYearAgoPost: recordOneYearAgoToday(posts, now: now),
    usageDays: recordActivityDaysSpan(posts),
    persona: recordFoodPersona(posts),
  );
}

/// 投稿数が最も多い年月。
RecordYearMonthCount? recordBusiestYearMonth(List<Posts> posts) {
  if (posts.isEmpty) {
    return null;
  }
  final counts = <String, int>{};
  for (final post in posts) {
    final key = '${post.createdAt.year}-${post.createdAt.month}';
    counts[key] = (counts[key] ?? 0) + 1;
  }
  final top = counts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) {
        return byCount;
      }
      return b.key.compareTo(a.key);
    });
  final parts = top.first.key.split('-');
  return RecordYearMonthCount(
    year: int.parse(parts[0]),
    month: int.parse(parts[1]),
    count: top.first.value,
  );
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

/// 使ったジャンルのユニーク数。
int recordUniqueGenreCount(List<Posts> posts) {
  final genres = <String>{};
  for (final post in posts) {
    final genre = recordPostGenre(post);
    if (genre != null) {
      genres.add(genre);
    }
  }
  return genres.length;
}

/// 最も古い投稿。
Posts? recordFirstPost(List<Posts> posts) {
  if (posts.isEmpty) {
    return null;
  }
  final sorted = [...posts]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return sorted.first;
}

/// 1年前の同じ日の投稿。無ければ前後3日。
Posts? recordOneYearAgoToday(
  List<Posts> posts, {
  DateTime? now,
}) {
  if (posts.isEmpty) {
    return null;
  }
  final today = now ?? DateTime.now();
  final target = DateTime(today.year - 1, today.month, today.day);
  Posts? exact;
  Posts? nearby;
  var nearbyDiff = 4;
  for (final post in posts) {
    final date = DateTime(
      post.createdAt.year,
      post.createdAt.month,
      post.createdAt.day,
    );
    if (date == target) {
      if (exact == null || post.createdAt.isAfter(exact.createdAt)) {
        exact = post;
      }
      continue;
    }
    final diff = date.difference(target).inDays.abs();
    if (diff > 0 && diff < nearbyDiff) {
      nearby = post;
      nearbyDiff = diff;
    }
  }
  return exact ?? nearby;
}

/// 去年との比較。ジャンルの変化を優先し、なければ件数で見る。
RecordYoyInsight? recordYoyInsight(
  List<Posts> posts, {
  DateTime? now,
}) {
  if (posts.isEmpty) {
    return null;
  }
  final today = now ?? DateTime.now();
  final thisYear = today.year;
  final lastYear = thisYear - 1;
  final thisYearPosts =
      posts.where((post) => post.createdAt.year == thisYear).toList();
  final lastYearPosts =
      posts.where((post) => post.createdAt.year == lastYear).toList();
  if (thisYearPosts.isEmpty || lastYearPosts.isEmpty) {
    return null;
  }
  final thisGenre = analyzeRecordFoodTraits(thisYearPosts).topGenre;
  if (thisGenre != null) {
    final thisCount = _genreCount(thisYearPosts, thisGenre);
    final lastCount = _genreCount(lastYearPosts, thisGenre);
    if (lastCount == 0 && thisCount >= 3) {
      return RecordYoyInsight(
        kind: RecordYoyKind.genreNew,
        delta: thisCount,
        genreId: thisGenre,
      );
    }
    if (lastCount > 0 && thisCount > lastCount) {
      return RecordYoyInsight(
        kind: RecordYoyKind.genreUp,
        delta: thisCount - lastCount,
        genreId: thisGenre,
      );
    }
  }
  final delta = thisYearPosts.length - lastYearPosts.length;
  if (delta == 0) {
    return null;
  }
  return RecordYoyInsight(
    kind: delta > 0 ? RecordYoyKind.postsUp : RecordYoyKind.postsDown,
    delta: delta.abs(),
  );
}

/// 投稿の偏りから食タイプを決める。件数不足なら出さない。
RecordFoodPersonaInsight? recordFoodPersona(List<Posts> posts) {
  if (posts.length < 5) {
    return null;
  }
  final summary = analyzeRecordFoodTraits(posts);
  final prefectures = recordVisitedPrefecturesCount(posts);
  final countries = recordVisitedCountriesCount(posts);
  if (prefectures >= 8 || countries >= 3) {
    return const RecordFoodPersonaInsight(type: RecordFoodPersona.traveler);
  }
  if (summary.explorationRatio >= 70) {
    return const RecordFoodPersonaInsight(type: RecordFoodPersona.explorer);
  }
  final tagged = posts.where((post) => recordPostGenre(post) != null).length;
  if (summary.topGenre != null &&
      tagged > 0 &&
      summary.topGenreCount / tagged >= 0.4) {
    return RecordFoodPersonaInsight(
      type: RecordFoodPersona.specialist,
      genreId: summary.topGenre,
    );
  }
  if (summary.topTimeSlot == RecordMealTimeSlot.lunch) {
    return const RecordFoodPersonaInsight(type: RecordFoodPersona.lunchLover);
  }
  if (summary.topTimeSlot == RecordMealTimeSlot.evening ||
      summary.topTimeSlot == RecordMealTimeSlot.lateNight) {
    return const RecordFoodPersonaInsight(type: RecordFoodPersona.nightOwl);
  }
  return const RecordFoodPersonaInsight(type: RecordFoodPersona.balanced);
}

/// 初めて訪れた都道府県・国を新しい順に返す。日本は県で見る。
List<RecordFirstVisitPlace> recordRecentFirstVisits(
  List<Posts> posts, {
  int limit = 8,
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
  if (visits.length <= limit) {
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
  final newPlaces = recordRecentFirstVisits(posts, limit: 100)
      .where((place) => place.firstVisitedAt.year == year)
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

String recordWeekdayLabel(Translations t, int weekday) {
  return switch (weekday) {
    DateTime.monday => t.myMapRecord.insight.weekdayMon,
    DateTime.tuesday => t.myMapRecord.insight.weekdayTue,
    DateTime.wednesday => t.myMapRecord.insight.weekdayWed,
    DateTime.thursday => t.myMapRecord.insight.weekdayThu,
    DateTime.friday => t.myMapRecord.insight.weekdayFri,
    DateTime.saturday => t.myMapRecord.insight.weekdaySat,
    _ => t.myMapRecord.insight.weekdaySun,
  };
}

(int, int)? _topWeekday(List<Posts> posts) {
  if (posts.isEmpty) {
    return null;
  }
  final counts = <int, int>{};
  for (final post in posts) {
    final weekday = post.createdAt.weekday;
    counts[weekday] = (counts[weekday] ?? 0) + 1;
  }
  final list = counts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) {
        return byCount;
      }
      return a.key.compareTo(b.key);
    });
  return (list.first.key, list.first.value);
}

int _genreCount(List<Posts> posts, String genreId) {
  var count = 0;
  for (final post in posts) {
    if (recordPostGenre(post) == genreId) {
      count++;
    }
  }
  return count;
}
