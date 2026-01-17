import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';

class AppAreaMealsBadge extends StatelessWidget {
  const AppAreaMealsBadge({
    required this.count,
    super.key,
  });

  final int? count;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final displayText = count == null
        ? l10n.mapVisibleAreaLoading
        : l10n.mapVisibleAreaMeals(count!);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
