import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';

/// 食の思い出アルバム画面用の色・装飾
class MemoryAlbumTheme {
  MemoryAlbumTheme._();

  static const Color creamBackground = AppTheme.backgroundLight;
  static const Color cardBackground = AppTheme.cardLight;
  static const Color chipBackground = AppTheme.orangeLight;
  static const Color chipBorder = AppTheme.primaryOrange;
  static const Color accentYellow = AppTheme.primaryOrange;
  static const Color heroGradientStart = AppTheme.orangeLight;
  static const Color heroGradientEnd = AppTheme.backgroundLight;

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
