import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';

/// 記録タブ：冒頭のサマリーカード
class RecordSummarySection extends StatelessWidget {
  const RecordSummarySection({
    required this.activityDays,
    required this.cardColor,
    required this.mutedColor,
    super.key,
  });

  final int activityDays;
  final Color cardColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.mapStats.recordSummary
                    .replaceAll('{days}', activityDays.toString()),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
              const Gap(6),
              Text(
                t.myMapRecord.subtitle,
                style: TextStyle(
                  color: mutedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Transform.translate(
            offset: const Offset(8, 0),
            child: Assets.image.record.image(
              width: 100,
              height: 100,
            ),
          ),
        ],
      ),
    );
  }
}
