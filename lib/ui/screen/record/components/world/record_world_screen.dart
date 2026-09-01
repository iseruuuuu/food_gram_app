import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/utils/location/country_display.dart';
import 'package:food_gram_app/core/utils/map_stats_presentation.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_detail_screen.dart';
import 'package:food_gram_app/ui/screen/record/components/record_tab.dart';
import 'package:food_gram_app/ui/screen/record/components/world/record_world_fill_map.dart';
import 'package:food_gram_app/ui/screen/record/record_view_model.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

/// 記録タブ：世界ビュー（上の情報・地図・下の国リスト）
class RecordWorldScreen extends ConsumerWidget {
  const RecordWorldScreen({
    required this.posts,
    super.key,
  });

  final List<Posts> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF161616) : Colors.white;
    final countries = recordVisitedCountryStats(posts);
    final selectorTop = recordMapOverlayTopForContext(context);
    const bottomPadding = 120.0;
    return Padding(
      padding: EdgeInsets.only(top: selectorTop),
      child: Column(
        children: [
          RecordTab(
            currentViewType: MapViewType.world,
            onViewTypeChanged:
                ref.read(recordViewModelProvider.notifier).changeViewType,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _WorldProgressCard(
              cardColor: cardColor,
              visitedCount: countries.length,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: RecordWorldFillMap(
                  posts: posts,
                  interactive: true,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
            child: _VisitedCountriesCard(
              cardColor: cardColor,
              countries: countries,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldProgressCard extends StatelessWidget {
  const _WorldProgressCard({
    required this.cardColor,
    required this.visitedCount,
  });

  final Color cardColor;
  final int visitedCount;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ratio = (visitedCount / worldCountryCap).clamp(0.0, 1.0);
    final percentText = (ratio * 100).toStringAsFixed(1);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
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
                  t.myMapRecord.worldEatingTitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$visitedCount',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1, left: 4),
                    child: Text(
                      '/ $worldCountryCap',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Gap(8),
          Row(
            children: [
              Text(
                t.mapStats.achievementRate,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const Gap(6),
              Text(
                '$percentText%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF22C55E),
                ),
              ),
              const Gap(8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 7,
                    backgroundColor:
                        isDark ? Colors.white12 : const Color(0xFFE5E7EB),
                    color: const Color(0xFF22C55E),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisitedCountriesCard extends HookWidget {
  const _VisitedCountriesCard({
    required this.cardColor,
    required this.countries,
  });

  final Color cardColor;
  final List<RecordCountryVisit> countries;

  static const _itemHeight = 36.0;
  static const _visibleCount = 4;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final listController = useScrollController();
    final maxPostCount = countries.fold<int>(
      0,
      (current, visit) => math.max(current, visit.postCount),
    );
    final visibleCount = math.min(countries.length, _visibleCount);
    final scrollable = countries.length > _visibleCount;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.myMapRecord.recentVisitedCountries,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          if (countries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  t.myMapRecord.noVisitedCountries,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.black45,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: _itemHeight * visibleCount,
              child: Scrollbar(
                controller: listController,
                thumbVisibility: scrollable,
                child: ListView.builder(
                  controller: listController,
                  primary: false,
                  padding: EdgeInsets.zero,
                  physics: scrollable
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  itemCount: countries.length,
                  itemExtent: _itemHeight,
                  itemBuilder: (context, index) {
                    return _CountryVisitRow(
                      visit: countries[index],
                      maxPostCount: maxPostCount,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CountryVisitRow extends StatelessWidget {
  const _CountryVisitRow({
    required this.visit,
    required this.maxPostCount,
  });

  final RecordCountryVisit visit;
  final int maxPostCount;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final languageCode = Localizations.localeOf(context).languageCode;
    final localeFormat = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final name = localizedCountryName(
      code: visit.code,
      japaneseName: visit.name,
      languageCode: languageCode,
    );
    final ratio = maxPostCount == 0 ? 0.0 : visit.postCount / maxPostCount;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              countryFlagEmoji(visit.code),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1),
            ),
          ),
          const Gap(6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const Gap(3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.08, 1),
                    minHeight: 3,
                    backgroundColor:
                        isDark ? Colors.white12 : const Color(0xFFE5E7EB),
                    color: const Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localeFormat.format(visit.postCount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  color: Color(0xFF22C55E),
                ),
              ),
              Text(
                t.myMapRecord.countryPostUnit,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
