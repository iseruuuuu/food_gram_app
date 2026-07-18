import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/summary/monthly/monthly_summary.dart';
import 'package:food_gram_app/core/summary/weekly/weekly_summary.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/food_tag_icon.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class MonthlySummaryContent extends StatelessWidget {
  const MonthlySummaryContent({
    required this.summary,
    super.key,
  });

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    final strings = _MonthlyStrings.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(summary: summary, strings: strings),
        const Gap(4),
        _Greeting(summary: summary, strings: strings),
        const Gap(4),
        _Records(summary: summary, strings: strings),
        if (summary.topGenres.isNotEmpty && summary.hasVisitFootprint) ...[
          const Gap(14),
          _CompactDetails(summary: summary, strings: strings),
        ] else if (summary.topGenres.isNotEmpty) ...[
          const Gap(14),
          _GenreTop3(summary: summary, strings: strings),
        ] else if (summary.hasVisitFootprint) ...[
          const Gap(14),
          _VisitFootprint(summary: summary, strings: strings),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.summary, required this.strings});

  final MonthlySummary summary;
  final _MonthlyStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = _Colors.of(context);
    final period = summary.period;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'MONTHLY RECAP',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF2F8A4B),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        const Gap(4),
        Text(
          strings.monthTitle(period.monthStart.month),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.text,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Gap(5),
        Text(
          strings.dateRange(
            period.monthStart,
            period.monthEndInclusive,
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.subtext,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.summary, required this.strings});

  final MonthlySummary summary;
  final _MonthlyStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = _Colors.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 4, 8, 0),
      decoration: BoxDecoration(
        color: colors.hero,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.greeting(summary.period.monthStart.month),
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: colors.subtext,
                      fontSize: 13,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: '${summary.postCount}',
                        style: const TextStyle(
                          color: Color(0xFFF08A24),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(text: strings.greetingPostsSuffix),
                      TextSpan(
                        text: '${summary.newRestaurantCount}',
                        style: const TextStyle(
                          color: Color(0xFFF08A24),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(text: strings.greetingPlacesSuffix),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Assets.gif.sammaryDog.image(
            width: 104,
            height: 104,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _Records extends StatelessWidget {
  const _Records({required this.summary, required this.strings});

  final MonthlySummary summary;
  final _MonthlyStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = _Colors.of(context);
    return _Section(
      title: strings.recordsTitle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Metric(
            icon: Icons.restaurant,
            iconColor: const Color(0xFF248D4B),
            label: strings.posts,
            value: strings.count(summary.postCount),
            comparison: strings.comparison(
              summary.postCountDifference,
              strings.countUnit,
            ),
          ),
          _Divider(color: colors.border),
          _Metric(
            icon: Icons.location_on,
            iconColor: const Color(0xFFF08A24),
            label: strings.newPlaces,
            value: strings.places(summary.newRestaurantCount),
            comparison: strings.comparison(
              summary.newRestaurantDifference,
              strings.placeUnit,
            ),
          ),
          _Divider(color: colors.border),
          _Metric(
            icon: Icons.star,
            iconColor: const Color(0xFF287CCB),
            label: strings.average,
            value: summary.averageStar.toStringAsFixed(1),
            comparison: strings.ratingComparison(
              summary.averageStarDifference,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.comparison,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? comparison;

  @override
  Widget build(BuildContext context) {
    final colors = _Colors.of(context);
    final difference = comparison;
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.subtext, fontSize: 10),
          ),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: Colors.white),
              ),
              const Gap(4),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const Gap(7),
          Text(
            difference ?? ' ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: (difference?.startsWith('-') ?? false)
                  ? Colors.red.shade500
                  : const Color(0xFF2F8A4B),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 72, color: color);
}

class _GenreTop3 extends StatelessWidget {
  const _GenreTop3({
    required this.summary,
    required this.strings,
    this.embedded = false,
  });

  final MonthlySummary summary;
  final _MonthlyStrings strings;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final colors = _Colors.of(context);
    final child = embedded
        ? Column(
            children: [
              for (var index = 0;
                  index < summary.topGenres.length;
                  index++) ...[
                _CompactGenre(
                  rank: index + 1,
                  genre: summary.topGenres[index],
                  totalPosts: summary.postCount,
                  strings: strings,
                ),
                if (index < summary.topGenres.length - 1) ...[
                  const Gap(10),
                  Divider(height: 1, color: colors.border),
                  const Gap(10),
                ],
              ],
            ],
          )
        : Row(
            children: [
              for (var index = 0; index < summary.topGenres.length; index++)
                Expanded(
                  child: _Genre(
                    rank: index + 1,
                    genre: summary.topGenres[index],
                    totalPosts: summary.postCount,
                    strings: strings,
                  ),
                ),
            ],
          );

    if (embedded) {
      return _EmbeddedSection(
        title: strings.genreTitle,
        child: child,
      );
    }
    return _Section(
      title: strings.genreTitle,
      child: child,
    );
  }
}

class _CompactDetails extends StatelessWidget {
  const _CompactDetails({required this.summary, required this.strings});

  final MonthlySummary summary;
  final _MonthlyStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = _Colors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 330) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GenreTop3(summary: summary, strings: strings),
              const Gap(14),
              _VisitFootprint(summary: summary, strings: strings),
            ],
          );
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 8,
                  child: _GenreTop3(
                    summary: summary,
                    strings: strings,
                    embedded: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: VerticalDivider(width: 1, color: colors.border),
                ),
                Expanded(
                  flex: 12,
                  child: _VisitFootprint(
                    summary: summary,
                    strings: strings,
                    embedded: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmbeddedSection extends StatelessWidget {
  const _EmbeddedSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = _Colors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colors.text,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Gap(14),
        child,
      ],
    );
  }
}

class _CompactGenre extends StatelessWidget {
  const _CompactGenre({
    required this.rank,
    required this.genre,
    required this.totalPosts,
    required this.strings,
  });

  final int rank;
  final WeeklySummaryGenreRank genre;
  final int totalPosts;
  final _MonthlyStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = _Colors.of(context);
    final percent =
        totalPosts == 0 ? 0 : (genre.count * 100 / totalPosts).round();
    final accent = _Genre.badgeColors[rank - 1];
    return Row(
      children: [
        SizedBox(
          width: 58,
          height: 58,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: FoodTagIcon(
                    tagId: genre.tagId,
                    size: 36,
                    expandToFill: true,
                    centerText: true,
                    textStyle: const TextStyle(fontSize: 28, height: 1),
                  ),
                ),
              ),
              Positioned(
                top: -2,
                left: -2,
                child: Container(
                  width: 23,
                  height: 23,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getLocalizedFoodName(genre.tagId, context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Gap(3),
              Text(
                '${strings.count(genre.count)} ($percent%)',
                style: TextStyle(color: colors.subtext, fontSize: 10),
              ),
              const Gap(7),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: percent / 100,
                  minHeight: 4,
                  color: accent,
                  backgroundColor: colors.border,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Genre extends StatelessWidget {
  const _Genre({
    required this.rank,
    required this.genre,
    required this.totalPosts,
    required this.strings,
  });

  final int rank;
  final WeeklySummaryGenreRank genre;
  final int totalPosts;
  final _MonthlyStrings strings;

  static const badgeColors = [
    Color(0xFFFFB900),
    Color(0xFF9DAAB0),
    Color(0xFFC98A55),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _Colors.of(context);
    final percent =
        totalPosts == 0 ? 0 : (genre.count * 100 / totalPosts).round();
    return Column(
      children: [
        SizedBox(
          width: 76,
          height: 76,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: colors.iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: FoodTagIcon(
                    tagId: genre.tagId,
                    size: 44,
                    expandToFill: true,
                    centerText: true,
                    textStyle: const TextStyle(fontSize: 34, height: 1),
                  ),
                ),
              ),
              Container(
                width: 25,
                height: 25,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeColors[rank - 1],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        Text(
          getLocalizedFoodName(genre.tagId, context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.text,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(2),
        Text(
          '${strings.count(genre.count)} ($percent%)',
          style: TextStyle(color: colors.subtext, fontSize: 11),
        ),
      ],
    );
  }
}

class _VisitFootprint extends StatelessWidget {
  const _VisitFootprint({
    required this.summary,
    required this.strings,
    this.embedded = false,
  });

  final MonthlySummary summary;
  final _MonthlyStrings strings;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final colors = _Colors.of(context);
    final visited = summary.visitedPrefectures.toSet();
    final newly = summary.newPrefecturesThisMonth.toSet();

    final child = embedded
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _JapanFootprint(
                summary: summary,
                strings: strings,
                visited: visited,
                newly: newly,
              ),
              const Gap(12),
              Divider(height: 1, color: colors.border),
              const Gap(12),
              _OverseasFootprint(summary: summary, strings: strings),
            ],
          )
        : IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 11,
                  child: _JapanFootprint(
                    summary: summary,
                    strings: strings,
                    visited: visited,
                    newly: newly,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: VerticalDivider(width: 1, color: colors.border),
                ),
                Expanded(
                  flex: 8,
                  child: _OverseasFootprint(
                    summary: summary,
                    strings: strings,
                  ),
                ),
              ],
            ),
          );
    if (embedded) {
      return _EmbeddedSection(
        title: strings.footprintTitle,
        child: child,
      );
    }
    return _Section(title: strings.footprintTitle, child: child);
  }
}

class _JapanFootprint extends StatelessWidget {
  const _JapanFootprint({
    required this.summary,
    required this.strings,
    required this.visited,
    required this.newly,
  });

  final MonthlySummary summary;
  final _MonthlyStrings strings;
  final Set<String> visited;
  final Set<String> newly;

  static const _green = Color(0xFF2F8A4B);
  static const _newOrange = Color(0xFFF08A24);

  @override
  Widget build(BuildContext context) {
    final colors = _Colors.of(context);
    final previousCount = visited.length - newly.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, size: 14, color: _green),
            const Gap(4),
            Expanded(
              child: Text(
                strings.japanLabel,
                style: TextStyle(
                  color: colors.subtext,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const Gap(6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$previousCount → ',
              style: TextStyle(
                color: colors.text,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '${visited.length}',
              style: const TextStyle(
                color: _green,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              strings.prefectureUnit,
              style: const TextStyle(
                color: _green,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (newly.isNotEmpty) ...[
              const Gap(5),
              _DeltaBadge(label: '+${newly.length}', color: _green),
            ],
          ],
        ),
        const Gap(8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: SizedBox(
                height: 110,
                child: CustomPaint(
                  painter: _JapanDotMapPainter(
                    visited: visited,
                    newlyVisited: newly,
                    unvisitedColor: colors.border,
                  ),
                ),
              ),
            ),
            const Gap(8),
            SizedBox(
              width: 74,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MapLegend(
                    color: colors.border,
                    label: strings.unvisitedLegend,
                  ),
                  const Gap(5),
                  _MapLegend(
                    color: _JapanDotMapPainter.visitedColor,
                    label: strings.visitedLegend,
                  ),
                  const Gap(5),
                  _MapLegend(
                    color: _newOrange,
                    label: strings.newThisMonthLegend,
                  ),
                  if (summary.newPrefecturesThisMonth.isNotEmpty) ...[
                    const Gap(9),
                    for (final name in summary.newPrefecturesThisMonth.take(3))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          '● $name',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _newOrange,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OverseasFootprint extends StatelessWidget {
  const _OverseasFootprint({required this.summary, required this.strings});

  final MonthlySummary summary;
  final _MonthlyStrings strings;

  static const _purple = Color(0xFF7B5EA7);

  @override
  Widget build(BuildContext context) {
    final colors = _Colors.of(context);
    final newCount = summary.newCountriesThisMonth.length;
    final countries = newCount > 0
        ? summary.newCountriesThisMonth
        : summary.visitedCountries.take(2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.public, size: 14, color: _purple),
            const Gap(4),
            Text(
              strings.overseasLabel,
              style: TextStyle(
                color: colors.subtext,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Gap(7),
        Row(
          children: [
            Text(
              strings.countryProgress(summary.visitedCountries.length),
              style: const TextStyle(
                color: _purple,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (newCount > 0) ...[
              const Gap(5),
              _DeltaBadge(label: '+$newCount', color: _purple),
            ],
          ],
        ),
        const Gap(9),
        if (summary.visitedCountries.isEmpty)
          Text(
            strings.noOverseasYet,
            style: TextStyle(color: colors.subtext, fontSize: 11),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final country in countries)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: _purple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_countryFlag(country)),
                      const Gap(5),
                      Text(
                        country,
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (summary.newCountriesThisMonth.contains(country)) ...[
                        const Gap(5),
                        const _Chip(
                          label: 'NEW',
                          foreground: Colors.white,
                          background: _purple,
                          compact: true,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const Gap(4),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: _Colors.of(context).subtext,
              fontSize: 8,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _countryFlag(String country) {
  return switch (country) {
    '台湾' => '🇹🇼',
    '韓国' => '🇰🇷',
    '中国' => '🇨🇳',
    '香港' => '🇭🇰',
    'タイ' => '🇹🇭',
    'アメリカ' => '🇺🇸',
    'フランス' => '🇫🇷',
    'イタリア' => '🇮🇹',
    'イギリス' => '🇬🇧',
    _ => '🌏',
  };
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.foreground,
    this.background,
    this.compact = false,
  });

  final String label;
  final Color foreground;
  final Color? background;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: background ?? Colors.transparent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: compact ? 9 : 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// 47都道府県を均等なドットで並べたタイル型日本地図。
/// 累積訪問は緑、今月新規はオレンジ、未訪問はグレーで「埋め具合」が見える。
class _JapanDotMapPainter extends CustomPainter {
  _JapanDotMapPainter({
    required this.visited,
    required this.newlyVisited,
    required this.unvisitedColor,
  });

  final Set<String> visited;
  final Set<String> newlyVisited;
  final Color unvisitedColor;

  static const visitedColor = Color(0xFF66BB6A);
  static const newlyColor = Color(0xFFF08A24);

  /// 地理的な並びを保ちながら、日本列島のシルエットに見えるよう調整した配置。
  static const _tiles = <({String name, int column, int row})>[
    (name: '北海道', column: 13, row: 0),
    (name: '青森県', column: 12, row: 1),
    (name: '秋田県', column: 11, row: 2),
    (name: '岩手県', column: 12, row: 2),
    (name: '山形県', column: 11, row: 3),
    (name: '宮城県', column: 12, row: 3),
    (name: '福島県', column: 12, row: 4),
    (name: '新潟県', column: 10, row: 4),
    (name: '茨城県', column: 13, row: 5),
    (name: '栃木県', column: 12, row: 5),
    (name: '群馬県', column: 11, row: 5),
    (name: '埼玉県', column: 12, row: 6),
    (name: '千葉県', column: 14, row: 6),
    (name: '東京都', column: 13, row: 6),
    (name: '神奈川県', column: 13, row: 7),
    (name: '富山県', column: 9, row: 5),
    (name: '石川県', column: 8, row: 4),
    (name: '福井県', column: 8, row: 5),
    (name: '山梨県', column: 11, row: 6),
    (name: '長野県', column: 10, row: 5),
    (name: '岐阜県', column: 9, row: 6),
    (name: '静岡県', column: 11, row: 7),
    (name: '愛知県', column: 10, row: 7),
    (name: '三重県', column: 9, row: 7),
    (name: '滋賀県', column: 8, row: 6),
    (name: '京都府', column: 7, row: 6),
    (name: '大阪府', column: 7, row: 7),
    (name: '兵庫県', column: 6, row: 6),
    (name: '奈良県', column: 8, row: 7),
    (name: '和歌山県', column: 7, row: 8),
    (name: '鳥取県', column: 5, row: 6),
    (name: '島根県', column: 4, row: 6),
    (name: '岡山県', column: 5, row: 7),
    (name: '広島県', column: 4, row: 7),
    (name: '山口県', column: 3, row: 7),
    (name: '徳島県', column: 6, row: 9),
    (name: '香川県', column: 5, row: 9),
    (name: '愛媛県', column: 4, row: 9),
    (name: '高知県', column: 5, row: 10),
    (name: '福岡県', column: 2, row: 7),
    (name: '佐賀県', column: 1, row: 8),
    (name: '長崎県', column: 0, row: 8),
    (name: '熊本県', column: 2, row: 8),
    (name: '大分県', column: 3, row: 8),
    (name: '宮崎県', column: 3, row: 9),
    (name: '鹿児島県', column: 2, row: 9),
    (name: '沖縄県', column: 0, row: 10),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const columns = 15;
    const rows = 11;
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;
    final radius = (cellWidth < cellHeight ? cellWidth : cellHeight) * 0.37;

    for (final tile in _tiles) {
      final center = Offset(
        (tile.column + 0.5) * cellWidth,
        (tile.row + 0.5) * cellHeight,
      );
      final paint = Paint()
        ..color = newlyVisited.contains(tile.name)
            ? newlyColor
            : visited.contains(tile.name)
                ? visitedColor
                : unvisitedColor;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _JapanDotMapPainter oldDelegate) {
    return oldDelegate.visited != visited ||
        oldDelegate.newlyVisited != newlyVisited ||
        oldDelegate.unvisitedColor != unvisitedColor;
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = _Colors.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.text,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Gap(18),
          child,
        ],
      ),
    );
  }
}

class _Colors {
  const _Colors({
    required this.text,
    required this.subtext,
    required this.surface,
    required this.border,
    required this.hero,
    required this.iconBackground,
  });

  factory _Colors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _Colors(
      text: isDark ? Colors.white : const Color(0xFF211E1A),
      subtext: isDark ? Colors.white60 : const Color(0xFF625E58),
      surface: isDark ? const Color(0xFF292929) : Colors.white,
      border: isDark ? Colors.white12 : const Color(0xFFE9E5DE),
      hero: isDark ? const Color(0xFF352F22) : const Color(0xFFFFF7E5),
      iconBackground:
          isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF3F0EA),
    );
  }

  final Color text;
  final Color subtext;
  final Color surface;
  final Color border;
  final Color hero;
  final Color iconBackground;
}

/// 生成済みの i18n リソース（[Translations]）を薄くラップし、
/// 画面側の呼び出しをそのまま保ちながらロケール対応の文言・日付を返す。
class _MonthlyStrings {
  const _MonthlyStrings({
    required this.t,
    required this.localeTag,
    required this.languageCode,
  });

  factory _MonthlyStrings.of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return _MonthlyStrings(
      t: Translations.of(context),
      localeTag: locale.toLanguageTag(),
      languageCode: locale.languageCode,
    );
  }

  final Translations t;
  final String localeTag;
  final String languageCode;

  String monthTitle(int month) =>
      t.monthlySummary.monthTitle.replaceAll('{month}', '$month');
  String greeting(int month) =>
      t.monthlySummary.greeting.replaceAll('{month}', '$month');
  String get greetingPostsSuffix => t.monthlySummary.greetingPostsSuffix;
  String get greetingPlacesSuffix => t.monthlySummary.greetingPlacesSuffix;
  String get recordsTitle => t.monthlySummary.recordsTitle;
  String get posts => t.monthlySummary.posts;
  String get newPlaces => t.monthlySummary.newPlaces;
  String get average => t.monthlySummary.average;
  String get genreTitle => t.monthlySummary.genreTitle;
  String get footprintTitle => t.monthlySummary.footprintTitle;
  String get japanLabel => t.monthlySummary.japanLabel;
  String get overseasLabel => t.monthlySummary.overseasLabel;
  String get noOverseasYet => t.monthlySummary.noOverseasYet;
  String get prefectureUnit => t.monthlySummary.prefectureUnit;
  String get unvisitedLegend => t.monthlySummary.unvisitedLegend;
  String get visitedLegend => t.monthlySummary.visitedLegend;
  String get newThisMonthLegend => t.monthlySummary.newThisMonthLegend;
  String get footer => t.monthlySummary.footer;
  String get countUnit => t.monthlySummary.countUnit;
  String get placeUnit => t.monthlySummary.placeUnit;
  String count(int value) =>
      t.monthlySummary.countValue.replaceAll('{count}', '$value');
  String places(int value) =>
      t.monthlySummary.placeValue.replaceAll('{count}', '$value');
  String countryProgress(int current) =>
      t.monthlySummary.countryProgress.replaceAll('{count}', '$current');

  String comparison(int value, String unit) => _comparison(
        delta: '${value > 0 ? '+' : ''}$value',
        unit: unit,
        isUp: value >= 0,
      );

  String ratingComparison(double value) => _comparison(
        delta: '${value > 0 ? '+' : ''}${value.toStringAsFixed(1)}',
        unit: '',
        isUp: value >= 0,
      );

  String _comparison({
    required String delta,
    required String unit,
    required bool isUp,
  }) =>
      t.monthlySummary.comparison
          .replaceAll('{delta}', delta)
          .replaceAll('{unit}', unit)
          .replaceAll('{arrow}', isUp ? '↑' : '↓');

  String dateRange(DateTime start, DateTime end) => t.monthlySummary.dateRange
      .replaceAll('{start}', _formatDate(start))
      .replaceAll('{end}', _formatDate(end));

  /// アクティブロケールに合わせて日付を整形する。
  /// ロケールデータが未ロードでも落ちないよう段階的にフォールバックする。
  String _formatDate(DateTime date) {
    for (final candidate in <String>{localeTag, languageCode}) {
      try {
        return DateFormat.MMMd(candidate).format(date);
      } on Object {
        continue;
      }
    }
    return DateFormat.MMMd().format(date);
  }
}
