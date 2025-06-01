import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// カテゴリーを表すレコード型
typedef CategoryData = ({String name, String displayIcon, bool isAllCategory});

final categoriesProvider = Provider<List<CategoryData>>((ref) {
  final result = <CategoryData>[
    (name: '', displayIcon: '🍽️', isAllCategory: true),
  ];
  foodCategory.forEach((key, value) {
    final foodEmojis = value;
    result.add(
      (
        name: key,
        displayIcon: foodEmojis.isNotEmpty && foodEmojis[0].isNotEmpty
            ? foodEmojis[0][0]
            : '🍽️',
        isAllCategory: false
      ),
    );
  });
  return result;
});

class AppCategoryItem extends HookConsumerWidget {
  const AppCategoryItem({
    required this.selectedCategoryName,
    super.key,
  });

  final ValueNotifier<String> selectedCategoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final categoriesData = ref.watch(categoriesProvider);
    final tabController = useTabController(
      initialLength: categoriesData.length,
    );
    useEffect(
      () {
        void updateTabFromCategory() {
          final categoryName = selectedCategoryName.value;
          final index = categoriesData.indexWhere(
            (cat) => cat.isAllCategory
                ? categoryName.isEmpty
                : cat.name == categoryName,
          );
          if (index != -1 && index != tabController.index) {
            tabController.animateTo(index);
          }
        }

        selectedCategoryName.addListener(updateTabFromCategory);
        return () {
          selectedCategoryName.removeListener(updateTabFromCategory);
        };
      },
      [tabController, selectedCategoryName],
    );

    return Column(
      children: [
        TabBar(
          indicatorWeight: 1,
          controller: tabController,
          isScrollable: true,
          padding: EdgeInsets.zero,
          tabAlignment: TabAlignment.start,
          automaticIndicatorColorAdjustment: false,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          indicatorSize: TabBarIndicatorSize.tab,
          enableFeedback: true,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 2,
              color: Colors.orange,
            ),
          ),
          dividerColor: Colors.orange,
          dividerHeight: 2,
          onTap: (index) {
            final category = categoriesData[index];
            selectedCategoryName.value =
                category.isAllCategory ? '' : category.name;
          },
          tabs: categoriesData
              .map(
                (category) => Tab(
                  height: 70,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        color: Colors.orange,
                      ),
                      width: MediaQuery.sizeOf(context).width / 6,
                      height:
                          selectedCategoryName.value == category.name ? 70 : 65,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category.displayIcon,
                            style: const TextStyle(
                              fontSize: 22,
                              height: 1.5,
                            ),
                          ),
                          Text(
                            category.isAllCategory
                                ? l10n.foodCategoryAll
                                : _l10nCategory(category.name, l10n),
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // プライベートヘルパーメソッド
  String _l10nCategory(String categoryName, L10n l10n) {
    switch (categoryName) {
      case 'Noodles':
        return l10n.foodCategoryNoodles;
      case 'Meat':
        return l10n.foodCategoryMeat;
      case 'Fast Food':
        return l10n.foodCategoryFastFood;
      case 'Rice Dishes':
        return l10n.foodCategoryRiceDishes;
      case 'Seafood':
        return l10n.foodCategorySeafood;
      case 'Bread':
        return l10n.foodCategoryBread;
      case 'Sweets & Snacks':
        return l10n.foodCategorySweetsAndSnacks;
      case 'Fruits':
        return l10n.foodCategoryFruits;
      case 'Vegetables':
        return l10n.foodCategoryVegetables;
      case 'Beverages':
        return l10n.foodCategoryBeverages;
      case 'Others':
        return l10n.foodCategoryOthers;
      default:
        return categoryName;
    }
  }
}
