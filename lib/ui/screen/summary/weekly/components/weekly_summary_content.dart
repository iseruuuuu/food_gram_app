import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/summary/weekly/weekly_summary.dart';
import 'package:food_gram_app/core/summary/weekly/weekly_summary_period.dart';
import 'package:food_gram_app/core/utils/memory_album_utils.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/food_tag_icon.dart';
import 'package:food_gram_app/ui/screen/summary/weekly/weekly_summary_format.dart';
import 'package:gap/gap.dart';

/// 今週のまとめ本体（ヘッダー〜ジャンルTOP3）
class WeeklySummaryContent extends ConsumerWidget {
  const WeeklySummaryContent({
    required this.summary,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final WeeklySummary summary;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WeeklySummaryHeader(period: summary.period),
          const Gap(14),
          _StreakCard(
            streakWeeks: summary.streakWeeks,
            postedWeekdays: summary.postedWeekdays,
          ),
          if (summary.bestPost != null) ...[
            const Gap(12),
            _BestPhoto(post: summary.bestPost!),
          ],
          if (summary.topGenres.isNotEmpty) ...[
            const Gap(18),
            _GenreTop3(topGenres: summary.topGenres),
          ],
        ],
      ),
    );
  }
}

class _WeeklySummaryHeader extends StatelessWidget {
  const _WeeklySummaryHeader({required this.period});

  final WeeklySummaryPeriod period;

  static const _accentGreen = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF2C2418);
    final subColor = isDark ? Colors.white54 : Colors.black54;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Assets.icon.icon3.image(width: 28, height: 28),
                const Gap(6),
                Text(
                  t.app.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
              ],
            ),
            const Gap(10),
            Text(
              t.weeklySummary.weeklyRecapLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color:
                    isDark ? _accentGreen.withValues(alpha: 0.9) : _accentGreen,
              ),
            ),
            const Gap(4),
            Text(
              t.weeklySummary.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.15,
                color: titleColor,
              ),
            ),
            const Gap(6),
            Text(
              formatWeeklySummaryDateRange(period, t),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: subColor,
              ),
            ),
          ],
        ),
        Positioned(
          top: -4,
          right: -4,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 8,
                left: -10,
                child: Icon(
                  Icons.pets,
                  size: 18,
                  color: Colors.orange.shade300.withValues(alpha: 0.85),
                ),
              ),
              Positioned(
                bottom: 6,
                right: -6,
                child: Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: Colors.amber.shade400.withValues(alpha: 0.9),
                ),
              ),
              Assets.gif.sammaryDog.image(
                width: 88,
                height: 88,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.streakWeeks,
    required this.postedWeekdays,
  });

  final int streakWeeks;
  final List<bool> postedWeekdays;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE8E4DC);
    final labels = weeklySummaryWeekdayLabels(t);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.weeklySummary.streakLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const Gap(4),
                Row(
                  children: [
                    Text(
                      t.weeklySummary.streakWeeks
                          .replaceAll('{weeks}', '$streakWeeks'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Gap(4),
                    Icon(
                      Icons.local_fire_department,
                      size: 22,
                      color: Colors.orange.shade600,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(width: 1, height: 48, color: borderColor),
          const Gap(12),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final posted =
                    index < postedWeekdays.length && postedWeekdays[index];
                return Column(
                  children: [
                    Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    const Gap(6),
                    _DayCircle(posted: posted, isDark: isDark),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  const _DayCircle({
    required this.posted,
    required this.isDark,
  });

  final bool posted;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const size = 24.0;
    if (posted) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFF4CAF50),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 14, color: Colors.white),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Colors.white24 : const Color(0xFFD0D0D0),
          width: 1.5,
        ),
      ),
    );
  }
}

class _BestPhoto extends ConsumerWidget {
  const _BestPhoto({required this.post});

