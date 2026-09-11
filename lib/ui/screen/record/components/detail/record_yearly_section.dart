import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/post/analyzer/record_insight_analyzer.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_premium_lock.dart';
import 'package:food_gram_app/ui/screen/record/components/record_post_image.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

/// 年間の記録。その年の食体験として見られるPremiumコンテンツ。
class RecordYearlySection extends StatelessWidget {
  const RecordYearlySection({
    required this.posts,
    required this.selectedYear,
    required this.onYearSelected,
    required this.isSubscribed,
    required this.onTapPremiumCta,
    super.key,
  });

  final List<Posts> posts;
  final int selectedYear;
  final ValueChanged<int> onYearSelected;
  final bool isSubscribed;
  final VoidCallback onTapPremiumCta;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final years = recordSortedYears(posts);
    if (years.isEmpty) {
      return const SizedBox.shrink();
    }
    final recap = analyzeYearRecap(posts, selectedYear);
    final yearlyCounts = <int, int>{};
    for (final post in posts) {
      final year = post.createdAt.toLocal().year;
      yearlyCounts[year] = (yearlyCounts[year] ?? 0) + 1;
    }
    final recentPosts = [...posts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: recordSectionCardDecoration(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.myMapRecord.insight.yearStoryTitle.replaceAll(
              '{year}',
              '$selectedYear',
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(4),
          Text(
            t.myMapRecord.insight.yearStorySubtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white60 : Colors.black45,
            ),
          ),
          const Gap(12),
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: years.length,
              separatorBuilder: (_, __) => const Gap(10),
              itemBuilder: (context, index) {
                final year = years[index];
                final yearPosts = recentPosts
                    .where((post) => post.createdAt.toLocal().year == year)
                    .take(3)
                    .toList();
                return RecordYearCard(
                  year: year,
                  count: yearlyCounts[year] ?? 0,
                  posts: yearPosts,
                  isSelected: selectedYear == year,
                  onTap: () => onYearSelected(year),
                );
              },
            ),
          ),
          const Gap(12),
          if (!isSubscribed)
            RecordPremiumLockBanner(
              message: t.myMapRecord.insight.yearStorySubtitle,
              ctaLabel: t.myMapRecord.insight.lockedDiscoveriesCta,
              onTap: onTapPremiumCta,
            )
          else if (recap != null)
            _YearRecapBody(recap: recap),
        ],
      ),
    );
  }
}

class _YearRecapBody extends StatelessWidget {
  const _YearRecapBody({required this.recap});

  final RecordYearRecap recap;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeFormat = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final compareText = _compareText(t);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _YearStat(
              value: localeFormat.format(recap.mealsCount),
              label: t.myMapRecord.recordedMealsLabel,
            ),
            _YearStat(
              value: localeFormat.format(recap.shopsCount),
              label: t.myMapRecord.visitedShopsLabel,
            ),
            _YearStat(
              value: '${recap.prefecturesCount}',
              label: t.myMapRecord.prefecturesUnit,
            ),
            _YearStat(
              value: '${recap.countriesCount}',
              label: t.myMapRecord.countriesUnit,
            ),
          ],
        ),
        if (compareText != null) ...[
          const Gap(8),
          Text(
            compareText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
        if (recap.topGenre != null) ...[
          const Gap(10),
          _FactLine(
            title: t.myMapRecord.insight.topGenreTitle,
            value: '${getLocalizedFoodName(recap.topGenre!, context)} / '
                '${t.myMapRecord.insight.mealCountUnit.replaceAll(
              '{count}',
              '${recap.topGenreCount}',
            )}',
          ),
        ],
        if (recap.topArea != null) ...[
          const Gap(6),
          _FactLine(
            title: t.myMapRecord.insight.topAreaTitle,
            value: '${recap.topArea} / '
                '${t.myMapRecord.insight.mealCountUnit.replaceAll(
              '{count}',
              '${recap.topAreaCount}',
            )}',
          ),
        ],
        if (recap.favoritePost != null) ...[
          const Gap(10),
          _FavoriteRow(post: recap.favoritePost!),
        ],
        if (recap.newPrefectures.isNotEmpty ||
            recap.newCountries.isNotEmpty) ...[
          const Gap(10),
          Text(
            t.myMapRecord.insight.yearNewPlacesTitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white60 : Colors.black45,
            ),
          ),
          const Gap(6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final name in recap.newPrefectures.take(6))
                _MiniChip(label: name),
              for (final name in recap.newCountries.take(4))
                _MiniChip(label: name),
            ],
          ),
        ],
        const Gap(12),
        Text(
          t.myMapRecord.insight.monthlyRecordsTitle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white60 : Colors.black45,
          ),
        ),
        const Gap(8),
        _MonthlyBars(counts: recap.monthlyCounts),
      ],
    );
  }

  String? _compareText(Translations t) {
    final previous = recap.previousYearMeals;
    if (previous == null) {
      return t.myMapRecord.insight.yearCompareNew;
    }
    final delta = recap.mealsCount - previous;
    if (delta > 0) {
      return t.myMapRecord.insight.yearCompareUp.replaceAll(
        '{count}',
        '$delta',
      );
    }
    if (delta < 0) {
      return t.myMapRecord.insight.yearCompareDown.replaceAll(
        '{count}',
        '${delta.abs()}',
      );
    }
    return null;
  }
}

class _YearStat extends StatelessWidget {
  const _YearStat({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryBlue,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _FactLine extends StatelessWidget {
  const _FactLine({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$title  ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteRow extends StatelessWidget {
  const _FavoriteRow({required this.post});

  final Posts post;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        RecordPostImage(post: post, size: 44, borderRadius: 10),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.myMapRecord.insight.favoriteDishTitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              Text(
                post.displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1D1D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
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
                        width: 60,
                        height: 60,
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

class _MonthlyBars extends StatelessWidget {
  const _MonthlyBars({required this.counts});

  final List<int> counts;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxCount = counts.fold<int>(
      0,
      (prev, value) => value > prev ? value : prev,
    );
    return SizedBox(
      height: 132,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < counts.length && i < 12; i++) ...[
            if (i > 0) const Gap(3),
            Expanded(
              child: _MonthBar(
                month: i + 1,
                count: counts[i],
                maxCount: maxCount,
                isDark: isDark,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  const _MonthBar({
    required this.month,
    required this.count,
    required this.maxCount,
    required this.isDark,
  });

  final int month;
  final int count;
  final int maxCount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final emptyColor = isDark ? Colors.white12 : const Color(0xFFE5E7EB);
    return Column(
      children: [
        SizedBox(
          height: 16,
          child: count > 0
              ? FittedBox(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                )
              : null,
        ),
        const Gap(4),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final ratio = maxCount == 0 ? 0.0 : count / maxCount;
              final height = count == 0
                  ? 4.0
                  : (constraints.maxHeight * ratio).clamp(
                      8.0,
                      constraints.maxHeight,
                    );
              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: height,
                  decoration: BoxDecoration(
                    color: count == 0 ? emptyColor : AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ),
        const Gap(4),
        Text(
          '$month',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
      ],
    );
  }
}
