import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

/// 記録タブ：あなたの食の軌跡カード（統計）
class RecordSummarySection extends StatelessWidget {
  const RecordSummarySection({
    required this.mealsCount,
    required this.shopsCount,
    required this.prefecturesCount,
    required this.countriesCount,
    super.key,
  });

  final int mealsCount;
  final int shopsCount;
  final int prefecturesCount;
  final int countriesCount;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF161616) : Colors.white;
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFE5E7EB);
    final localeFormat = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
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
      child: Stack(
        children: [
          Positioned(
            top: -16,
            right: -12,
            child: Opacity(
              opacity: isDark ? 0.1 : 0.07,
              child: Assets.gif.recordFootprints.image(
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
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFFEF4444),
                      size: 24,
                    ),
                    const Gap(6),
                    Flexible(
                      child: Text(
                        t.myMapRecord.footprintTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  t.myMapRecord.footprintSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontWeight: FontWeight.w600,
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
                      ),
                    ],
                  ),
                ),
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
  });

  final IconData icon;
  final Color accent;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.2 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: accent,
                size: 22,
              ),
            ),
            const Gap(10),
            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: accent,
                  height: 1,
                ),
              ),
            ),
            const Gap(6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
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
