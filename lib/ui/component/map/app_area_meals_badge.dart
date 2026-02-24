import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/screen/map/map_state.dart';
import 'package:gap/gap.dart';

class AppAreaMealsBadge extends StatelessWidget {
  const AppAreaMealsBadge({
    required this.count,
    this.topTags = const [],
    super.key,
  });

  final int? count;
  final List<VisibleAreaTagCount> topTags;
  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final line1 = count == null
        ? t.map.visibleAreaLoading
        : t.map.visibleAreaMeals.replaceAll('{count}', count.toString());
    final textStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: textColor,
    );
    final tagStyle = TextStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w500,
      color: textColor,
    );
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(line1, style: textStyle),
          if (topTags.isNotEmpty) ...[
            const Gap(4),
            Text(
              '${t.map.areaPopularLabel}：'
              '${topTags.map((tag) => '${tag.emoji} ×${tag.count}').join('　')}',
              style: tagStyle,
            ),
          ],
        ],
      ),
    );
  }
}
