import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/gen/strings.g.dart';

class TimelineCategoryTabBar extends StatelessWidget {
  const TimelineCategoryTabBar({
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
    super.key,
  });

  final List<CategoryData> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  static const double _circleSize = 56;
  static const double _iconFontSize = 28;
  static const double _labelFontSize = 12;
  static const double _itemWidth = 68;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final circleColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);
    final selectedCircleColor =
        isDark ? const Color(0xFF3A3A3A) : const Color(0xFFEAEAEA);

    return SizedBox(
      height: _circleSize + 8 + _labelFontSize + 12,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = index == selectedIndex;
          final label = category.isAllCategory
              ? Translations.of(context).share.categoryAll
              : getLocalizedCategoryName(category.name, context);

          return GestureDetector(
            onTap: () => onCategorySelected(index),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: _itemWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: _circleSize,
                    height: _circleSize,
                    decoration: BoxDecoration(
                      color: isSelected ? selectedCircleColor : circleColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category.displayIcon,
                      style: const TextStyle(fontSize: _iconFontSize),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _labelFontSize,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
