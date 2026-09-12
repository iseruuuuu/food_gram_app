import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/restaurant_group.dart';
import 'package:food_gram_app/core/utils/restaurant/restaurant_display_name.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';

/// マップ下部シートのエリア投稿カード（画像上・テキスト下の縦積み）
class MapAreaRestaurantCard extends StatelessWidget {
  const MapAreaRestaurantCard({
    required this.group,
    required this.imageUrl,
    required this.onTap,
    super.key,
  });

  static const double imageSize = 120;
  static const double width = 120;
  static const double height = 200;

  final RestaurantGroup group;
  final String? imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? Colors.white : Colors.black;
    final muted = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final t = Translations.of(context);
    final foodName = group.posts.isEmpty
        ? ''
        : group.representativePost.foodName.trim();
    final avgStar = group.averageStar;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: imageUrl == null
                      ? Image.asset(
                          isDark
                              ? Assets.image.emptyDark.path
                              : Assets.image.empty.path,
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Image.asset(
                            isDark
                                ? Assets.image.emptyDark.path
                                : Assets.image.empty.path,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizedRestaurantName(group.name, t),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (foodName.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  foodName,
                  style: TextStyle(
                    fontSize: 12,
                    color: muted,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  if (avgStar != null) ...[
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFC107),
                      size: 16,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      avgStar.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: muted,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${group.posts.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
