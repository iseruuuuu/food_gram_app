import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';

/// 年間の記録セクション
class RecordYearlySection extends StatelessWidget {
  const RecordYearlySection({
    required this.cardColor,
    required this.mutedColor,
    required this.sortedYears,
    required this.yearlyCounts,
    required this.recentPosts,
    super.key,
  });

  final Color cardColor;
  final Color mutedColor;
  final List<int> sortedYears;
  final Map<int, int> yearlyCounts;
  final List<Posts> recentPosts;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 6),
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
              height: 105,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: sortedYears.length,
                separatorBuilder: (_, __) => const Gap(10),
                itemBuilder: (context, index) {
                  final year = sortedYears[index];
                  final postCount = yearlyCounts[year] ?? 0;
                  final firstPostOfYear = recentPosts.firstWhere(
                    (p) => p.createdAt.year == year,
                    orElse: () => recentPosts.first,
                  );
                  return RecordYearAvatarTile(
                    year: year,
                    count: postCount,
                    post: firstPostOfYear,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// 年間の記録1年分（年・代表画像・件数）
class RecordYearAvatarTile extends ConsumerWidget {
  const RecordYearAvatarTile({
    required this.year,
    required this.count,
    required this.post,
    super.key,
  });

  final int year;
  final int count;
  final Posts post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storageKey = post.firstFoodImage;
    final imageUrl = storageKey.isEmpty
        ? null
        : ref
            .read(supabaseProvider)
            .storage
            .from('food')
            .getPublicUrl(storageKey);
    return SizedBox(
      width: 84,
      child: Column(
        children: [
          Text(
            '$year',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(6),
          CircleAvatar(
            radius: 24,
            backgroundColor:
                isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            backgroundImage: imageUrl == null ? null : NetworkImage(imageUrl),
            child: imageUrl == null
                ? Icon(
                    Icons.restaurant,
                    size: 20,
                    color: isDark ? Colors.white54 : Colors.black45,
                  )
                : null,
          ),
          const Gap(6),
          Text(
            '$count ${t.myMapRecord.countUnit}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
