import 'package:flutter/material.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/post/providers/map_category_filter_provider.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// マップ上部に常に見せたい大カテゴリ（All の次）
const mapPrimaryCategoryNames = ['麺類', '肉料理', '軽食系'];

/// マップカテゴリフィルターのアクセントカラー（アプリの青系）
const _mapCategoryBlue = AppTheme.primaryBlue;
final _mapSubChipBackground = AppTheme.primaryBlue.withValues(alpha: 0.12);

class MapCategoryChipBar extends ConsumerWidget {
  const MapCategoryChipBar({
    required this.onCategoryChanged,
    super.key,
  });

  final Future<void> Function() onCategoryChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCategories = ref.watch(categoriesProvider);
    final categories = _orderedMapCategories(allCategories);
    final filter = ref.watch(mapCategoryFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final subTags = filter.mainCategory != null
        ? foodCategory[filter.mainCategory] ?? const <String>[]
        : const <String>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isAll = category.isAllCategory;
                    final categoryName = category.name;
                    final isSelected = isAll
                        ? filter.mainCategory == null
                        : filter.mainCategory == categoryName;
                    final label = isAll
                        ? 'All'
                        : getLocalizedCategoryName(categoryName, context);
                    return _PrimaryCategoryChip(
                      label: label,
                      icon: isAll ? null : category.displayIcon,
                      isSelected: isSelected,
                      isDark: isDark,
                      onTap: () => _onPrimarySelected(
                        ref: ref,
                        isAll: isAll,
                        categoryName: categoryName,
                        isSelected: isSelected,
                      ),
                    );
                  },
                ),
              ),
              if (filter.mainCategory != null && subTags.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: subTags.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = filter.subTagId == null;
                        return _SubCategoryChip(
                          label: Translations.of(context).foodCategory.all,
                          isSelected: isSelected,
                          onTap: () => _onSubSelected(
                            ref: ref,
                            mainCategory: filter.mainCategory!,
                            subTagId: null,
                            isSelected: isSelected,
                          ),
                        );
                      }
                      final tagId = subTags[index - 1];
                      final isSelected = filter.subTagId == tagId;
                      return _SubCategoryChip(
                        label: getLocalizedFoodName(tagId, context),
                        isSelected: isSelected,
                        onTap: () => _onSubSelected(
                          ref: ref,
                          mainCategory: filter.mainCategory!,
                          subTagId: tagId,
                          isSelected: isSelected,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onPrimarySelected({
    required WidgetRef ref,
    required bool isAll,
    required String categoryName,
    required bool isSelected,
  }) async {
    ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
          name: AnalyticsEvent.mapFilterOpen,
        );
    final notifier = ref.read(mapCategoryFilterProvider.notifier);
    if (isAll) {
      notifier.state = (mainCategory: null, subTagId: null);
    } else if (isSelected) {
      notifier.state = (mainCategory: null, subTagId: null);
    } else {
      notifier.state = (mainCategory: categoryName, subTagId: null);
    }
    ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
      name: AnalyticsEvent.mapFilterApply,
      parameters: {
        AnalyticsParam.category: isAll ? 'all' : categoryName,
      },
    );
    await onCategoryChanged();
  }

  Future<void> _onSubSelected({
    required WidgetRef ref,
    required String mainCategory,
    required String? subTagId,
    required bool isSelected,
  }) async {
    ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
          name: AnalyticsEvent.mapFilterOpen,
        );
    final notifier = ref.read(mapCategoryFilterProvider.notifier);
    if (isSelected && subTagId != null) {
      notifier.state = (mainCategory: mainCategory, subTagId: null);
    } else {
      notifier.state = (mainCategory: mainCategory, subTagId: subTagId);
    }
    ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
      name: AnalyticsEvent.mapFilterApply,
      parameters: {
        AnalyticsParam.category: mainCategory,
        if (subTagId != null) 'sub_tag': subTagId,
      },
    );
    await onCategoryChanged();
  }
}

class _PrimaryCategoryChip extends StatelessWidget {
  const _PrimaryCategoryChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    this.icon,
  });

  final String label;
  final String? icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    return Material(
      color: isSelected
          ? _mapCategoryBlue
          : (isDark ? Colors.black87 : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? _mapCategoryBlue
              : (isDark ? Colors.white38 : Colors.grey.shade300),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Text(
                  icon!,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubCategoryChip extends StatelessWidget {
  const _SubCategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? _mapCategoryBlue : _mapSubChipBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isSelected ? Colors.white : _mapCategoryBlue,
            ),
          ),
        ),
      ),
    );
  }
}

/// All → 主要3カテゴリ → その他の順
List<CategoryData> _orderedMapCategories(List<CategoryData> all) {
  final allChip = all.where((c) => c.isAllCategory).toList();
  final primary = <CategoryData>[];
  final rest = <CategoryData>[];
  for (final c in all) {
    if (c.isAllCategory) {
      continue;
    }
    if (mapPrimaryCategoryNames.contains(c.name)) {
      primary.add(c);
    } else {
      rest.add(c);
    }
  }
  primary.sort(
    (a, b) => mapPrimaryCategoryNames
        .indexOf(a.name)
        .compareTo(mapPrimaryCategoryNames.indexOf(b.name)),
  );
  return [...allChip, ...primary, ...rest];
}
