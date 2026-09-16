import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/search_utils.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/food_tag_icon.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

typedef OnTagSelected = void Function(List<String> tags);

class AppFoodTag extends HookWidget {
  const AppFoodTag({
    required this.onTagSelected,
    required this.foodTags,
    required this.foodTexts,
    this.emptyHint,
    super.key,
  });

  final OnTagSelected onTagSelected;
  final List<String> foodTags;
  final ValueNotifier<List<String>> foodTexts;
  final String? emptyHint;

  Future<void> _showTagSelector(
    BuildContext context,
    ValueNotifier<List<String>> foodTexts,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HookBuilder(
        builder: (context) {
          final selectedTags = useState<List<String>>(foodTags);
          final selectedTexts = useState<List<String>>(foodTexts.value);
          final searchController = useTextEditingController();
          final searchQuery = useState<String>('');
          final filteredCategories = useMemoized(
            () {
              if (searchQuery.value.isEmpty) {
                return foodCategory.entries.toList();
              }
              final filtered = <MapEntry<String, List<String>>>[];
              for (final entry in foodCategory.entries) {
                final filteredFoods = entry.value.where((food) {
                  final emoji = food;
                  final text = getLocalizedFoodName(food, context);
                  return isSearchMatch(searchQuery.value, emoji) ||
                      isSearchMatch(searchQuery.value, text);
                }).toList();
                if (filteredFoods.isNotEmpty) {
                  filtered.add(MapEntry(entry.key, filteredFoods));
                }
              }
              return filtered;
            },
            [searchQuery.value, context],
          );
          useEffect(
            () {
              void listener() {
                searchQuery.value = searchController.text;
              }

              searchController.addListener(listener);
              return () => searchController.removeListener(listener);
            },
            [searchController],
          );
          final scheme = Theme.of(context).colorScheme;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final sheetBg = isDark ? scheme.surface : Colors.white;
          final sheetFg = isDark ? Colors.white : Colors.black;
          final sheetFgMuted = isDark ? Colors.white70 : Colors.grey;
          // 真っ黒に潰れないよう、チップ/検索欄は一段明るい面色にする
          final chipBg = isDark ? scheme.surfaceContainerHighest : Colors.white;
          final chipBorder = isDark ? Colors.white24 : Colors.grey[300]!;
          return GestureDetector(
            onTap: () => primaryFocus?.unfocus(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: context.pop,
                          child: Text(
                            Translations.of(context).cancel,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          Translations.of(context).post.selectFoodTag,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: sheetFg,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            onTagSelected(selectedTags.value);
                            foodTexts.value = selectedTexts.value;
                            context.pop();
                          },
                          child: Text(
                            Translations.of(context).save,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark ? Colors.white : AppTheme.primaryOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                    ),
                    child: TextField(
                      controller: searchController,
                      style: TextStyle(color: sheetFg),
                      decoration: InputDecoration(
                        hintText: Translations.of(context).searchFood,
                        hintStyle: TextStyle(color: sheetFgMuted),
                        prefixIcon: Icon(Icons.search, color: sheetFg),
                        suffixIcon: searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: sheetFg),
                                onPressed: searchController.clear,
                              )
                            : null,
                        filled: isDark,
                        fillColor: isDark ? chipBg : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: sheetFgMuted),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: sheetFgMuted),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: filteredCategories.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: sheetFgMuted,
                                  ),
                                  const Gap(16),
                                  Text(
                                    Translations.of(context).noResultsFound,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: sheetFgMuted,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: filteredCategories.map((entry) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        getLocalizedCategoryName(
                                          entry.key,
                                          context,
                                        ),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: sheetFg,
                                        ),
                                      ),
                                    ),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: entry.value.map((food) {
                                        final tagId = food;
                                        final text = getLocalizedFoodName(
                                          food,
                                          context,
                                        );
                                        final isSelected =
                                            selectedTags.value.contains(tagId);
                                        return GestureDetector(
                                          onTap: () {
                                            final newSelectedTags = <String>[
                                              ...selectedTags.value,
                                            ];
                                            final newSelectedTexts = <String>[
                                              ...selectedTexts.value,
                                            ];
                                            if (isSelected) {
                                              newSelectedTags.remove(tagId);
                                              newSelectedTexts.remove(text);
                                            } else {
                                              newSelectedTags.add(tagId);
                                              newSelectedTexts.add(text);
                                            }
                                            selectedTags.value =
                                                newSelectedTags;
                                            selectedTexts.value =
                                                newSelectedTexts;
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppTheme.primaryOrange
                                                  : chipBg,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppTheme.primaryOrange
                                                    : chipBorder,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                FoodTagIcon(
                                                  tagId: tagId,
                                                  size: 20,
                                                ),
                                                const Gap(4),
                                                Text(
                                                  text,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : sheetFg,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    useValueListenable(foodTexts);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showTagSelector(context, foodTexts),
      child: Padding(
        padding: EdgeInsets.zero,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: Row(
                  children: [
                    const Gap(12),
                    Expanded(
                      child: foodTags.isEmpty
                          ? Text(
                              emptyHint ??
                                  Translations.of(context).post.categoryTitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: scheme.onSurfaceVariant,
                              ),
                            )
                          : Row(
                              children: [
                                if (foodTags.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryOrange
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.primaryOrange
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FoodTagIcon(
                                          tagId: foodTags.first,
                                          size: 22,
                                        ),
                                        const Gap(2),
                                        Text(
                                          getLocalizedFoodName(
                                            foodTags.first,
                                            context,
                                          ),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : AppTheme.primaryOrange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (foodTags.length > 1)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryOrange
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.primaryOrange
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          FoodTagIcon(
                                            tagId: foodTags[1],
                                            size: 22,
                                          ),
                                          const Gap(2),
                                          Text(
                                            getLocalizedFoodName(
                                              foodTags[1],
                                              context,
                                            ),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white
                                                  : AppTheme.primaryOrange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (foodTags.length > 2)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      '+${foodTags.length - 2}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : AppTheme.primaryOrange,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    if (foodTags.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: scheme.onSurface,
                        ),
                      ),
                    const Gap(2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
