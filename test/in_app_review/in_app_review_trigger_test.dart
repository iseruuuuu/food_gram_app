import 'package:flutter_test/flutter_test.dart';

void main() {
  group('In-App Review 表示タイミング（投稿成功後）', () {
    // post_screen.dart と同じ判定ロジック
    bool shouldShowReviewForStreakResult(int newStreakWeeks) {
      final isFirstTime = newStreakWeeks == 1;
      const milestoneWeeks = [3, 5, 10];
      final isMilestone = milestoneWeeks.contains(newStreakWeeks);
      return isFirstTime || isMilestone;
    }

    test('初回投稿（1週）のときはレビューを表示する', () {
      expect(shouldShowReviewForStreakResult(1), isTrue);
    });

    test('ストリーク2週のときはレビューを表示しない', () {
      expect(shouldShowReviewForStreakResult(2), isFalse);
    });

    test('ストリーク3週（節目）のときはレビューを表示する', () {
      expect(shouldShowReviewForStreakResult(3), isTrue);
    });

    test('ストリーク4週のときはレビューを表示しない', () {
      expect(shouldShowReviewForStreakResult(4), isFalse);
    });

    test('ストリーク5週（節目）のときはレビューを表示する', () {
      expect(shouldShowReviewForStreakResult(5), isTrue);
    });

    test('ストリーク6週のときはレビューを表示しない', () {
      expect(shouldShowReviewForStreakResult(6), isFalse);
    });

    test('ストリーク10週（節目）のときはレビューを表示する', () {
      expect(shouldShowReviewForStreakResult(10), isTrue);
    });

    test('ストリーク11週以上のときはレビューを表示しない', () {
      expect(shouldShowReviewForStreakResult(11), isFalse);
      expect(shouldShowReviewForStreakResult(20), isFalse);
    });

    test('節目は 1, 3, 5, 10 週のみでそれ以外は表示しない', () {
      final showWeeks = [1, 3, 5, 10];
      final noShowWeeks = [2, 4, 6, 7, 8, 9, 11, 12];

      for (final week in showWeeks) {
        expect(
          shouldShowReviewForStreakResult(week),
          isTrue,
          reason: '$week 週は表示する',
        );
      }
      for (final week in noShowWeeks) {
        expect(
          shouldShowReviewForStreakResult(week),
          isFalse,
          reason: '$week 週は表示しない',
        );
      }
    });
  });
}
