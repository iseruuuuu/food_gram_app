import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';

/// 日本・世界の達成率シェア画像。
class MapStatsShare extends StatelessWidget {
  const MapStatsShare({
    required this.viewType,
    required this.visitedPrefecturesCount,
    required this.visitedCountriesCount,
    super.key,
  });

  final MapViewType viewType;
  final int visitedPrefecturesCount;
  final int visitedCountriesCount;

  static const Size size = Size(compositionWidth, compositionHeight);
  static const double compositionWidth = 360;
  static const double compositionHeight = 400;
  static const double cardWidth = 320;
  static const double cardHeight = 240;
  static const int prefectureTotal = 47;
  static const int countryTotal = 195;

  bool get _isJapan => viewType == MapViewType.japan;

  int get count => _isJapan ? visitedPrefecturesCount : visitedCountriesCount;

  int get total => _isJapan ? prefectureTotal : countryTotal;

  String _challengeTitle(Translations t) {
    return _isJapan
        ? t.myMapShare.japanChallengeTitle
        : t.myMapShare.worldChallengeTitle;
  }

  String _questionText(Translations t) {
    return _isJapan ? t.myMapShare.japanQuestion : t.myMapShare.worldQuestion;
  }

  String _label(Translations t) {
    return _isJapan ? t.mapStats.prefectures : t.mapStats.visitedCountries;
  }

  String shareMessage(Translations t) {
    final challengeInProgress = _isJapan
        ? t.myMapShare.japanChallengeInProgress
        : t.myMapShare.worldChallengeInProgress;
    final currentProgress = t.myMapShare.currentProgress
        .replaceAll('{count}', count.toString())
        .replaceAll('{total}', total.toString());
    return '$challengeInProgress\n'
        '$currentProgress\n\n'
        '${t.myMapShare.yourTurn}\n\n'
        '#FoodGram';
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return SizedBox(
      width: compositionWidth,
      height: compositionHeight,
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 56),
            Text(
              _questionText(t),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: _MapStatsShareCard(
                  viewType: viewType,
                  challengeTitle: _challengeTitle(t),
                  count: count,
                  total: total,
                  label: _label(t),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapStatsShareCard extends StatelessWidget {
  const _MapStatsShareCard({
    required this.viewType,
    required this.challengeTitle,
    required this.count,
    required this.total,
    required this.label,
  });

  final MapViewType viewType;
  final String challengeTitle;
  final int count;
  final int total;
  final String label;

  @override
  Widget build(BuildContext context) {
    final emoji = viewType == MapViewType.japan ? '🗾' : '🌍';
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black26,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(24),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 24)),
                    const Gap(8),
                    Text(
                      challengeTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  '$count / $total',
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryOrange,
                    height: 1.1,
                  ),
                ),
              ),
              const Gap(8),
              Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    '#FoodGram',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF444444),
                      fontSize: 14,
                    ),
                  ),
                  const Gap(6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Assets.image.appIcon.image(
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              const Gap(8),
            ],
          ),
        ),
      ),
    );
  }
}
