import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/utils/location/country_detector.dart';
import 'package:food_gram_app/core/utils/location/prefecture_detector.dart';
import 'package:food_gram_app/gen/strings.g.dart';

enum RecordMealTimeSlot { morning, lunch, afternoon, evening, lateNight }

class RecordFoodTraitsSummary {
  const RecordFoodTraitsSummary({
    required this.totalPosts,
    required this.topArea,
    required this.topAreaCount,
    required this.topGenre,
    required this.topGenreCount,
    required this.topTimeSlot,
    required this.topTimeCount,
    required this.topRestaurant,
    required this.topRestaurantCount,
    required this.averageRating,
    required this.ratingCount,
    required this.explorationRatio,
    required this.firstVisitCount,
  });

  final int totalPosts;
  final String? topArea;
  final int topAreaCount;
  final String? topGenre;
  final int topGenreCount;
  final RecordMealTimeSlot? topTimeSlot;
  final int topTimeCount;
  final String? topRestaurant;
  final int topRestaurantCount;
  final double? averageRating;
  final int ratingCount;
  final int explorationRatio;
  final int firstVisitCount;
}

/// 初投稿日から最終投稿日までの日数（記録タブ表示用）
int recordActivityDaysSpan(List<Posts> source) {
  if (source.isEmpty) {
    return 0;
  }
  final sorted = [...source]
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return sorted.last.createdAt.difference(sorted.first.createdAt).inDays;
}

/// 投稿の座標から訪れた都道府県数を数える（記録タブ詳細の統計用）。
/// 地図を開かなくても正しい件数を表示できるよう、posts から直接算出する。
int recordVisitedPrefecturesCount(List<Posts> posts) {
  final prefectures = <String>{};
  for (final post in posts) {
    if (post.lat == 0 || post.lng == 0) {
      continue;
    }
    final prefecture = PrefectureDetector.detectPrefecture(post.lat, post.lng);
    if (prefecture != null && prefecture.isNotEmpty) {
      prefectures.add(prefecture);
    }
  }
  return prefectures.length;
}

/// 投稿の座標から訪れた国数を数える（記録タブ詳細の統計用）。
int recordVisitedCountriesCount(List<Posts> posts) {
  final countries = <String>{};
  for (final post in posts) {
    if (post.lat == 0 || post.lng == 0) {
      continue;
    }
    final country = CountryDetector.detectCountry(post.lat, post.lng);
    if (country != null && country != 'その他') {
      countries.add(country);
    }
  }
  return countries.length;
}

/// 今年はじめて訪れたお店の数（記録タブのハイライト表示用）
int recordNewShopsThisYear(List<Posts> posts) {
  if (posts.isEmpty) {
    return 0;
  }
  final year = DateTime.now().year;
  final firstSeen = <String, DateTime>{};
  for (final post in posts) {
    final shop = post.restaurant.trim();
    if (shop.isEmpty) {
      continue;
    }
    final current = firstSeen[shop];
    if (current == null || post.createdAt.isBefore(current)) {
      firstSeen[shop] = post.createdAt;
    }
  }
  return firstSeen.values.where((date) => date.year == year).length;
}

/// 連続して記録した最長の日数（記録タブのハイライト表示用）
int recordLongestDailyStreak(List<Posts> posts) {
  if (posts.isEmpty) {
    return 0;
  }
  final days = posts
      .map(
        (p) => DateTime(p.createdAt.year, p.createdAt.month, p.createdAt.day),
      )
      .toSet()
      .toList()
    ..sort();
  var longest = 1;
  var current = 1;
  for (var i = 1; i < days.length; i++) {
    final diff = days[i].difference(days[i - 1]).inDays;
    if (diff == 1) {
      current++;
      if (current > longest) {
        longest = current;
      }
    } else if (diff > 1) {
      current = 1;
    }
  }
  return longest;
}

/// 先月と比べた今月の投稿数の増加率（%）。先月が0件の場合はnull。
int? recordMonthlyGrowthPercent(List<Posts> posts) {
  final now = DateTime.now();
  final thisMonth = DateTime(now.year, now.month);
  final lastMonth = DateTime(now.year, now.month - 1);
  var thisCount = 0;
  var lastCount = 0;
  for (final post in posts) {
    final d = post.createdAt;
    if (d.year == thisMonth.year && d.month == thisMonth.month) {
      thisCount++;
    } else if (d.year == lastMonth.year && d.month == lastMonth.month) {
      lastCount++;
    }
  }
  if (lastCount == 0) {
    return null;
  }
  return (((thisCount - lastCount) / lastCount) * 100).round();
}

/// 今月の投稿数（記録タブのサブ指標表示用）
int recordPostsThisMonth(List<Posts> posts) {
  final now = DateTime.now();
  return posts
      .where(
        (p) => p.createdAt.year == now.year && p.createdAt.month == now.month,
      )
      .length;
}

/// 今月はじめて訪れたお店の数（記録タブのサブ指標表示用）
int recordNewShopsThisMonth(List<Posts> posts) {
  if (posts.isEmpty) {
    return 0;
  }
  final now = DateTime.now();
  final firstSeen = <String, DateTime>{};
  for (final post in posts) {
    final shop = post.restaurant.trim();
    if (shop.isEmpty) {
      continue;
    }
    final current = firstSeen[shop];
    if (current == null || post.createdAt.isBefore(current)) {
      firstSeen[shop] = post.createdAt;
    }
  }
  return firstSeen.values
      .where((date) => date.year == now.year && date.month == now.month)
      .length;
}

