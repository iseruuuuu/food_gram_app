import 'package:flutter_test/flutter_test.dart';
import 'package:food_gram_app/core/review/in_app_review_service.dart';

void main() {
  group('InAppReviewService.shouldShowReviewByDate（頻度制限ロジック）', () {
    test('最後のレビュー日が空のときは表示可能', () {
      final now = DateTime(2024, 6, 1, 12);
      expect(
        InAppReviewService.shouldShowReviewByDate('', 7, now),
        isTrue,
      );
    });

    test('最後のレビューから7日未満のときは表示しない', () {
      final now = DateTime(2024, 6, 1, 12);
      final lastReview = DateTime(2024, 5, 28, 12); // 4日前
      expect(
        InAppReviewService.shouldShowReviewByDate(
          lastReview.toIso8601String(),
          7,
          now,
        ),
        isFalse,
      );
    });

    test('最後のレビューからちょうど7日のときは表示可能', () {
      final now = DateTime(2024, 6, 1, 12);
      final lastReview = DateTime(2024, 5, 25, 12); // 7日前
      expect(
        InAppReviewService.shouldShowReviewByDate(
          lastReview.toIso8601String(),
          7,
          now,
        ),
        isTrue,
      );
    });

    test('最後のレビューから7日超のときは表示可能', () {
      final now = DateTime(2024, 6, 1, 12);
      final lastReview = DateTime(2024, 5, 20, 12); // 12日前
      expect(
        InAppReviewService.shouldShowReviewByDate(
          lastReview.toIso8601String(),
          7,
          now,
        ),
        isTrue,
      );
    });

    test('minDays を 30 にした場合、30日経過で表示可能', () {
      final now = DateTime(2024, 6, 1, 12);
      final lastReview = DateTime(2024, 4, 30, 12); // 32日前
      expect(
        InAppReviewService.shouldShowReviewByDate(
          lastReview.toIso8601String(),
          30,
          now,
        ),
        isTrue,
      );
    });

    test('minDays を 30 にした場合、29日では表示しない', () {
      final now = DateTime(2024, 6, 1, 12);
      final lastReview = DateTime(2024, 5, 3, 12); // 29日前
      expect(
        InAppReviewService.shouldShowReviewByDate(
          lastReview.toIso8601String(),
          30,
          now,
        ),
        isFalse,
      );
    });
  });

  group('InAppReviewService.shouldShowReviewFor7DayMilestone（7日経過ロジック）', () {
    test('初回起動日が空のときは表示しない（未記録）', () {
      final now = DateTime(2024, 6, 1, 12);
      expect(
        InAppReviewService.shouldShowReviewFor7DayMilestone('', 7, now),
        isFalse,
      );
    });

    test('初回起動から6日では表示しない', () {
      final now = DateTime(2024, 6, 7, 12);
      final firstLaunch = DateTime(2024, 6, 1, 12); // 6日前
      expect(
        InAppReviewService.shouldShowReviewFor7DayMilestone(
          firstLaunch.toIso8601String(),
          7,
          now,
        ),
        isFalse,
      );
    });

    test('初回起動からちょうど7日で表示可能', () {
      final now = DateTime(2024, 6, 8, 12);
      final firstLaunch = DateTime(2024, 6, 1, 12); // 7日前
      expect(
        InAppReviewService.shouldShowReviewFor7DayMilestone(
          firstLaunch.toIso8601String(),
          7,
          now,
        ),
        isTrue,
      );
    });

    test('初回起動から7日超で表示可能', () {
      final now = DateTime(2024, 6, 15, 12);
      final firstLaunch = DateTime(2024, 6, 1, 12); // 14日前
      expect(
        InAppReviewService.shouldShowReviewFor7DayMilestone(
          firstLaunch.toIso8601String(),
          7,
          now,
        ),
        isTrue,
      );
    });

    test('requiredDays を 14 にした場合、13日では表示しない', () {
      final now = DateTime(2024, 6, 14, 12);
      final firstLaunch = DateTime(2024, 6, 1, 12); // 13日前
      expect(
        InAppReviewService.shouldShowReviewFor7DayMilestone(
          firstLaunch.toIso8601String(),
          14,
          now,
        ),
        isFalse,
      );
    });

    test('requiredDays を 14 にした場合、14日経過で表示可能', () {
      final now = DateTime(2024, 6, 15, 12);
      final firstLaunch = DateTime(2024, 6, 1, 12); // 14日前
      expect(
        InAppReviewService.shouldShowReviewFor7DayMilestone(
          firstLaunch.toIso8601String(),
          14,
          now,
        ),
        isTrue,
      );
    });
  });
}
