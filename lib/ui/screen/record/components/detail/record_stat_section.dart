import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// 記録タブ：数値＋ラベルのセクション
class RecordStatSection extends StatelessWidget {
  const RecordStatSection({
    required this.emoji,
    required this.value,
    required this.label,
    required this.valueColor,
    super.key,
  });

  final String emoji;
  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161616) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const Gap(4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