  final Posts post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageUrl = postImageUrl(ref, post);
    final restaurant =
        post.restaurant.trim().isEmpty ? post.foodName : post.restaurant;
    final category = parseFoodTagIds(post.foodTag)
        .map((tag) => getLocalizedFoodName(tag, context))
        .join('・');
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE8E4DC);
    const photoSize = 118.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: photoSize,
                  height: photoSize,
                  child: imageUrl == null
                      ? ColoredBox(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          child: Image.asset(
                            isDark
                                ? Assets.image.emptyDark.path
                                : Assets.image.empty.path,
                            fit: BoxFit.cover,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => ColoredBox(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                          ),
                          errorWidget: (_, __, ___) => Image.asset(
                            isDark
                                ? Assets.image.emptyDark.path
                                : Assets.image.empty.path,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              Positioned(
                top: -6,
                left: -6,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _SparkleLines(),
                    const Gap(6),
                    Flexible(
                      child: Text(
                        t.weeklySummary.bestPhotoTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                    const Gap(6),
                    const _SparkleLines(mirror: true),
                  ],
                ),
                const Gap(10),
                Text(
                  restaurant,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (category.isNotEmpty) ...[
                  const Gap(4),
                  Text(
                    category,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
                const Gap(10),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 20,
                      color: Colors.amber.shade600,
                    ),
                    const Gap(4),
                    Text(
                      post.star.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkleLines extends StatelessWidget {
  const _SparkleLines({this.mirror = false});

  final bool mirror;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white38 : Colors.black26;

    return SizedBox(
      width: 18,
      height: 16,
      child: CustomPaint(
        painter: _SparkleLinesPainter(color: color, mirror: mirror),
      ),
    );
  }
}

class _SparkleLinesPainter extends CustomPainter {
  _SparkleLinesPainter({required this.color, required this.mirror});

  final Color color;
  final bool mirror;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final lines = [
      (
        Offset(0, size.height * 0.7),
        Offset(size.width * 0.55, size.height * 0.1)
      ),
      (
        Offset(size.width * 0.15, size.height),
        Offset(size.width * 0.85, size.height * 0.35)
      ),
      (
        Offset(size.width * 0.35, size.height * 0.85),
        Offset(size.width, size.height * 0.55)
      ),
    ];

    for (final (start, end) in lines) {
      if (mirror) {
        canvas.drawLine(
          Offset(size.width - start.dx, start.dy),
          Offset(size.width - end.dx, end.dy),
          paint,
        );
      } else {
        canvas.drawLine(start, end, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparkleLinesPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.mirror != mirror;
  }
}

class _GenreTop3 extends StatelessWidget {
  const _GenreTop3({required this.topGenres});

  final List<WeeklySummaryGenreRank> topGenres;

  static const _badgeColors = [
    Color(0xFFFFC107),
    Color(0xFFB0BEC5),
    Color(0xFFD4A574),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.weeklySummary.genreTop3Title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const Gap(14),
        Row(
          children: [
            for (var i = 0; i < topGenres.length; i++) ...[
              if (i > 0) const Gap(8),
              Expanded(
                child: _GenreRankItem(
                  rank: i + 1,
                  badgeColor: _badgeColors[i.clamp(0, 2)],
                  genre: topGenres[i],
                  isDark: isDark,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _GenreRankItem extends StatelessWidget {
  const _GenreRankItem({
    required this.rank,
    required this.badgeColor,
    required this.genre,
    required this.isDark,
  });

  final int rank;
  final Color badgeColor;
  final WeeklySummaryGenreRank genre;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final name = getLocalizedFoodName(genre.tagId, context);
    final circleBg = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF0EEEA);

    return Column(
      children: [
        SizedBox(
          width: 88,
          height: 88,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: circleBg,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(14),
                  child: FoodTagIcon(
                    tagId: genre.tagId,
                    size: 48,
                    expandToFill: true,
                    centerText: true,
                    textStyle: const TextStyle(fontSize: 36, height: 1),
                  ),
                ),
              ),
              Positioned(
                top: -2,
                left: -2,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(10),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const Gap(2),
        Text(
          t.weeklySummary.postCountValue
              .replaceAll('{count}', '${genre.count}'),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
      ],
    );
  }
}
