import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/summary/weekly/weekly_summary_period.dart';

/// 週内で食べたジャンルの順位
class WeeklySummaryGenreRank {
  const WeeklySummaryGenreRank({
    required this.tagId,
    required this.count,
  });

  final String tagId;
  final int count;
}

/// 週次まとめの集計結果
class WeeklySummary {
  const WeeklySummary({
    required this.period,
    required this.postCount,
    required this.newRestaurantCount,
    required this.averageStar,
    required this.postedWeekdays,
    required this.streakWeeks,
    required this.bestPost,
    required this.weekPosts,
    required this.topGenres,
  });

  final WeeklySummaryPeriod period;
  final int postCount;
  final int newRestaurantCount;
  final double averageStar;

  /// 月〜日（index 0=月 … 6=日）に投稿があったか
  final List<bool> postedWeekdays;
  final int streakWeeks;
  final Posts? bestPost;
  final List<Posts> weekPosts;

  /// 件数上位のジャンル（最大3件）
  final List<WeeklySummaryGenreRank> topGenres;

  bool get hasPosts => postCount > 0;
}
