import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:gap/gap.dart';

class AppMapStatsShareWidget extends StatelessWidget {
  const AppMapStatsShareWidget({
    required this.viewType,
    required this.challengeTitle,
    required this.count,
    required this.total,
    required this.label,
    super.key,
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
                    color: AppTheme.primaryBlue,
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
                  Assets.icon.icon3.image(width: 28, height: 28),
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
