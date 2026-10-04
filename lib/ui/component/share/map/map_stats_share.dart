import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/location/country_detector.dart';
import 'package:food_gram_app/core/utils/location/country_display.dart';
import 'package:food_gram_app/core/utils/location/prefecture_display.dart';
import 'package:food_gram_app/core/utils/map_share_journey.dart';
import 'package:food_gram_app/core/utils/map_stats_presentation.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/share/map/share_outline_map.dart';
import 'package:gap/gap.dart';

/// 自分の食の旅がどこまで広がって、次の白はどこかを見せるシェア画像。
///
/// 日本は横幅いっぱいの正方形地図。世界も同じ大きさの正方形に収める。
class MapStatsShare extends StatelessWidget {
  const MapStatsShare({
    required this.viewType,
    required this.visitedPrefecturesCount,
    required this.visitedCountriesCount,
    required this.posts,
    this.outlines,
    super.key,
  });

  final MapViewType viewType;
  final int visitedPrefecturesCount;
  final int visitedCountriesCount;
  final List<Posts> posts;
  final ShareOutlineSet? outlines;

  static const double compositionWidth = 360;

  static const double _sidePadding = 22;
  static const double _topPadding = 16;
  static const double _bottomPadding = 18;

  /// 左右の余白を除いた幅に [japanShareMapScale] を掛けた一辺。日本も世界も同じ。
  static const mapSide =
      (compositionWidth - _sidePadding * 2) * japanShareMapScale;

  /// 地図以外の高さ。上下の余白・見出し・数字・バー・ロゴを含む。
  static const _chromeHeight = 186.0;
  static const double compositionHeight = _chromeHeight + mapSide;
  static const Size size = Size(compositionWidth, compositionHeight);

  /// 国旗・地球儀と「JAPAN / WORLD FOOD MAP」。
  static const kickerIconSize = 26.0;
  static const kickerFontSize = 18.0;

  static Size sizeFor(MapViewType _) => size;

  static const _muted = Color(0xFF667386);
  static const _mapBg = AppTheme.orangeLight;

  bool get _isJapan => viewType == MapViewType.japan;

  int get _total => _isJapan ? japanPrefectureCap : worldCountryCap;

  MapShareJourney _journey() {
    if (_isJapan) {
      return buildJapanShareJourney([
        for (final visit in recordVisitedPrefectureStats(posts))
          MapSharePlace(
            id: visit.name,
            visitedAt: visit.lastVisitedAt,
          ),
      ]);
    }
    if (!CountryDetector.isLoaded) {
      return buildWorldShareJourney(const []);
    }
    return buildWorldShareJourney(
      [
        for (final visit in recordVisitedCountryStats(posts))
          MapSharePlace(
            id: visit.code,
            visitedAt: visit.lastVisitedAt,
            countryCode: visit.code,
          ),
      ],
      continentOf: (code) {
        final region = outlines?.worldById[code];
        if (region == null) {
          return null;
        }
        return continentKeyFromLatLng(
          region.centroidLat,
          region.centroidLng,
          countryCode: code,
        );
      },
    );
  }

  int _count(MapShareJourney journey) {
    final postsReady =
        posts.isNotEmpty && (_isJapan || CountryDetector.isLoaded);
    if (postsReady) {
      return journey.count;
    }
    final given = _isJapan ? visitedPrefecturesCount : visitedCountriesCount;
    if (given < 0) {
      return 0;
    }
    if (given > _total) {
      return _total;
    }
    return given;
  }

  String shareMessage(Translations t, {required String languageCode}) {
    final journey = _journey();
    final count = _count(journey);
    final story = _storyText(t, journey, count, languageCode);
    final current = t.myMapShare.currentProgress
        .replaceAll('{count}', '$count')
        .replaceAll('{total}', '$_total');
    return '$story\n'
        '$current\n\n'
        '${t.myMapShare.yourTurn}\n\n'
        '#FoodGram';
  }

  Translations _translations(BuildContext context) {
    final data = context.dependOnInheritedWidgetOfExactType<
        InheritedLocaleData<AppLocale, Translations>>();
    return data?.translations ?? LocaleSettings.instance.currentTranslations;
  }

