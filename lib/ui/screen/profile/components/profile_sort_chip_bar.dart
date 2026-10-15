import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/helpers/haptic_feedback_helper.dart';
import 'package:food_gram_app/core/utils/my_profile_post_sort.dart';
import 'package:food_gram_app/gen/strings.g.dart';

class ProfileSortChipBar extends StatelessWidget {
  const ProfileSortChipBar({
    required this.selectedSort,
    required this.onSortChanged,
    super.key,
  });

  final MyProfilePostSortOrder selectedSort;
  final ValueChanged<MyProfilePostSortOrder> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).profile;
    final items = <({
      MyProfilePostSortOrder order,
      String label,
      IconData icon,
    })>[
      (
        order: MyProfilePostSortOrder.newest,
        label: t.sortNewest,
        icon: Icons.schedule_rounded,
      ),
      (
        order: MyProfilePostSortOrder.oldest,
        label: t.sortOldest,
        icon: Icons.history_rounded,
      ),
      (
        order: MyProfilePostSortOrder.starHigh,
        label: t.sortHighestRating,
        icon: Icons.star_rounded,
      ),
      (
        order: MyProfilePostSortOrder.starLow,
        label: t.sortLowestRating,
        icon: Icons.star_outline_rounded,
      ),
      (
        order: MyProfilePostSortOrder.likesHigh,
        label: t.sortMostLiked,
        icon: Icons.favorite_rounded,
      ),
    ];

    return ColoredBox(
      color: AppTheme.backgroundOf(context),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = item.order == selectedSort;
            return _SortChip(
              label: item.label,
              icon: item.icon,
              isSelected: isSelected,
              onTap: () {
                if (!isSelected) {
                  HapticFeedbackHelper.selection();
                  onSortChanged(item.order);
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        isSelected ? Colors.white : AppTheme.textPrimaryOf(context);
    final iconColor =
        isSelected ? Colors.white : AppTheme.textSecondaryOf(context);

    return Material(
      color: isSelected ? AppTheme.primaryOrange : AppTheme.cardOf(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? AppTheme.primaryOrange
              : AppTheme.dividerOf(context),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: iconColor,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
