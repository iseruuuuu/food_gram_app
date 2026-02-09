import 'package:food_gram_app/core/model/model.dart';

/// タイムラインから詳細画面へ遷移する際の extra。
/// カテゴリタブから遷移した場合は [categoryName] を渡し、
/// 詳細画面の2件目以降をそのカテゴリでフィルタするために使う。
class TimelineDetailExtra {
  const TimelineDetailExtra({
    required this.model,
    this.categoryName,
  });

  final Model model;
  final String? categoryName;
}
