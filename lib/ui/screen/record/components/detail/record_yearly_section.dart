import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/screen/record/components/record_post_image.dart';
import 'package:gap/gap.dart';

/// 年間の記録セクション
class RecordYearlySection extends StatelessWidget {
  const RecordYearlySection({
    required this.cardColor,
    required this.mutedColor,
    required this.sortedYears,
    required this.yearlyCounts,
    required this.recentPosts,
    required this.onYearSelected,
    this.selectedYear,
    super.key,
  });

  final Color cardColor;
  final Color mutedColor;
  final List<int> sortedYears;
  final Map<int, int> yearlyCounts;
  final List<Posts> recentPosts;
  final int? selectedYear;
  final ValueChanged<int> onYearSelected;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Text(
            t.myMapRecord.yearlyTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(12),
          if (sortedYears.isEmpty)
            Text(
              t.myMapRecord.noPostsYet,
              style: TextStyle(color: mutedColor),
            )
          else
            SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: sortedYears.length,
                separatorBuilder: (_, __) => const Gap(10),
                itemBuilder: (context, index) {
                  final year = sortedYears[index];
                  final postCount = yearlyCounts[year] ?? 0;
                  final yearPosts = recentPosts
                      .where((post) => post.createdAt.year == year)
                      .take(3)
                      .toList();
                  return RecordYearCard(
                    year: year,
                    count: postCount,
                    posts: yearPosts,
                    isSelected: selectedYear == year,
                    onTap: () => onYearSelected(year),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// 年間の記録1年分（年・件数・代表画像）
class RecordYearCard extends StatelessWidget {
  const RecordYearCard({
    required this.year,
    required this.count,
    required this.posts,
    required this.onTap,
    this.isSelected = false,
    super.key,
  });

  final int year;
  final int count;
  final List<Posts> posts;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 156,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1D1D1D) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryBlue
                  : (isDark ? Colors.white10 : const Color(0xFFECECEC)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  t.myMapRecord.yearLabel.replaceAll('{year}', '$year'),
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ),
              const Gap(2),
              Text(
                ' $count ${t.myMapRecord.countUnit}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  for (var i = 0; i < 2; i++) ...[
                    if (i > 0) const Gap(6),
                    if (i < posts.length)
                      RecordPostImage(
                        post: posts[i],
                        size: 60,
                        borderRadius: 8,
                      )
                    else
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:
                              isDark ? Colors.white10 : const Color(0xFFE8EEF4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
