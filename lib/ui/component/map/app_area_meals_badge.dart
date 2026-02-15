import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/strings.g.dart';

class AppAreaMealsBadge extends StatelessWidget {
  const AppAreaMealsBadge({
    required this.count,
    super.key,
  });

  final int? count;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final displayText = count == null
        ? t.map.visibleAreaLoading
        : t.map.visibleAreaMeals.replaceAll('{count}', count.toString());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
