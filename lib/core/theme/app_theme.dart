import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/text_form_borders.dart';

/// アプリのライト・ダークテーマ定義
class AppTheme {
  AppTheme._();

  /// アプリの青系（primary）に使う色
  static const Color primaryBlue = Color(0xFF0168B7);

  static ThemeData get light {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: baseScheme.copyWith(
        primary: primaryBlue,
        onPrimary: Colors.white,
      ),
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
      seedColor: primaryBlue,
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1E1E),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: baseScheme.copyWith(
        primary: primaryBlue,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
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
