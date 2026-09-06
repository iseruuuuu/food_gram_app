// ignore_for_file: lines_longer_than_80_chars, document_ignores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/gen/strings.g.dart';

final Map<String, List<String>> foodCategory = {
  'ご当地': ['tag:meibutsu', 'tag:souvenir'],
  '麺類': ['🍝', '🍜', 'tag:udon', 'tag:soba', 'tag:yakisoba', 'tag:tantanmen'],
  '肉料理': ['🥩', 'tag:yakiniku', 'tag:hamburg', '🍗', 'tag:tsukune', 'tag:tonkatsu', '🥓', '🍖'],
  '軽食系': ['🍔', '🍟', '🍕', '🥙', '🌯', 'tag:takoyaki', '🍤', '🥟'],
  'ご飯物': ['🍙', '🍚', 'tag:tendon', 'tag:katsudon', 'tag:omurice', '🍱', '🍳', '🍛', 'tag:stew', '🍲', '🥘', '🫕'],
  '魚介類': ['🍣', 'tag:kaisendon', '🐟', '🦐', '🦀', '🦑', '🐙', '🐚', '🦪', '🐡', '🦞', '🐳', '🦈'],
  'パン類': ['🍞', '🥖', '🥐', '🥯', 'tag:melonpan', 'tag:frenchtoast', '🍩', '🥪', '🌭', '🥨'],
  'おやつ': ['🍦', '🍮', '🍘', '🍡', '🍧', '🍨', '🥧', '🍭', '🍫', '🍿', '🍪', '🥜', '🌰', '🥮', '🍯', '🥞', '🍰', '🧁', '🧇', 'tag:montblanc', 'tag:mochi'],
  'フルーツ': ['🍎', '🍐', '🍊', '🍋', '🍋‍🟩', '🍌', '🍉', '🍇', '🍓', '🫐', '🍈', '🍒', '🍑', '🥭', '🍍', '🥥', '🥝'],
  '野菜類': ['🥗', '🍅', '🍆', '🥑', '🫛', '🥦', '🥒', '🌶️', '🫑', '🌽', '🥕', '🫒', '🧄', '🧅', '🥔', '🍠', '🫚', '🍄‍🟫'],
  'ドリンク': ['🫖', '☕️', '🍵', '🧃', '🥤', '🧋', '🍶', '🍺', '🍷', '🥃', '🍸', '🍹', '🧉', '🍾', '🍼'],
  'その他': ['🍥', '🍢', '🧀', '🥚', '🧈', 'tag:tamagoyaki'],
};

/// 食べ物の絵文字から食べ物名を取得する関数
String getFoodName(String emoji) {
  for (final category in foodCategory.values) {
    if (category.contains(emoji)) {
      return emoji;
    }
  }
  return 'その他の食べ物';
}

