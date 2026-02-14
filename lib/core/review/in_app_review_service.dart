import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:logger/logger.dart';

/// In-App Reviewを管理するサービス
class InAppReviewService {
  final InAppReview _inAppReview = InAppReview.instance;
  final Preference _preference = Preference();
  final Logger _logger = Logger();

  /// 最後のレビュー表示日と経過日数から、表示可能かどうかを判定する
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

  /// 初回起動日から [requiredDays] 日経過したかどうかを判定する
  /// [firstLaunchDateStr] 初回起動日（ISO8601）。空の場合は未記録として false
  /// [requiredDays] 必要経過日数（例: 7）
  /// [now] 現在日時
  static bool shouldShowReviewFor7DayMilestone(
    String firstLaunchDateStr,
    int requiredDays,
    DateTime now,
  ) {
    if (firstLaunchDateStr.isEmpty) {
      return false;
    }
    final firstLaunch = DateTime.parse(firstLaunchDateStr);
    final days = now.difference(firstLaunch).inDays;
    return days >= requiredDays;
  }

  /// アプリ初回起動から [daysSinceFirstLaunch] 日経過時にレビューを表示する（定着ユーザー向け）
  /// 初回起動日が未設定の場合は今を記録して何もしない
  Future<void> maybeRequestReviewFor7DayMilestone({
    int daysSinceFirstLaunch = 7,
  }) async {
    try {
      final firstLaunchStr =
          await _preference.getString(PreferenceKey.firstLaunchDate);

      if (firstLaunchStr.isEmpty) {
        await _preference.setString(
          PreferenceKey.firstLaunchDate,
          DateTime.now().toIso8601String(),
        );
        _logger.d('First launch date saved');
        return;
      }

      if (shouldShowReviewFor7DayMilestone(
        firstLaunchStr,
        daysSinceFirstLaunch,
        DateTime.now(),
      )) {
        await requestReview();
      }
    } on Exception catch (e) {
      _logger.e('Error in 7-day review check: $e');
    }
  }
}
