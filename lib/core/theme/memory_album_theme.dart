import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';

/// 食の思い出アルバム画面用の色・装飾
class MemoryAlbumTheme {
  MemoryAlbumTheme._();

  static const creamBackground = AppTheme.backgroundLight;
  static const cardBackground = AppTheme.cardLight;
  static const chipBackground = AppTheme.orangeLight;
  static const chipBorder = AppTheme.primaryOrange;
  static const accentYellow = AppTheme.primaryOrange;
  static const heroGradientStart = AppTheme.orangeLight;
  static const heroGradientEnd = AppTheme.backgroundLight;

  static BoxDecoration cardDecoration({required bool isDark}) {
    if (isDark) {
      return BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerDark),
      );
    }
    return BoxDecoration(
      color: AppTheme.cardLight,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.dividerLight),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