String getLocalizedFoodName(String tagId, BuildContext context) {
  final t = Translations.of(context);

  final customFoodNameMap = {
    'tag:meibutsu': t.tag.meibutsu,
    'tag:souvenir': t.tag.souvenir,
    'tag:udon': t.tag.udon,
    'tag:soba': t.tag.soba,
    'tag:yakisoba': t.tag.yakisoba,
    'tag:tonkatsu': t.tag.tonkatsu,
    'tag:tantanmen': t.tag.tantanmen,
    'tag:takoyaki': t.tag.takoyaki,
    'tag:tsukune': t.tag.tsukune,
    'tag:omurice': t.tag.omurice,
    'tag:tamagoyaki': t.tag.tamagoyaki,
    'tag:frenchtoast': t.tag.frenchToast,
    'tag:montblanc': t.tag.montBlanc,
    'tag:stew': t.tag.stew,
    'tag:hamburg': t.tag.hamburg,
    'tag:yakiniku': t.tag.yakiniku,
    'tag:tendon': t.tag.tendon,
    'tag:katsudon': t.tag.katsudon,
    'tag:kaisendon': t.tag.kaisendon,
    'tag:mochi': t.tag.mochi,
    'tag:melonpan': t.tag.melonpan,
  };
  final customName = customFoodNameMap[tagId];
  if (customName != null) {
    return customName;
  }

  final foodNameMap = {
    '🍝': t.tag.pasta,
    '🍜': t.tag.ramen,
    '🥩': t.tag.steak,
    '🍖': t.tag.otherMeat,
    '🍗': t.tag.chicken,
    '🥓': t.tag.bacon,
    '🍔': t.tag.hamburger,
    '🍟': t.tag.frenchFries,
    '🍕': t.tag.pizza,
    '🥙': t.tag.tacos,
    '🫔': t.tag.tamales,
    '🥟': t.tag.chineseCuisine,
    '🍤': t.tag.friedShrimp,
    '🍲': t.tag.hotPot,
    '🍛': t.tag.curry,
    '🥘': t.tag.paella,
    '🫕': t.tag.fondue,
    '🍙': t.tag.onigiri,
    '🍚': t.tag.rice,
    '🍱': t.tag.bento,
    '🍣': t.tag.sushi,
    '🐟': t.tag.fish,
    '🐙': t.tag.octopus,
    '🦑': t.tag.squid,
    '🦐': t.tag.shrimp,
    '🦀': t.tag.crab,
    '🐚': t.tag.shellfish,
    '🦪': t.tag.oyster,
    '🐡': t.tag.fugu,
    '🦞': t.tag.lobster,
    '🐳': t.tag.whale,
    '🦈': t.tag.shark,
    '🍞': t.tag.bread,
    '🥪': t.tag.sandwich,
    '🌭': t.tag.hotDog,
    '🍩': t.tag.donut,
    '🥞': t.tag.pancake,
    '🥐': t.tag.croissant,
    '🥯': t.tag.bagel,
    '🥖': t.tag.baguette,
    '🥨': t.tag.pretzel,
    '🌮': t.tag.tacos,
    '🌯': t.tag.burrito,
    '🍦': t.tag.softServe,
    '🍮': t.tag.pudding,
    '🍘': t.tag.riceCracker,
    '🍡': t.tag.dango,
    '🍧': t.tag.shavedIce,
    '🍨': t.tag.iceCream,
    '🥧': t.tag.pie,
    '🧁': t.tag.muffin,
    '🍰': t.tag.cake,
    '🍭': t.tag.lollipop,
    '🍬': t.tag.candy,
    '🍫': t.tag.chocolate,
    '🍿': t.tag.popcorn,
    '🍪': t.tag.cookie,
    '🥜': t.tag.peanuts,
    '🫘': t.tag.beans,
    '🌰': t.tag.chestnut,
    '🥠': t.tag.fortuneCookie,
    '🥮': t.tag.mooncake,
    '🍯': t.tag.honey,
    '🧇': t.tag.waffle,
    '🍏': t.tag.apple,
    '🍎': t.tag.apple,
    '🍐': t.tag.pear,
    '🍊': t.tag.orange,
    '🍋': t.tag.lemon,
    '🍋‍🟩': t.tag.lime,
    '🍌': t.tag.banana,
    '🍉': t.tag.watermelon,
    '🍇': t.tag.grapes,
    '🍓': t.tag.strawberry,
    '🫐': t.tag.blueberry,
    '🍈': t.tag.melon,
    '🍒': t.tag.cherry,
    '🍑': t.tag.peach,
    '🥭': t.tag.mango,
    '🍍': t.tag.pineapple,
    '🥥': t.tag.coconut,
    '🥝': t.tag.kiwi,
    '🥗': t.tag.salad,
    '🍅': t.tag.tomato,
    '🍆': t.tag.eggplant,
    '🥑': t.tag.avocado,
    '🫛': t.tag.greenBeans,
    '🥦': t.tag.broccoli,
    '🥒': t.tag.cucumber,
    '🌶️': t.tag.chili,
    '🫑': t.tag.bellPepper,
    '🌽': t.tag.corn,
    '🥕': t.tag.carrot,
    '🫒': t.tag.olive,
    '🧄': t.tag.garlic,
    '🧅': t.tag.onion,
    '🥔': t.tag.potato,
    '🍠': t.tag.sweetPotato,
    '🫚': t.tag.ginger,
    '🍄‍🟫': t.tag.shiitake,
    '🫖': t.tag.teapot,
    '☕️': t.tag.coffee,
    '🍵': t.tag.tea,
    '🧃': t.tag.juice,
    '🥤': t.tag.softDrink,
    '🧋': t.tag.bubbleTea,
    '🍶': t.tag.sake,
    '🍺': t.tag.beer,
    '🍷': t.tag.wine,
    '🥃': t.tag.whiskey,
    '🍸': t.tag.cocktail,
    '🍹': t.tag.tropicalCocktail,
    '🧉': t.tag.mateTea,
    '🍾': t.tag.champagne,
    '🍼': t.tag.milk,
    '🍥': t.tag.kamaboko,
    '🍢': t.tag.oden,
    '🧀': t.tag.cheese,
    '🥚': t.tag.egg,
    '🍳': t.tag.teishoku,
    '🧈': t.tag.butter,
  };

  return foodNameMap[tagId] ?? t.tag.otherFood;
}

/// 投稿の foodTag 文字列をタグIDのリストに分解する
List<String> parseFoodTagIds(String foodTag) {
  return foodTag
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

String getLocalizedCategoryName(String categoryName, BuildContext context) {
  final t = Translations.of(context);

  switch (categoryName) {
    case 'ご当地':
      return t.tag.localSpecialties;
    case '麺類':
      return t.tag.noodles;
    case '肉料理':
      return t.tag.meatDishes;
    case '軽食系':
      return t.tag.fastFood;
    case 'ご飯物':
      return t.tag.riceDishes;
    case '魚介類':
      return t.tag.seafood;
    case 'パン類':
      return t.tag.bread;
    case 'おやつ':
      return t.tag.sweetsAndSnacks;
    case 'フルーツ':
      return t.tag.fruits;
    case '野菜類':
      return t.tag.vegetables;
    case 'ドリンク':
      return t.tag.beverages;
    case 'その他':
      return t.tag.others;
    default:
      return categoryName;
  }
}

typedef CategoryData = ({String name, String displayIcon, bool isAllCategory});

/// 食べ物の絵文字からアイコンと食べ物名の両方を取得する関数
({String emoji, String name}) getFoodTagData(String emoji) {
  for (final category in foodCategory.values) {
    if (category.contains(emoji)) {
      return (emoji: emoji, name: emoji);
    }
  }
  return (emoji: emoji, name: '');
}

final categoriesProvider = Provider<List<CategoryData>>((ref) {
  final result = <CategoryData>[
    (name: '', displayIcon: '🍽️', isAllCategory: true),
  ];
  foodCategory.forEach((key, value) {
    final foodEmojis = value;
    result.add(
      (
        name: key,
        displayIcon: foodEmojis.isNotEmpty ? foodEmojis[0] : '🍽️',
        isAllCategory: false
      ),
    );
  });
  return result;
});
