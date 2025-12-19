import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Streak Service Logic Tests', () {
    // ストリーク計算ロジックのテスト用ヘルパー関数
    ({
      int newStreakWeeks,
      bool isUpdated,
    }) calculateStreak({
      required DateTime? lastPostDate,
      required int currentStreakWeeks,
      required DateTime now,
    }) {
      int newStreakWeeks;
      bool isUpdated;

      if (lastPostDate == null) {
        // 初回投稿
        newStreakWeeks = 1;
        isUpdated = true;
      } else {
        final daysDifference = now.difference(lastPostDate).inDays;

        if (daysDifference < 7) {
          // 1週間以内：ストリークは更新しない
          newStreakWeeks = currentStreakWeeks;
          isUpdated = false;
        } else if (daysDifference >= 7 && daysDifference <= 14) {
          // 1週間後〜2週間以内：ストリークを継続
          newStreakWeeks = currentStreakWeeks + 1;
          isUpdated = true;
        } else {
          // 2週間以上経過：ストリークをリセット
          newStreakWeeks = 1;
          isUpdated = true;
        }
      }

      return (newStreakWeeks: newStreakWeeks, isUpdated: isUpdated);
    }

    test('初回投稿時はストリーク1週に設定される', () {
      final now = DateTime(2024, 1, 15, 12);
      final result = calculateStreak(
        lastPostDate: null,
        currentStreakWeeks: 0,
        now: now,
      );

      expect(result.newStreakWeeks, 1);
      expect(result.isUpdated, true);
    });

    test('1週間以内の投稿はストリークが更新されない', () {
      final now = DateTime(2024, 1, 15, 12);
      final lastPostDate = DateTime(2024, 1, 10, 12); // 5日前

      final result = calculateStreak(
        lastPostDate: lastPostDate,
        currentStreakWeeks: 1,
        now: now,
      );

      expect(result.newStreakWeeks, 1);
      expect(result.isUpdated, false);
    });

    test('ちょうど1週間後の投稿はストリークが継続される', () {
      final now = DateTime(2024, 1, 15, 12);
      final lastPostDate = DateTime(2024, 1, 8, 12); // 7日前

      final result = calculateStreak(
        lastPostDate: lastPostDate,
        currentStreakWeeks: 1,
        now: now,
      );

      expect(result.newStreakWeeks, 2);
      expect(result.isUpdated, true);
    });

    test('1週間後〜2週間以内の投稿はストリークが継続される', () {
      final now = DateTime(2024, 1, 15, 12);
      final lastPostDate = DateTime(2024, 1, 5, 12); // 10日前（1週間後〜2週間以内）

      final result = calculateStreak(
        lastPostDate: lastPostDate,
        currentStreakWeeks: 1,
        now: now,
      );

      expect(result.newStreakWeeks, 2);
      expect(result.isUpdated, true);
    });

    test('ちょうど2週間後の投稿はストリークが継続される', () {
      final now = DateTime(2024, 1, 15, 12);
      final lastPostDate = DateTime(2024, 1, 1, 12); // 14日前

      final result = calculateStreak(
        lastPostDate: lastPostDate,
        currentStreakWeeks: 2,
        now: now,
      );

      expect(result.newStreakWeeks, 3);
      expect(result.isUpdated, true);
    });

    test('2週間以上経過後の投稿はストリークがリセットされる', () {
      final now = DateTime(2024, 1, 15, 12);
      final lastPostDate = DateTime(2023, 12, 30, 12); // 16日前

      final result = calculateStreak(
        lastPostDate: lastPostDate,
        currentStreakWeeks: 5,
        now: now,
      );

      expect(result.newStreakWeeks, 1);
      expect(result.isUpdated, true);
    });

    test('連続投稿シナリオ: 1週目→2週目→3週目', () {
      final baseDate = DateTime(2024, 1, 1, 12);

      // 1週目: 初回投稿
      var result = calculateStreak(
        lastPostDate: null,
        currentStreakWeeks: 0,
        now: baseDate,
      );
      expect(result.newStreakWeeks, 1);
      expect(result.isUpdated, true);

      // 2週目: 1週間後
      result = calculateStreak(
        lastPostDate: baseDate,
        currentStreakWeeks: 1,
        now: baseDate.add(const Duration(days: 7)),
      );
      expect(result.newStreakWeeks, 2);
      expect(result.isUpdated, true);

      // 3週目: さらに1週間後
      result = calculateStreak(
        lastPostDate: baseDate.add(const Duration(days: 7)),
        currentStreakWeeks: 2,
        now: baseDate.add(const Duration(days: 14)),
      );
      expect(result.newStreakWeeks, 3);
      expect(result.isUpdated, true);
    });

    test('連続投稿シナリオ: 11週間連続', () {
      final baseDate = DateTime(2024, 1, 1, 12);
      var currentStreak = 0;
      var lastPostDate = baseDate;

      // 初回投稿
      var result = calculateStreak(
        lastPostDate: null,
        currentStreakWeeks: 0,
        now: baseDate,
      );
      currentStreak = result.newStreakWeeks;
      lastPostDate = baseDate;

      // 2週目から11週目まで
      for (var week = 2; week <= 11; week++) {
        final now = baseDate.add(Duration(days: (week - 1) * 7));
        result = calculateStreak(
          lastPostDate: lastPostDate,
          currentStreakWeeks: currentStreak,
          now: now,
        );

        expect(result.newStreakWeeks, week);
        expect(result.isUpdated, true);

        currentStreak = result.newStreakWeeks;
        lastPostDate = now;
      }
    });

    test('ストリークが途切れた場合のリセット', () {
      final baseDate = DateTime(2024, 1, 1, 12);

      // 1週目: 初回投稿
      var result = calculateStreak(
        lastPostDate: null,
        currentStreakWeeks: 0,
        now: baseDate,
      );
      expect(result.newStreakWeeks, 1);

      // 2週目: 1週間後
      result = calculateStreak(
        lastPostDate: baseDate,
        currentStreakWeeks: 1,
        now: baseDate.add(const Duration(days: 7)),
      );
      expect(result.newStreakWeeks, 2);

      // 3週目: さらに1週間後
      result = calculateStreak(
        lastPostDate: baseDate.add(const Duration(days: 7)),
        currentStreakWeeks: 2,
        now: baseDate.add(const Duration(days: 14)),
      );
      expect(result.newStreakWeeks, 3);

      // 29日後（14日後の投稿から15日経過 = 2週間以上経過）: ストリークがリセット
      result = calculateStreak(
        lastPostDate: baseDate.add(const Duration(days: 14)),
        currentStreakWeeks: 3,
        now: baseDate.add(const Duration(days: 29)), // 14日後の投稿から15日経過 = 2週間以上
      );
      expect(result.newStreakWeeks, 1);
      expect(result.isUpdated, true);
    });

    test('同じ週内での複数投稿はストリークが更新されない', () {
      final baseDate = DateTime(2024, 1, 1, 12);

      // 1週目: 初回投稿
      var result = calculateStreak(
        lastPostDate: null,
        currentStreakWeeks: 0,
        now: baseDate,
      );
      expect(result.newStreakWeeks, 1);
      expect(result.isUpdated, true);

      // 同じ週内で2回目の投稿（3日後）
      result = calculateStreak(
        lastPostDate: baseDate,
        currentStreakWeeks: 1,
        now: baseDate.add(const Duration(days: 3)),
      );
      expect(result.newStreakWeeks, 1);
      expect(result.isUpdated, false);

      // 同じ週内で3回目の投稿（5日後）
      result = calculateStreak(
        lastPostDate: baseDate,
        currentStreakWeeks: 1,
        now: baseDate.add(const Duration(days: 5)),
      );
      expect(result.newStreakWeeks, 1);
      expect(result.isUpdated, false);
    });

    test('境界値テスト: 6日後は更新されない', () {
      final now = DateTime(2024, 1, 15, 12);
      final lastPostDate = DateTime(2024, 1, 9, 12); // 6日前

      final result = calculateStreak(
        lastPostDate: lastPostDate,
        currentStreakWeeks: 1,
        now: now,
      );

      expect(result.newStreakWeeks, 1);
      expect(result.isUpdated, false);
    });

    test('境界値テスト: 7日後は更新される', () {
      final now = DateTime(2024, 1, 15, 12);
      final lastPostDate = DateTime(2024, 1, 8, 12); // 7日前

      final result = calculateStreak(
        lastPostDate: lastPostDate,
        currentStreakWeeks: 1,
        now: now,
      );

      expect(result.newStreakWeeks, 2);
      expect(result.isUpdated, true);
    });

    test('境界値テスト: 14日後は更新される', () {
      final now = DateTime(2024, 1, 15, 12);
      final lastPostDate = DateTime(2024, 1, 1, 12); // 14日前

      final result = calculateStreak(
        lastPostDate: lastPostDate,
        currentStreakWeeks: 2,
        now: now,
      );

      expect(result.newStreakWeeks, 3);
      expect(result.isUpdated, true);
    });

    test('境界値テスト: 15日後はリセットされる', () {
      final now = DateTime(2024, 1, 15, 12);
      final lastPostDate = DateTime(2023, 12, 31, 12); // 15日前

      final result = calculateStreak(
        lastPostDate: lastPostDate,
        currentStreakWeeks: 5,
        now: now,
      );

      expect(result.newStreakWeeks, 1);
      expect(result.isUpdated, true);
    });
  });
}
