import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_category_item.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesData = ref.watch(categoriesProvider);
    final l10n = L10n.of(context);
    final nearbyPosts = ref.watch(getNearByPostsProvider);
    final supabase = ref.watch(supabaseProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '📍近いレストラン',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    child: const Text(
                      'もっとみる',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
