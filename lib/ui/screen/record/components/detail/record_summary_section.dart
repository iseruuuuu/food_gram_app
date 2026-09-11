import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_premium_lock.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

/// 記録タブ：あなたの食の軌跡。累計の食べ歩き規模を振り返る。
class RecordSummarySection extends StatelessWidget {
  const RecordSummarySection({
    required this.mealsCount,
    required this.shopsCount,
    required this.prefecturesCount,
    required this.countriesCount,
    required this.isSubscribed,
    required this.onTapPremiumCta,
    super.key,
  });

  final int mealsCount;
  final int shopsCount;
  final int prefecturesCount;
  final int countriesCount;
  final bool isSubscribed;
  final VoidCallback onTapPremiumCta;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFE5E7EB);
    final localeFormat = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: recordSectionCardDecoration(isDark: isDark),
      child: Stack(
        children: [
          Positioned(
            top: -16,
            right: -12,
            child: Opacity(
              opacity: isDark ? 0.1 : 0.07,
              child: Lottie.asset(
                Assets.lottie.recordFootprints,
                width: 500,
                height: 500,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.myMapRecord.footprintTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(14),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      _JourneyStatColumn(
                        icon: Icons.restaurant,
                        accent: const Color(0xFFEF4444),
                        value: localeFormat.format(mealsCount),
                        label: t.myMapRecord.recordedMealsLabel,
                        locked: !isSubscribed,
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: dividerColor,
                      ),
                      _JourneyStatColumn(
                        icon: Icons.storefront_outlined,
                        accent: const Color(0xFF3B82F6),
                        value: localeFormat.format(shopsCount),
                        label: t.myMapRecord.visitedShopsLabel,
                        locked: !isSubscribed,
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: dividerColor,
                      ),
                      _JourneyStatColumn(
                        icon: Icons.map_outlined,
                        accent: const Color(0xFF16A34A),
                        value: '$prefecturesCount',
                        label: t.myMapRecord.prefecturesUnit,
                        locked: !isSubscribed,
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: dividerColor,
                      ),
                      _JourneyStatColumn(
                        icon: Icons.public,
                        accent: const Color(0xFFF59E0B),
                        value: '$countriesCount',
                        label: t.myMapRecord.countriesUnit,
                        locked: !isSubscribed,
                      ),
                    ],
                  ),
                ),
                if (!isSubscribed) ...[
                  const Gap(14),
                  RecordPremiumLockBanner(
                    message: t.myMapRecord.insight.footprintLockedHint,
                    ctaLabel: t.myMapRecord.insight.lockedDiscoveriesCta,
                    onTap: onTapPremiumCta,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyStatColumn extends StatelessWidget {
  const _JourneyStatColumn({
    required this.icon,
    required this.accent,
    required this.value,
    required this.label,
    this.locked = false,
  });

  final IconData icon;
  final Color accent;
  final String value;
  final String label;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Icon(
              locked ? Icons.lock_outline_rounded : icon,
              color:
                  locked ? (isDark ? Colors.white38 : Colors.black38) : accent,
              size: 28,
            ),
            const Gap(4),
            FittedBox(
              child: Text(
                locked ? '—' : value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: locked
                      ? AppTheme.primaryBlue.withValues(alpha: 0.4)
                      : accent,
                  height: 1,
                ),
              ),
            ),
            const Gap(4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
