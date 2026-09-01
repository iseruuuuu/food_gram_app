import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/screen/record/components/world/record_world_fill_map.dart';
import 'package:gap/gap.dart';

/// 記録タブ：食の旅マップ（訪れた国を塗りつぶした世界地図）
class RecordJourneyMapSection extends StatelessWidget {
  const RecordJourneyMapSection({
    required this.posts,
    required this.cardColor,
    required this.onSeeMore,
    super.key,
  });

  final List<Posts> posts;
  final Color cardColor;
  final VoidCallback onSeeMore;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.myMapRecord.journeyMapTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onSeeMore,
                child: Row(
                  children: [
                    Text(
                      t.seeMore,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white60 : Colors.black45,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 210,
              width: double.infinity,
              child: Stack(
                children: [
                  RecordWorldFillMap(posts: posts),
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onSeeMore,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
