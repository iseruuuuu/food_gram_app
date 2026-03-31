import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/post/providers/map_category_filter_provider.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MapCategoryChipBar extends ConsumerWidget {
  const MapCategoryChipBar({
    required this.onCategoryChanged,
    super.key,
  });

  final Future<void> Function() onCategoryChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedMapCategoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isAll = category.isAllCategory;
          final categoryName = category.name;
          final isSelected = isAll
              ? selectedCategory == null
              : selectedCategory == categoryName;
          final label =
              isAll ? 'All' : getLocalizedCategoryName(categoryName, context);
          return ChoiceChip(
            selected: isSelected,
            showCheckmark: false,
            avatar: Text(
              category.displayIcon,
              style: const TextStyle(fontSize: 15),
            ),
            label: Text(label),
            selectedColor: AppTheme.primaryBlue,
            backgroundColor: isDark ? Colors.black87 : Colors.white,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
            ),
            side: BorderSide(
              color: isSelected
                  ? AppTheme.primaryBlue
                  : (isDark ? Colors.white38 : Colors.grey.shade300),
            ),
            onSelected: (selected) async {
              final notifier = ref.read(selectedMapCategoryProvider.notifier);
              if (isAll) {
                notifier.state = null;
              } else {
                notifier.state = isSelected ? null : categoryName;
              }
              await onCategoryChanged();
            },
          );
        },
      ),
    );
  }
}
