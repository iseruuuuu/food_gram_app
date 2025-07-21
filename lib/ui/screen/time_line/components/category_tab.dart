import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CategoryTab extends HookConsumerWidget {
  const CategoryTab({
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
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
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
                  height: 65,
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
                      height: (category.isAllCategory &&
                                  selectedCategoryName.value == '') ||
                              selectedCategoryName.value == category.name
                          ? 65
                          : 55,
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
                                                                  : getLocalizedCategoryName(category.name, context),
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


}
