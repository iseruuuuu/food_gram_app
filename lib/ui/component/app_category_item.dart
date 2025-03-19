import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';

class AppCategoryItem extends StatelessWidget {
  const AppCategoryItem({
    required this.selectedCategoryName,
    super.key,
  });

  final ValueNotifier<String> selectedCategoryName;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: foodCategory.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: () {
                selectedCategoryName.value = '';
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selectedCategoryName.value.isEmpty
                      ? Colors.black
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(),
                ),
                child: Row(
                  children: [
                    Text('🍽️', style: TextStyle(fontSize: 18)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        l10n.foodCategoryAll,
                        style: TextStyle(
                          color: selectedCategoryName.value.isEmpty
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final entry = foodCategory.entries.elementAt(index - 1);
          final categoryName = entry.key;
          final foodEmojis = entry.value;
          final displayIcon = foodEmojis.isNotEmpty ? foodEmojis[0] : '🍽️';
          final isSelected = selectedCategoryName.value == categoryName;
          return GestureDetector(
            onTap: () {
              selectedCategoryName.value = categoryName;
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(),
              ),
              child: Row(
                children: [
                  Text(displayIcon, style: TextStyle(fontSize: 24)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      l10nCategory(categoryName, l10n),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
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