RecordFoodTraitsSummary analyzeRecordFoodTraits(List<Posts> posts) {
  final areaCounts = <String, int>{};
  final genreCounts = <String, int>{};
  final timeCounts = <RecordMealTimeSlot, int>{};
  final restaurantCounts = <String, int>{};
  var ratingTotal = 0.0;
  var ratingCount = 0;

  for (final post in posts) {
    final area = _areaFor(post);
    if (area != null) {
      areaCounts[area] = (areaCounts[area] ?? 0) + 1;
    }

    final genre = _genreFor(post);
    if (genre != null) {
      genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
    }

    final timeZone = _timeZoneFor(post.createdAt.hour);
    timeCounts[timeZone] = (timeCounts[timeZone] ?? 0) + 1;

    final restaurant = post.restaurant.trim();
    if (restaurant.isNotEmpty) {
      restaurantCounts[restaurant] = (restaurantCounts[restaurant] ?? 0) + 1;
    }

    if (post.star > 0) {
      ratingTotal += post.star;
      ratingCount++;
    }
  }

  final topArea = _topEntry(areaCounts);
  final topGenre = _topEntry(genreCounts);
  final topTime = _topEntry(timeCounts);
  final topRestaurant = _topEntry(restaurantCounts);
  final exploratory = _explorationStats(posts);
  final averageRating = ratingCount == 0 ? null : (ratingTotal / ratingCount);

  return RecordFoodTraitsSummary(
    totalPosts: posts.length,
    topArea: topArea?.$1,
    topAreaCount: topArea?.$2 ?? 0,
    topGenre: topGenre?.$1,
    topGenreCount: topGenre?.$2 ?? 0,
    topTimeSlot: topTime?.$1,
    topTimeCount: topTime?.$2 ?? 0,
    topRestaurant: topRestaurant?.$1,
    topRestaurantCount: topRestaurant?.$2 ?? 0,
    averageRating: averageRating,
    ratingCount: ratingCount,
    explorationRatio: exploratory.$1,
    firstVisitCount: exploratory.$2,
  );
}

(T, int)? _topEntry<T>(Map<T, int> source) {
  if (source.isEmpty) {
    return null;
  }
  final list = source.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) {
        return byCount;
      }
      return a.key.toString().compareTo(b.key.toString());
    });
  final top = list.first;
  return (top.key, top.value);
}

(int, int) _explorationStats(List<Posts> posts) {
  if (posts.isEmpty) {
    return (0, 0);
  }
  final sorted = [...posts]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  final seen = <String>{};
  var firstVisitCount = 0;
  var validRestaurantPosts = 0;

  for (final post in sorted) {
    final shop = post.restaurant.trim();
    if (shop.isEmpty) {
      continue;
    }
    validRestaurantPosts++;
    if (seen.add(shop)) {
      firstVisitCount++;
    }
  }
  if (validRestaurantPosts == 0) {
    return (0, 0);
  }
  final ratio = ((firstVisitCount / validRestaurantPosts) * 100).round();
  return (ratio, firstVisitCount);
}

/// 投稿の緯度経度から都道府県名（日本）または国コードを返す。
/// 記録タブのカード表示などで利用する公開ヘルパー。
String? recordPostAreaLabel(Posts post) => _areaFor(post);

String? _areaFor(Posts post) {
  if (post.lat == 0 || post.lng == 0) {
    return null;
  }
  final countryCode = CountryDetector.getCountryCode(post.lat, post.lng);
  if (countryCode == 'JP') {
    final prefecture = PrefectureDetector.detectPrefecture(post.lat, post.lng);
    if (prefecture != null && prefecture.isNotEmpty) {
      return prefecture;
    }
  }
  return countryCode;
}

String? _genreFor(Posts post) {
  final raw = post.foodTag.trim();
  if (raw.isEmpty) {
    return null;
  }
  final first = raw.split(',').first.trim();
  return first.isEmpty ? null : first;
}

RecordMealTimeSlot _timeZoneFor(int hour) {
  if (hour >= 5 && hour < 11) {
    return RecordMealTimeSlot.morning;
  }
  if (hour >= 11 && hour < 15) {
    return RecordMealTimeSlot.lunch;
  }
  if (hour >= 15 && hour < 18) {
    return RecordMealTimeSlot.afternoon;
  }
  if (hour >= 18 && hour < 22) {
    return RecordMealTimeSlot.evening;
  }
  return RecordMealTimeSlot.lateNight;
}

int recordFoodTraitsRatio(int count, int total) =>
    (count / total * 100).round();

String recordFoodTraitsTimeSlotLabel(Translations t, RecordMealTimeSlot slot) {
  return switch (slot) {
    RecordMealTimeSlot.morning => t.myMapRecord.foodTraits.morningLabel,
    RecordMealTimeSlot.lunch => t.myMapRecord.foodTraits.lunchLabel,
    RecordMealTimeSlot.afternoon => t.myMapRecord.foodTraits.afternoonLabel,
    RecordMealTimeSlot.evening => t.myMapRecord.foodTraits.eveningLabel,
    RecordMealTimeSlot.lateNight => t.myMapRecord.foodTraits.lateNightLabel,
  };
}
