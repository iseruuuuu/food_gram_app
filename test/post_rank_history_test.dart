import 'package:flutter_test/flutter_test.dart';
import 'package:food_gram_app/core/local/post_rank_history.dart';

void main() {
  group('PostRankHistory', () {
    test('first open has no day or month baseline', () {
      final comparison = const PostRankHistory({}).compare(
        currentRank: 42,
        today: DateTime(2026, 10, 14),
      );

      expect(comparison.currentRank, 42);
      expect(comparison.dayDelta, isNull);
      expect(comparison.monthDelta, isNull);
      expect(comparison.hasNoBaseline, isTrue);
    });

    test('day delta uses the latest earlier day and ignores today', () {
      const history = PostRankHistory({
        '2026-10-14': 10,
        '2026-10-12': 20,
        '2026-10-10': 30,
      });

      final comparison = history.compare(
        currentRank: 15,
        today: DateTime(2026, 10, 14),
      );

      expect(comparison.dayDelta, 5);
      expect(comparison.monthDelta, isNull);
    });

    test('negative delta means the rank number got worse', () {
      final comparison = const PostRankHistory({'2026-10-13': 8}).compare(
        currentRank: 13,
        today: DateTime(2026, 10, 14),
      );

      expect(comparison.dayDelta, -5);
    });

    test('month delta uses the latest day in the previous month', () {
      const history = PostRankHistory({
        '2026-09-02': 40,
        '2026-09-28': 30,
        '2026-08-31': 10,
        '2026-10-13': 28,
      });

      final comparison = history.compare(
        currentRank: 33,
        today: DateTime(2026, 10, 14),
      );

      expect(comparison.dayDelta, -5);
      expect(comparison.monthDelta, -3);
    });

    test('January compares with December of the previous year', () {
      final comparison = const PostRankHistory({
        '2025-12-31': 12,
        '2026-01-01': 9,
      }).compare(
        currentRank: 9,
        today: DateTime(2026, 1, 2),
      );

      expect(comparison.dayDelta, 0);
      expect(comparison.monthDelta, 3);
    });

    test('record overwrites today and drops expired days', () {
      final updated = const PostRankHistory({
        '2025-09-01': 99,
        '2026-10-01': 20,
        '2026-10-14': 18,
        'not-a-date': 1,
      }).record(
        today: DateTime(2026, 10, 14),
        rank: 16,
      );

      expect(updated.days.containsKey('2025-09-01'), isFalse);
      expect(updated.days['2026-10-01'], 20);
      expect(updated.days['2026-10-14'], 16);
      expect(updated.days.containsKey('not-a-date'), isFalse);
    });

    test('decode skips broken values and keeps valid days', () {
      final history = PostRankHistory.decode(
        '{"2026-10-01": 12, "bad": 3, "2026-02-31": 4, "2026-10-02": 0}',
      );

      expect(history.days, {'2026-10-01': 12});
    });
  });
}
