import 'package:flutter/material.dart';

/// 食の思い出アルバム画面用の色・装飾
class MemoryAlbumTheme {
  MemoryAlbumTheme._();

  static const creamBackground = Color(0xFFFFF9EE);
  static const cardBackground = Color(0xFFFFFBF3);
  static const chipBackground = Color(0xFFFFF3CD);
  static const chipBorder = Color(0xFFFFE082);
  static const accentYellow = Color(0xFFFFC107);
  static const heroGradientStart = Color(0xFFFFF8E1);
  static const heroGradientEnd = Color(0xFFFFFDE7);

  static BoxDecoration cardDecoration({required bool isDark}) {
    if (isDark) {
      return BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      );
    }
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFFFE082).withValues(alpha: 0.5)),
      boxShadow: [
        BoxShadow(
          color: Colors.amber.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
