import 'dart:math';

import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/model/weekly_summary.dart';
import 'package:food_gram_app/core/model/weekly_summary_period.dart';

/// 週次まとめの純関数集計
WeeklySummary calculateWeeklySummary({
  required List<Posts> allPosts,
  required WeeklySummaryPeriod period,
  required int streakWeeks,
  Random? random,
}) {
  final weekPosts = allPosts
      .where((p) => period.contains(p.createdAt))
      .toList(growable: false);

  final postedWeekdays = List<bool>.filled(7, false);
  for (final post in weekPosts) {
    final local = post.createdAt.toLocal();
    final weekdayIndex = local.weekday - DateTime.monday;
    if (weekdayIndex >= 0 && weekdayIndex < 7) {
      postedWeekdays[weekdayIndex] = true;
    }
  }

  final priorRestaurantNames = <String>{};
  for (final post in allPosts) {
    if (post.createdAt.toLocal().isBefore(period.weekStart)) {
      final name = post.restaurant.trim();
      if (name.isNotEmpty) {
        priorRestaurantNames.add(name);
      }
    }
  }

  final newRestaurants = <String>{};
  for (final post in weekPosts) {
    final name = post.restaurant.trim();
    if (name.isEmpty) {
      continue;
    }
    if (!priorRestaurantNames.contains(name)) {
      newRestaurants.add(name);
    }
  }

  var averageStar = 0.0;
  if (weekPosts.isNotEmpty) {
    final sum = weekPosts.fold<double>(0, (acc, p) => acc + p.star);
    averageStar = sum / weekPosts.length;
  }

  Posts? bestPost;
  if (weekPosts.isNotEmpty) {
    final rng = random ?? Random();
    bestPost = weekPosts[rng.nextInt(weekPosts.length)];
  }

  return WeeklySummary(
    period: period,
    postCount: weekPosts.length,
    newRestaurantCount: newRestaurants.length,
    averageStar: averageStar,
    postedWeekdays: postedWeekdays,
    streakWeeks: streakWeeks,
    bestPost: bestPost,
    weekPosts: weekPosts,
    topGenres: topGenresFromPosts(weekPosts),
  );
}

/// 週内投稿の foodTag を集計し、件数上位最大3件を返す
List<WeeklySummaryGenreRank> topGenresFromPosts(List<Posts> weekPosts) {
  final counts = <String, int>{};
  for (final post in weekPosts) {
    for (final tagId in parseFoodTagIds(post.foodTag)) {
      counts[tagId] = (counts[tagId] ?? 0) + 1;
    }
  }
  if (counts.isEmpty) {
    return const [];
  }
  final entries = counts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) {
        return byCount;
      }
      return a.key.compareTo(b.key);
    });
  return entries
      .take(3)
      .map(
        (e) => WeeklySummaryGenreRank(tagId: e.key, count: e.value),
      )
      .toList(growable: false);
}
