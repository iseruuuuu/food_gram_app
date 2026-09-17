import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';

class TabStyle {
  TabStyle._();

  /// タブ（アイコン・文言）の色。
  /// 選択時はブランドオレンジ / 未選択はグレー。
  static Color tabColor(BuildContext context, {required bool selected}) {
    if (!selected) {
      return AppTheme.textSecondaryOf(context);
    }
    return AppTheme.primaryOrange;
  }

  static TextStyle tab(BuildContext context, {required bool value}) {
    return TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: tabColor(context, selected: value),
    );
  }
}
