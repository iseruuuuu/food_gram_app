import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:logger/logger.dart';

/// In-App Reviewを管理するサービス
class InAppReviewService {
  final InAppReview _inAppReview = InAppReview.instance;
  final Preference _preference = Preference();
  final Logger _logger = Logger();

  /// 最後のレビュー表示日と経過日数から、表示可能かどうかを判定する（テスト用に公開）
  /// [lastReviewDateStr] 最後のレビュー表示日（ISO8601）。空の場合は初回として true
  /// [minDays] 最低経過日数
  /// [now] 現在日時
  static bool shouldShowReviewByDate(
    String lastReviewDateStr,
    int minDays,
    DateTime now,
  ) {
    if (lastReviewDateStr.isEmpty) {
      return true;
    }
    final lastReviewDate = DateTime.parse(lastReviewDateStr);
    final daysSinceLastReview = now.difference(lastReviewDate).inDays;
    return daysSinceLastReview >= minDays;
  }

  /// レビューを表示するかどうかを判定
  /// [minDaysSinceLastReview] 最後のレビュー表示から最低経過日数（デフォルト: 14日＝2週間）
  Future<bool> shouldShowReview({int minDaysSinceLastReview = 14}) async {
    try {
      // In-App Reviewが利用可能かチェック
      final isAvailable = await _inAppReview.isAvailable();
      if (!isAvailable) {
        _logger.d('In-App Review is not available');
        return false;
      }

      // 最後のレビュー表示日を取得
      final lastReviewDateStr =
          await _preference.getString(PreferenceKey.lastReviewRequestDate);

      return shouldShowReviewByDate(
        lastReviewDateStr,
        minDaysSinceLastReview,
        DateTime.now(),
      );
    } on Exception catch (e) {
      _logger.e('Error checking review availability: $e');
      return false;
    }
  }

  /// レビューを表示
  /// [minDaysSinceLastReview] 最後のレビュー表示から最低経過日数（デフォルト: 14日＝2週間）
  Future<void> requestReview({int minDaysSinceLastReview = 14}) async {
    try {
      // レビューを表示するかどうかを判定
      if (!await shouldShowReview(
        minDaysSinceLastReview: minDaysSinceLastReview,
      )) {
        _logger.d('Review request skipped due to frequency limit');
        return;
      }

      // レビューを表示
      await _inAppReview.requestReview();

      // レビュー表示日を記録
      await _preference.setString(
        PreferenceKey.lastReviewRequestDate,
        DateTime.now().toIso8601String(),
      );

      _logger.i('In-App Review requested successfully');
    } on Exception catch (e) {
      _logger.e('Error requesting review: $e');
    }
  }
}
