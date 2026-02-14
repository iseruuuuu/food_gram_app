import 'package:flutter_test/flutter_test.dart';
import 'package:food_gram_app/core/review/in_app_review_service.dart';

void main() {
  group('InAppReviewService.shouldShowReviewByDate（頻度制限ロジック）', () {
    test('最後のレビュー日が空のときは表示可能', () {
      final now = DateTime(2024, 6, 1, 12);
      expect(
        InAppReviewService.shouldShowReviewByDate('', 14, now),
        isTrue,
      );
    });

    test('最後のレビューから14日未満のときは表示しない', () {
      final now = DateTime(2024, 6, 1, 12);
      final lastReview = DateTime(2024, 5, 25, 12); // 7日前
      expect(
        InAppReviewService.shouldShowReviewByDate(
          lastReview.toIso8601String(),
          14,
          now,
        ),
        isFalse,
      );
    });

    test('最後のレビューからちょうど14日のときは表示可能', () {
      final now = DateTime(2024, 6, 1, 12);
      final lastReview = DateTime(2024, 5, 18, 12); // 14日前
      expect(
        InAppReviewService.shouldShowReviewByDate(
          lastReview.toIso8601String(),
          14,
          now,
        ),
        isTrue,
      );
    });

    test('最後のレビューから14日超のときは表示可能', () {
      final now = DateTime(2024, 6, 1, 12);
      final lastReview = DateTime(2024, 5, 1, 12); // 31日前
      expect(
        InAppReviewService.shouldShowReviewByDate(
          lastReview.toIso8601String(),
          14,
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
}
