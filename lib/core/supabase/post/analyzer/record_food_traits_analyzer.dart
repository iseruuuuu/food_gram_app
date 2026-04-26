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
