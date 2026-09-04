import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/format/post_price_formatter.dart';
import 'package:food_gram_app/gen/strings.g.dart';

/// 選択中店舗のヘッダー。レストラン名をタイトルにし、投稿画像はその下に置く。
class MapSelectedPostCard extends StatelessWidget {
  const MapSelectedPostCard({
    required this.posts,
    required this.restaurantName,
    this.onClose,
    super.key,
  });

  final List<Posts> posts;
  final String restaurantName;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? Colors.white70 : const Color(0xFF5F5F5F);
    final representative = posts.isEmpty ? null : posts.first;
    final avgStar = _averageStar(posts);
    final tagIds = representative == null
        ? const <String>[]
        : parseFoodTagIds(representative.foodTag);
    final tagLabel =
        tagIds.isEmpty ? null : getLocalizedFoodName(tagIds.first, context);
    final priceRange = _priceRangeDisplay(posts);
    final price = priceRange == null
        ? ''
        : priceRange.min == priceRange.max
            ? priceRange.min
            : Translations.of(context).map.priceRange(
                  min: priceRange.min,
                  max: priceRange.max,
                );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  restaurantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                    height: 1.2,
                  ),
                ),
              ),
              if (avgStar != null) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFC107),
                  size: 20,
                ),
                const SizedBox(width: 2),
                Text(
                  avgStar.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                ),
              ],
              if (onClose != null)
                IconButton(
                  onPressed: onClose,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  icon: Icon(Icons.close, color: onSurface, size: 22),
                ),
            ],
          ),
          if (tagLabel != null || price.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                [
                  if (tagLabel != null) tagLabel,
                  if (price.isNotEmpty) price,
                ].join('  ·  '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: tagLabel != null ? AppTheme.primaryBlue : muted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

double? _averageStar(List<Posts> posts) {
  final stars = posts.map((e) => e.star).where((s) => s > 0);
  if (stars.isEmpty) {
    return null;
  }
  return stars.reduce((a, b) => a + b) / stars.length;
}

/// 値段が付いている投稿の最安〜最高。通貨が混在する場合は最多通貨のみ使う。
({String min, String max})? _priceRangeDisplay(List<Posts> posts) {
  final priced = <({double amount, String currency})>[];
  for (final post in posts) {
    final amount = post.priceAmount;
    final currency = post.priceCurrency?.trim();
    if (amount == null || currency == null || currency.isEmpty) {
      continue;
    }
    priced.add((amount: amount, currency: currency.toUpperCase()));
  }
  if (priced.isEmpty) {
    return null;
  }
  final counts = <String, int>{};
  for (final item in priced) {
    counts[item.currency] = (counts[item.currency] ?? 0) + 1;
  }
  final currency =
      counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  final amounts = priced
      .where((item) => item.currency == currency)
      .map((item) => item.amount);
  final minAmount = amounts.reduce((a, b) => a < b ? a : b);
  final maxAmount = amounts.reduce((a, b) => a > b ? a : b);
  return (
    min: formatPostPriceDisplay(amount: minAmount, currencyCode: currency),
    max: formatPostPriceDisplay(amount: maxAmount, currencyCode: currency),
  );
}
