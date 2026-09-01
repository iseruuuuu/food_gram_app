import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/strings.g.dart';

enum TimelineFeedMode { all, friends }

/// Timeline 上部の [全体] [フレンド] 切り替え
class TimelineFeedModeTabBar extends StatelessWidget {
  const TimelineFeedModeTabBar({
    required this.currentMode,
    required this.onModeChanged,
    super.key,
  });

  final TimelineFeedMode currentMode;
  final ValueChanged<TimelineFeedMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final unselectedTextColor = isDark ? Colors.white : Colors.black87;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 8, 0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _TabItem(
            label: t.timeline.feedAll,
            isSelected: currentMode == TimelineFeedMode.all,
            isFirst: true,
            isLast: false,
            unselectedTextColor: unselectedTextColor,
            onTap: () => onModeChanged(TimelineFeedMode.all),
          ),
          _TabItem(
            label: t.timeline.feedFriends,
            isSelected: currentMode == TimelineFeedMode.friends,
            isFirst: false,
            isLast: true,
            unselectedTextColor: unselectedTextColor,
            onTap: () => onModeChanged(TimelineFeedMode.friends),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    required this.unselectedTextColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final Color unselectedTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? const Radius.circular(12) : Radius.zero,
              right: isLast ? const Radius.circular(12) : Radius.zero,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : unselectedTextColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
