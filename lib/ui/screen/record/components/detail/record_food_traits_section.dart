import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/analyzer/record_food_traits_analyzer.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

/// 記録タブ：プレミアム向けの食傾向カード群
class RecordFoodTraitsSection extends StatelessWidget {
  const RecordFoodTraitsSection({
    required this.posts,
    required this.cardColor,
    required this.mutedColor,
    required this.isSubscribed,
    required this.onTapPremiumCta,
    super.key,
  });

  final List<Posts> posts;
  final Color cardColor;
  final Color mutedColor;
  final bool isSubscribed;
  final VoidCallback onTapPremiumCta;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final ratingFormat = NumberFormat.decimalPattern(localeTag)
      ..minimumFractionDigits = 1
      ..maximumFractionDigits = 1;
    final summary = analyzeRecordFoodTraits(posts);
    final total = summary.totalPosts == 0 ? 1 : summary.totalPosts;
    final traits = [
      _RecordFoodTraitItem(
        title: t.myMapRecord.foodTraits.frequentAreaTitle,
        value: summary.topArea ?? t.myMapRecord.foodTraits.noData,
        subValue: summary.topArea == null
            ? null
            : t.myMapRecord.foodTraits.shareOfTotal.replaceAll(
                '{percent}',
                recordFoodTraitsRatio(summary.topAreaCount, total).toString(),
              ),
      ),
      _RecordFoodTraitItem(
        title: t.myMapRecord.foodTraits.topGenreTitle,
        value: summary.topGenre ?? t.myMapRecord.foodTraits.noData,
        subValue: summary.topGenre == null
            ? null
            : t.myMapRecord.foodTraits.shareOfTotal.replaceAll(
                '{percent}',
                recordFoodTraitsRatio(summary.topGenreCount, total).toString(),
              ),
      ),
      _RecordFoodTraitItem(
        title: t.myMapRecord.foodTraits.frequentTimeTitle,
        value: summary.topTimeSlot == null
            ? t.myMapRecord.foodTraits.noData
            : recordFoodTraitsTimeSlotLabel(t, summary.topTimeSlot!),
        subValue: summary.topTimeSlot == null
            ? null
            : t.myMapRecord.foodTraits.shareOfTotal.replaceAll(
                '{percent}',
                recordFoodTraitsRatio(summary.topTimeCount, total).toString(),
              ),
      ),
      _RecordFoodTraitItem(
        title: t.myMapRecord.foodTraits.frequentRestaurantTitle,
        value: summary.topRestaurant ?? t.myMapRecord.foodTraits.noData,
        subValue: summary.topRestaurant == null
            ? null
            : t.myMapRecord.foodTraits.shareOfTotal.replaceAll(
                '{percent}',
                recordFoodTraitsRatio(summary.topRestaurantCount, total)
                    .toString(),
              ),
      ),
      _RecordFoodTraitItem(
        title: t.myMapRecord.foodTraits.averageRatingTitle,
        value: summary.averageRating == null
            ? t.myMapRecord.foodTraits.noRating
            : ratingFormat.format(summary.averageRating!),
        subValue: summary.ratingCount == 0
            ? null
            : t.myMapRecord.foodTraits.ratingCount.replaceAll(
                '{count}',
                summary.ratingCount.toString(),
              ),
      ),
      _RecordFoodTraitItem(
        title: t.myMapRecord.foodTraits.explorationRateTitle,
        value: '${summary.explorationRatio}%',
        subValue: summary.firstVisitCount == 0
            ? null
            : t.myMapRecord.foodTraits.firstVisitCount.replaceAll(
                '{count}',
                summary.firstVisitCount.toString(),
              ),
      ),
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      t.myMapRecord.foodTraits.sectionTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      t.myMapRecord.foodTraits.premiumBadge,
                      style: TextStyle(
                        color: Colors.amber.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                Stack(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: traits
                          .map(
                            (trait) => _TraitCard(
                              trait: trait,
                              mutedColor: mutedColor,
                            ),
                          )
                          .toList(),
                    ),
                    if (!isSubscribed)
                      Positioned.fill(
                        child: _NonSubscriberOverlay(
                          t: t,
                          onTapPremiumCta: onTapPremiumCta,
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

class _RecordFoodTraitItem {
  const _RecordFoodTraitItem({
    required this.title,
    required this.value,
    this.subValue,
  });

  final String title;
  final String value;
  final String? subValue;
}

class _NonSubscriberOverlay extends StatelessWidget {
  const _NonSubscriberOverlay({
    required this.t,
    required this.onTapPremiumCta,
  });

  final Translations t;
  final VoidCallback onTapPremiumCta;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.72),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.08),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 28,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Gap(4),
                Text(
                  t.myMapRecord.foodTraits.lockedDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(8),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: onTapPremiumCta,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFE8A63A),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: Text(
                      t.myMapRecord.foodTraits.premiumCta,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TraitCard extends StatelessWidget {
  const _TraitCard({
    required this.trait,
    required this.mutedColor,
  });

  final _RecordFoodTraitItem trait;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 16 * 2 - 14 * 2 - 8) / 2;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1D1D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trait.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: mutedColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(4),
          FittedBox(
            child: Text(
              trait.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
          if (trait.subValue != null) ...[
            const Gap(4),
            Text(
              trait.subValue!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: mutedColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
