import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';

class ProfileStyle {
  ProfileStyle._();

  /// ユーザー名（最も目立たせる）
  static TextStyle displayName(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 17,
      color: AppTheme.textPrimaryOf(context),
    );
  }

  static TextStyle name() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: AppTheme.textPrimaryLight,
    );
  }

  static TextStyle userName() {
    return const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: AppTheme.textSecondaryLight,
    );
  }

  /// FoodGramメンバー番号
  static TextStyle memberNumber(BuildContext context) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppTheme.textSecondaryOf(context),
      letterSpacing: 0.2,
    );
  }

  static TextStyle bio(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      color: AppTheme.textPrimaryOf(context),
      height: 1.4,
    );
  }

  static TextStyle nextLevel(BuildContext context) {
    return TextStyle(
      fontSize: 13,
      color: AppTheme.textSecondaryOf(context),
    );
  }

  static TextStyle nextLevelCount(BuildContext context) {
    return const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: AppTheme.primaryOrange,
    );
  }

  static TextStyle statValue(BuildContext context) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppTheme.textPrimaryOf(context),
    );
  }

  static TextStyle statLabel(BuildContext context) {
    return TextStyle(
      fontSize: 13,
      color: AppTheme.textSecondaryOf(context),
    );
  }

  static TextStyle rankBadge(BuildContext context) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: AppTheme.isDarkOf(context)
          ? AppTheme.primaryOrange
          : AppTheme.orangeDark,
    );
  }

  static Color rankBadgeBackground(BuildContext context) {
    return AppTheme.orangeBackgroundOf(context);
  }

  static Color rankBadgeBorder(BuildContext context) {
    return AppTheme.primaryOrange;
  }

  static TextStyle screenTitle(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: AppTheme.textPrimaryOf(context),
    );
  }

  static TextStyle editButton(BuildContext context) {
    return TextStyle(
      color: AppTheme.textSecondaryOf(context),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
  }
}
