import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/weekly_summary_period.dart';
import 'package:food_gram_app/core/weekly_summary/weekly_summary_calculator.dart';

Posts _post({
  required int id,
  required DateTime createdAt,
  String restaurant = '店A',
  double star = 4.0,
  String foodTag = '',
}) {
  return Posts(
    id: id,
    foodImage: 'user/food.jpg',
    foodName: 'Food $id',
    restaurant: restaurant,
    comment: '',
    createdAt: createdAt,
    lat: 0,
    lng: 0,
    userId: 'user',
    heart: 0,
    star: star,
    foodTag: foodTag,
    isAnonymous: false,
  );
}

void main() {
  group('WeeklySummaryPeriod', () {
    test('月曜起動時は直前の月〜日を返す', () {
      // 2026-07-13 は月曜 → 先週は 7/6(月)〜7/12(日)
      final monday = DateTime(2026, 7, 13, 10);
      final period = WeeklySummaryPeriod.previousWeek(monday);
      expect(period.weekStart, DateTime(2026, 7, 6));
      expect(period.weekEndExclusive, DateTime(2026, 7, 13));
      expect(period.weekEndInclusive, DateTime(2026, 7, 12));
      expect(period.preferenceKey, '2026-07-06');
    });

    test('contains は週境界を正しく判定する', () {
      final period = WeeklySummaryPeriod(
        weekStart: DateTime(2026, 7, 7),
        weekEndExclusive: DateTime(2026, 7, 14),
      );
      expect(period.contains(DateTime(2026, 7, 7)), isTrue);
      expect(period.contains(DateTime(2026, 7, 13, 23, 59)), isTrue);
      expect(period.contains(DateTime(2026, 7, 6, 23, 59)), isFalse);
      expect(period.contains(DateTime(2026, 7, 14)), isFalse);
    });
  });

  group('calculateWeeklySummary', () {
    final period = WeeklySummaryPeriod(
      weekStart: DateTime(2026, 7, 7),
      weekEndExclusive: DateTime(2026, 7, 14),
    );

    test('週内投稿のみを集計し平均評価を出す', () {
      // 2026-07-07=火, 2026-07-10=金
      final posts = [
        _post(id: 1, createdAt: DateTime(2026, 7, 6), star: 5), // 週外
        _post(id: 2, createdAt: DateTime(2026, 7, 7)),
        _post(id: 3, createdAt: DateTime(2026, 7, 10), star: 5),
        _post(id: 4, createdAt: DateTime(2026, 7, 14), star: 1), // 週外
      ];
      final summary = calculateWeeklySummary(
        allPosts: posts,
        period: period,
        streakWeeks: 3,
        random: Random(1),
      );
      expect(summary.postCount, 2);
      expect(summary.averageStar, 4.5);
      expect(summary.streakWeeks, 3);
      expect(summary.postedWeekdays[0], isFalse); // 月
      expect(summary.postedWeekdays[1], isTrue); // 火
      expect(summary.postedWeekdays[4], isTrue); // 金
      expect(summary.postedWeekdays[6], isFalse); // 日
    });

    test('新しいお店は過去に同名がない店だけ数える', () {
      final posts = [
        _post(
          id: 1,
          createdAt: DateTime(2026, 6),
          restaurant: '既存店',
        ),
        _post(
          id: 2,
          createdAt: DateTime(2026, 7, 8),
          restaurant: '既存店',
        ),
        _post(
          id: 3,
          createdAt: DateTime(2026, 7, 9),
          restaurant: '新店A',
        ),
        _post(
          id: 4,
          createdAt: DateTime(2026, 7, 10),
          restaurant: '新店B',
        ),
        _post(
          id: 5,
          createdAt: DateTime(2026, 7, 11),
          restaurant: '新店A',
        ),
      ];
      final summary = calculateWeeklySummary(
        allPosts: posts,
        period: period,
        streakWeeks: 1,
        random: Random(0),
      );
      expect(summary.newRestaurantCount, 2);
    });

    test('ベスト写真は週内投稿から選ばれる', () {
      final posts = [
        _post(id: 10, createdAt: DateTime(2026, 7)),
        _post(id: 20, createdAt: DateTime(2026, 7, 8)),
        _post(id: 30, createdAt: DateTime(2026, 7, 12)),
      ];
      final summary = calculateWeeklySummary(
        allPosts: posts,
        period: period,
        streakWeeks: 0,
        random: Random(42),
      );
      expect(summary.bestPost, isNotNull);
      expect([20, 30], contains(summary.bestPost!.id));
      expect(summary.bestPost!.id, isNot(10));
    });

    test('週内投稿がなければベストは null', () {
      final posts = [
        _post(id: 1, createdAt: DateTime(2026, 7)),
      ];
      final summary = calculateWeeklySummary(
        allPosts: posts,
        period: period,
        streakWeeks: 0,
        random: Random(0),
      );
      expect(summary.hasPosts, isFalse);
      expect(summary.bestPost, isNull);
      expect(summary.topGenres, isEmpty);
    });

    test('ジャンル TOP3 は件数順で最大3件', () {
      final posts = [
        _post(id: 1, createdAt: DateTime(2026, 7, 8), foodTag: '🍜'),
        _post(id: 2, createdAt: DateTime(2026, 7, 8), foodTag: '🍜'),
        _post(id: 3, createdAt: DateTime(2026, 7, 9), foodTag: '🍜'),
        _post(id: 4, createdAt: DateTime(2026, 7, 9), foodTag: '🍖'),
        _post(id: 5, createdAt: DateTime(2026, 7, 10), foodTag: '🍖'),
        _post(id: 6, createdAt: DateTime(2026, 7, 10), foodTag: '🍰'),
        _post(id: 7, createdAt: DateTime(2026, 7, 11), foodTag: '🍕'),
        _post(id: 8, createdAt: DateTime(2026, 7), foodTag: '🍜'), // 週外
      ];
      final summary = calculateWeeklySummary(
        allPosts: posts,
        period: period,
        streakWeeks: 0,
        random: Random(0),
      );
      expect(summary.topGenres.length, 3);
      expect(summary.topGenres[0].tagId, '🍜');
      expect(summary.topGenres[0].count, 3);
      expect(summary.topGenres[1].tagId, '🍖');
      expect(summary.topGenres[1].count, 2);
      // 同数なら tagId 昇順 → 🍕 が 🍰 より先
      expect(summary.topGenres[2].tagId, '🍕');
      expect(summary.topGenres[2].count, 1);
    });
  });
}
