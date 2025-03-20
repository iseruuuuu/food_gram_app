import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:gap/gap.dart';

class AppCategoryItem extends StatefulWidget {
  const AppCategoryItem({
    required this.selectedCategoryName,
    super.key,
  });

  final ValueNotifier<String> selectedCategoryName;

  @override
  State<AppCategoryItem> createState() => _AppCategoryItemState();
}

class _AppCategoryItemState extends State<AppCategoryItem>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Map<String, dynamic>> _categoriesData;

  @override
  void initState() {
    super.initState();
    _initCategories();
    // +1 は「すべて」カテゴリー用
    _tabController = TabController(length: _categoriesData.length, vsync: this);

    // 選択カテゴリが変更されたらタブコントローラーも更新
    widget.selectedCategoryName.addListener(_updateTabFromCategory);
  }

  void _initCategories() {
    final allCategories = <Map<String, dynamic>>[
      {
        'name': '',
        'displayIcon': '🍽️',
        'isAllCategory': true,
      }
    ];

    // 他のカテゴリーを追加
    foodCategory.forEach((key, value) {
      allCategories.add({
        'name': key,
        'displayIcon': value.isNotEmpty ? value[0] : '🍽️',
        'isAllCategory': false,
      });
    });

    _categoriesData = allCategories;
  }

  void _updateTabFromCategory() {
    if (!mounted) {
      return;
    }

    final categoryName = widget.selectedCategoryName.value;
    final index = _categoriesData.indexWhere(
      (cat) => cat['isAllCategory']
          ? categoryName.isEmpty
          : cat['name'] == categoryName,
    );

    if (index != -1 && index != _tabController.index) {
      _tabController.animateTo(index);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    widget.selectedCategoryName.removeListener(_updateTabFromCategory);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Column(
      children: [
        TabBar(
          indicatorWeight: 1,
          controller: _tabController,
          isScrollable: true,
          padding: EdgeInsets.zero,
          tabAlignment: TabAlignment.start,
          automaticIndicatorColorAdjustment: false,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 4),
          ),
          enableFeedback: true,
          labelColor: Colors.black,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          unselectedLabelColor: Colors.grey,
          dividerColor: Colors.black,
          onTap: (index) {
            final category = _categoriesData[index];
            widget.selectedCategoryName.value =
                category['isAllCategory'] ? '' : category['name'];
          },
          tabs: _buildTabs(l10n),
        ),
      ],
    );
  }

  List<Widget> _buildTabs(L10n l10n) {
    return _categoriesData.map((category) {
      final isAllCategory = category['isAllCategory'] as bool;
      final categoryName = category['name'] as String;
      final displayIcon = category['displayIcon'] as String;
      return Tab(
        height: 40,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayIcon,
                style: const TextStyle(fontSize: 20),
              ),
              Gap(8),
              Text(
                isAllCategory
                    ? l10n.foodCategoryAll
                    : l10nCategory(categoryName, l10n),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String l10nCategory(String categoryName, L10n l10n) {
    String displayName;
    switch (categoryName) {
      case 'Noodles':
        displayName = l10n.foodCategoryNoodles;
        break;
      case 'Meat':
        displayName = l10n.foodCategoryMeat;
        break;
      case 'Fast Food':
        displayName = l10n.foodCategoryFastFood;
        break;
      case 'Rice Dishes':
        displayName = l10n.foodCategoryRiceDishes;
        break;
      case 'Seafood':
        displayName = l10n.foodCategorySeafood;
        break;
      case 'Bread':
        displayName = l10n.foodCategoryBread;
        break;
      case 'Sweets & Snacks':
        displayName = l10n.foodCategorySweetsAndSnacks;
        break;
      case 'Fruits':
        displayName = l10n.foodCategoryFruits;
        break;
      case 'Vegetables':
        displayName = l10n.foodCategoryVegetables;
        break;
      case 'Beverages':
        displayName = l10n.foodCategoryBeverages;
        break;
      case 'Others':
        displayName = l10n.foodCategoryOthers;
        break;
      default:
        displayName = categoryName;
    }

    return displayName;
  }
}
