import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/text_form_borders.dart';

/// アプリのライト・ダークテーマ定義
class AppTheme {
  AppTheme._();

  /// アプリのブランドオレンジ（primary / アクセント）
  static const Color primaryOrange = Color(0xFFE88932);
  static const Color orangeDark = Color(0xFFC96F24);
  static const Color orangeLight = Color(0xFFFFF0DE);
  static const Color darkOrangeBackground = Color(0xFF4A321F);

  static const Color backgroundLight = Color(0xFFFFFDF9);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF29231F);
  static const Color textSecondaryLight = Color(0xFF8B8178);
  static const Color dividerLight = Color(0xFFEEE7E0);

  static const Color backgroundDark = Color(0xFF1C1B1A);
  static const Color cardDark = Color(0xFF252321);
  static const Color textPrimaryDark = Color(0xFFFFF8F1);
  static const Color textSecondaryDark = Color(0xFFA9A19A);
  static const Color dividerDark = Color(0xFF3A3531);

  /// 特別な達成・称号でのみ使うゴールド
  static const Color achievementGold = Color(0xFFD6A441);

  /// 成功・情報系 SnackBar の背景色（ブランドオレンジ）
  static const SnackBarThemeData snackBarTheme = SnackBarThemeData(
    backgroundColor: primaryOrange,
    contentTextStyle: TextStyle(color: Colors.white),
    actionTextColor: Colors.white,
  );

  static bool isDarkOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color textPrimaryOf(BuildContext context) {
    return isDarkOf(context) ? textPrimaryDark : textPrimaryLight;
  }

  static Color textSecondaryOf(BuildContext context) {
    return isDarkOf(context) ? textSecondaryDark : textSecondaryLight;
  }

  static Color backgroundOf(BuildContext context) {
    return isDarkOf(context) ? backgroundDark : backgroundLight;
  }

  static Color cardOf(BuildContext context) {
    return isDarkOf(context) ? cardDark : cardLight;
  }

  static Color dividerOf(BuildContext context) {
    return isDarkOf(context) ? dividerDark : dividerLight;
  }

  /// 統計アイコンなどの薄いオレンジ背景
  static Color orangeBackgroundOf(BuildContext context) {
    return isDarkOf(context) ? darkOrangeBackground : orangeLight;
  }

  /// 地図上FABの枠線。ダーク=白、ライト=グレーで背景に依存せず視認性を確保する。
  static Color fabBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.grey.shade300;
  }

  static ThemeData get light {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primaryOrange,
      surface: cardLight,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: baseScheme.copyWith(
        primary: primaryOrange,
        onPrimary: Colors.white,
        primaryContainer: orangeLight,
        onPrimaryContainer: orangeDark,
        surface: cardLight,
        onSurface: textPrimaryLight,
        onSurfaceVariant: textSecondaryLight,
        outline: dividerLight,
        outlineVariant: dividerLight,
        secondary: primaryOrange,
        onSecondary: Colors.white,
      ),
      snackBarTheme: snackBarTheme,
      scaffoldBackgroundColor: backgroundLight,
      canvasColor: backgroundLight,
      dividerColor: dividerLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        foregroundColor: textPrimaryLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        contentPadding: EdgeInsets.all(15),
        focusedBorder: TextFormBorders.textFormFocusedBorder,
        enabledBorder: TextFormBorders.textFormEnabledBorder,
        focusedErrorBorder: TextFormBorders.textFormErrorBorder,
        errorBorder: TextFormBorders.textFormErrorBorder,
      ),
    );
  }

  static ThemeData get dark {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primaryOrange,
      brightness: Brightness.dark,
      surface: cardDark,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: baseScheme.copyWith(
        primary: primaryOrange,
        onPrimary: Colors.white,
        primaryContainer: darkOrangeBackground,
        onPrimaryContainer: orangeLight,
        surface: cardDark,
        onSurface: textPrimaryDark,
        onSurfaceVariant: textSecondaryDark,
        outline: dividerDark,
        outlineVariant: dividerDark,
        secondary: primaryOrange,
        onSecondary: Colors.white,
      ),
      snackBarTheme: snackBarTheme,
      scaffoldBackgroundColor: backgroundDark,
      canvasColor: backgroundDark,
      dividerColor: dividerDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: textPrimaryDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkOrangeBackground,
          foregroundColor: orangeLight,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        contentPadding: EdgeInsets.all(15),
        focusedBorder: TextFormBorders.textFormFocusedBorderDark,
        enabledBorder: TextFormBorders.textFormEnabledBorderDark,
        focusedErrorBorder: TextFormBorders.textFormErrorBorder,
        errorBorder: TextFormBorders.textFormErrorBorder,
      ),
    );
  }
}
