import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/text_form_borders.dart';

/// アプリのライト・ダークテーマ定義
class AppTheme {
  AppTheme._();

  /// アプリのブランドオレンジ（primary）
  static const Color primaryOrange = Color(0xFFE88932);

  /// 成功・情報系 SnackBar の背景色（ブランドオレンジ）
  static const SnackBarThemeData snackBarTheme = SnackBarThemeData(
    backgroundColor: primaryOrange,
    contentTextStyle: TextStyle(color: Colors.white),
    actionTextColor: Colors.white,
  );

  /// 地図上FABの枠線。ダーク=白、ライト=グレーで背景に依存せず視認性を確保する。
  static Color fabBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.grey.shade300;
  }

  static ThemeData get light {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primaryOrange,
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: baseScheme.copyWith(
        primary: primaryOrange,
        onPrimary: Colors.white,
      ),
      snackBarTheme: snackBarTheme,
      scaffoldBackgroundColor: Colors.white,
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
      surface: const Color(0xFF1E1E1E),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: baseScheme.copyWith(
        primary: primaryOrange,
        onPrimary: Colors.white,
      ),
      snackBarTheme: snackBarTheme,
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: baseScheme.primaryContainer,
          foregroundColor: baseScheme.onPrimaryContainer,
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