  @override
  Widget build(BuildContext context) {
    final t = _translations(context);
    final journey = _journey();
    final count = _count(journey);
    final ratio = _total == 0 ? 0.0 : count / _total;
    final regions = _isJapan
        ? outlines?.japan ?? const <ShareOutlineRegion>[]
        : outlines?.world ?? const <ShareOutlineRegion>[];
    final visitedIds = _placesForMap();
    final map = _map(regions: regions, visitedIds: visitedIds);

    return SizedBox(
      width: compositionWidth,
      height: compositionHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              _sidePadding,
              _topPadding,
              _sidePadding,
              _bottomPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Kicker(
                  isJapan: _isJapan,
                  label: _isJapan
                      ? t.myMapShare.kickerJapan
                      : t.myMapShare.kickerWorld,
                ),
                const Gap(10),
                Align(
                  child: SizedBox(
                    width: mapSide,
                    height: mapSide,
                    child: map,
                  ),
                ),
                const Gap(12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$count',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryOrange,
                              height: 1,
                            ),
                          ),
                          TextSpan(
                            text: ' / $_total',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryOrange,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        _isJapan
                            ? t.myMapShare.visitedJapan
                            : t.myMapShare.visitedWorld,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _muted,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF6E6D4),
                    color: AppTheme.primaryOrange,
                  ),
                ),
                const Gap(12),
                const Align(
                  alignment: Alignment.centerRight,
                  child: _Branding(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _map({
    required List<ShareOutlineRegion> regions,
    required Set<String> visitedIds,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ColoredBox(
        color: _mapBg,
        child: ShareFillMap(
          regions: regions,
          visitedIds: visitedIds,
          japan: _isJapan,
        ),
      ),
    );
  }

  Set<String> _placesForMap() {
    if (_isJapan) {
      return {
        for (final visit in recordVisitedPrefectureStats(posts)) visit.name,
      };
    }
    if (!CountryDetector.isLoaded) {
      return const {};
    }
    return {
      for (final visit in recordVisitedCountryStats(posts)) visit.code,
    };
  }

  String _storyText(
    Translations t,
    MapShareJourney journey,
    int count,
    String languageCode,
  ) {
    if (journey.kind == MapShareStoryKind.empty && count > 0) {
      final template =
          _isJapan ? t.myMapShare.japanProgress : t.myMapShare.worldProgress;
      return _fill(template, {'count': count});
    }
    final region = _regionName(t, journey.focusKey);
    final continent = _continentName(t, journey.focusKey);
    final next = _prefectureName(journey.nextPlaceName, languageCode);
    final spread = journey.spreadCount;
    return switch (journey.kind) {
      MapShareStoryKind.empty =>
        _isJapan ? t.myMapShare.japanEmpty : t.myMapShare.worldEmpty,
      MapShareStoryKind.japanHereNeighbor => _fill(
          t.myMapShare.japanHereNeighbor,
          {'region': region, 'count': count, 'next': next},
        ),
      MapShareStoryKind.japanSpreadNeighbor => _fill(
          t.myMapShare.japanSpreadNeighbor,
          {'region': region, 'spread': spread, 'next': next},
        ),
      MapShareStoryKind.japanHereBlank => _fill(
          t.myMapShare.japanHereBlank,
          {'region': region, 'count': count, 'next': next},
        ),
      MapShareStoryKind.japanSpreadBlank => _fill(
          t.myMapShare.japanSpreadBlank,
          {'region': region, 'spread': spread, 'next': next},
        ),
      MapShareStoryKind.japanComplete => t.myMapShare.japanComplete,
      MapShareStoryKind.worldOneContinent => _fill(
          t.myMapShare.worldOneContinent,
          {'continent': continent, 'count': count},
        ),
      MapShareStoryKind.worldSpread => _fill(
          t.myMapShare.worldSpread,
          {'continent': continent, 'spread': spread},
        ),
      MapShareStoryKind.worldAllContinents => t.myMapShare.worldAllContinents,
      MapShareStoryKind.worldComplete => _fill(
          t.myMapShare.worldComplete,
          {'count': count},
        ),
      MapShareStoryKind.worldProgress => _fill(
          t.myMapShare.worldProgress,
          {'count': count},
        ),
    };
  }

  String _fill(String template, Map<String, Object> values) {
    var text = template;
    for (final entry in values.entries) {
      text = text.replaceAll('{${entry.key}}', '${entry.value}');
    }
    return text;
  }

  String _prefectureName(String? name, String languageCode) {
    if (name == null || name.isEmpty) {
      return '';
    }
    return localizedPrefectureName(name: name, languageCode: languageCode);
  }

  String _regionName(Translations t, String? key) {
    return switch (key) {
      'hokkaido' => t.myMapShare.regionHokkaido,
      'tohoku' => t.myMapShare.regionTohoku,
      'kanto' => t.myMapShare.regionKanto,
      'chubu' => t.myMapShare.regionChubu,
      'kinki' => t.myMapShare.regionKinki,
      'chugoku' => t.myMapShare.regionChugoku,
      'shikoku' => t.myMapShare.regionShikoku,
      'kyushu' => t.myMapShare.regionKyushu,
      _ => '',
    };
  }

  String _continentName(Translations t, String? key) {
    return switch (key) {
      'asia' => t.myMapShare.continentAsia,
      'europe' => t.myMapShare.continentEurope,
      'northAmerica' => t.myMapShare.continentNorthAmerica,
      'southAmerica' => t.myMapShare.continentSouthAmerica,
      'africa' => t.myMapShare.continentAfrica,
      'oceania' => t.myMapShare.continentOceania,
      _ => '',
    };
  }
}

class _Kicker extends StatelessWidget {
  const _Kicker({required this.isJapan, required this.label});

  final bool isJapan;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          isJapan ? '🇯🇵' : '🌍',
          style: const TextStyle(fontSize: MapStatsShare.kickerIconSize),
        ),
        const Gap(8),
        Text(
          label,
          style: const TextStyle(
            fontSize: MapStatsShare.kickerFontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: Color(0xFF8A93A0),
          ),
        ),
      ],
    );
  }
}

class _Branding extends StatelessWidget {
  const _Branding();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '#FoodGram',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF3A4452),
            fontSize: 13,
          ),
        ),
        const Gap(6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Assets.image.appIcon.image(
            width: 22,
            height: 22,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
