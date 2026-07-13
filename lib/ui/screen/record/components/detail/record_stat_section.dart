import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// 記録タブ：数値＋ラベルのセクション
class RecordStatSection extends StatelessWidget {
  const RecordStatSection({
    required this.emoji,
    required this.value,
    required this.label,
    required this.valueColor,
    this.valueFontSize = 15,
    this.compact = false,
    super.key,
  });

  final String emoji;
  final String value;
  final String label;
  final Color valueColor;
  final double valueFontSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 10,
          vertical: compact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161616) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: compact ? 16 : 18),
            ),
            const Gap(4),
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w800,
                fontSize: valueFontSize,
                height: 1.2,
              ),
            ),
            const Gap(4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: compact ? 9 : 10,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
