// ignore_for_file: lines_longer_than_80_chars, document_ignores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/gen/strings.g.dart';

final Set<String> countryEmojis = {
  '🇯🇵', '🇮🇹', '🇫🇷', '🇨🇳', '🇮🇳', '🇲🇽', '🇭🇰', '🇺🇸', '🇲🇹', '🇹🇭', '🇬🇷', '🇹🇷', '🇰🇷', '🇷🇺', '🇪🇸', '🇻🇳', '🇵🇹', '🇦🇹', '🇧🇪', '🇸🇪',
  '🇩🇪', '🇬🇧', '🇳🇱', '🇦🇺', '🇧🇷', '🇦🇷', '🇨🇴', '🇵🇪', '🇳🇴', '🇩🇰', '🇵🇱', '🇨🇿', '🇭🇺', '🇿🇦', '🇪🇬', '🇲🇦', '🇳🇿', '🇵🇭', '🇲🇾', '🇸🇬',
  '🇮🇩', '🇮🇷', '🇸🇦', '🇲🇳', '🇰🇭', '🇱🇦', '🇨🇺', '🇯🇲', '🇨🇱', '🇻🇪', '🇵🇦', '🇧🇴', '🇮🇸', '🇱🇹', '🇪🇪', '🇱🇻', '🇫🇮', '🇭🇷', '🇸🇮', '🇸🇰',
  '🇷🇴', '🇧🇬', '🇷🇸', '🇦🇱', '🇬🇪', '🇦🇲', '🇦🇿', '🇺🇦', '🇧🇾', '🇰🇿', '🇺🇿', '🇰🇬', '🇹🇲', '🇹🇯', '🇲🇻', '🇳🇵', '🇧🇩', '🇲🇲', '🇧🇳', '🇹🇼',
  '🇳🇬', '🇰🇪', '🇬🇭', '🇪🇹', '🇸🇩', '🇹🇳', '🇦🇴', '🇨🇩', '🇿🇼', '🇲🇬', '🇵🇬', '🇼🇸', '🇹🇻', '🇫🇯', '🇵🇼', '🇰🇮', '🇻🇺', '🇧🇭', '🇶🇦', '🇰🇼',
  '🇴🇲', '🇾🇪', '🇱🇧', '🇸🇾', '🇯🇴',
};

/// 国の絵文字から料理名を取得する関数
String getCountryName(String emoji) {
  return countryEmojis.contains(emoji) ? emoji : 'その他の料理';
}

/// 国の絵文字から料理名を取得する関数
String getLocalizedCountryName(String emoji, BuildContext context) {
  final t = Translations.of(context);
  final countryNameMap = {
    '🇯🇵': t.tag.japaneseCuisine,
    '🇮🇹': t.tag.italianCuisine,
    '🇫🇷': t.tag.frenchCuisine,
    '🇨🇳': t.tag.chineseCuisine,
    '🇮🇳': t.tag.indianCuisine,
    '🇲🇽': t.tag.mexicanCuisine,
    '🇭🇰': t.tag.hongKongCuisine,
    '🇺🇸': t.tag.americanCuisine,
    '🇲🇹': t.tag.mediterraneanCuisine,
    '🇹🇭': t.tag.thaiCuisine,
    '🇬🇷': t.tag.greekCuisine,
    '🇹🇷': t.tag.turkishCuisine,
    '🇰🇷': t.tag.koreanCuisine,
    '🇷🇺': t.tag.russianCuisine,
    '🇪🇸': t.tag.spanishCuisine,
    '🇻🇳': t.tag.vietnameseCuisine,
    '🇵🇹': t.tag.portugueseCuisine,
    '🇦🇹': t.tag.austrianCuisine,
    '🇧🇪': t.tag.belgianCuisine,
    '🇸🇪': t.tag.swedishCuisine,
    '🇩🇪': t.tag.germanCuisine,
    '🇬🇧': t.tag.britishCuisine,
    '🇳🇱': t.tag.dutchCuisine,
    '🇦🇺': t.tag.australianCuisine,
    '🇧🇷': t.tag.brazilianCuisine,
    '🇦🇷': t.tag.argentineCuisine,
    '🇨🇴': t.tag.colombianCuisine,
    '🇵🇪': t.tag.peruvianCuisine,
    '🇳🇴': t.tag.norwegianCuisine,
    '🇩🇰': t.tag.danishCuisine,
    '🇵🇱': t.tag.polishCuisine,
    '🇨🇿': t.tag.czechCuisine,
    '🇭🇺': t.tag.hungarianCuisine,
    '🇿🇦': t.tag.southAfricanCuisine,
    '🇪🇬': t.tag.egyptianCuisine,
    '🇲🇦': t.tag.moroccanCuisine,
    '🇳🇿': t.tag.newZealandCuisine,
    '🇵🇭': t.tag.filipinoCuisine,
    '🇲🇾': t.tag.malaysianCuisine,
    '🇸🇬': t.tag.singaporeanCuisine,
    '🇮🇩': t.tag.indonesianCuisine,
    '🇮🇷': t.tag.iranianCuisine,
    '🇸🇦': t.tag.saudiArabianCuisine,
    '🇲🇳': t.tag.mongolianCuisine,
    '🇰🇭': t.tag.cambodianCuisine,
    '🇱🇦': t.tag.laotianCuisine,
    '🇨🇺': t.tag.cubanCuisine,
    '🇯🇲': t.tag.jamaicanCuisine,
    '🇨🇱': t.tag.chileanCuisine,
    '🇻🇪': t.tag.venezuelanCuisine,
    '🇵🇦': t.tag.panamanianCuisine,
    '🇧🇴': t.tag.bolivianCuisine,
    '🇮🇸': t.tag.icelandicCuisine,
    '🇱🇹': t.tag.lithuanianCuisine,
    '🇪🇪': t.tag.estonianCuisine,
    '🇱🇻': t.tag.latvianCuisine,
    '🇫🇮': t.tag.finnishCuisine,
    '🇭🇷': t.tag.croatianCuisine,
    '🇸🇮': t.tag.slovenianCuisine,
    '🇸🇰': t.tag.slovakCuisine,
    '🇷🇴': t.tag.romanianCuisine,
    '🇧🇬': t.tag.bulgarianCuisine,
    '🇷🇸': t.tag.serbianCuisine,
    '🇦🇱': t.tag.albanianCuisine,
    '🇬🇪': t.tag.georgianCuisine,
    '🇦🇲': t.tag.armenianCuisine,
    '🇦🇿': t.tag.azerbaijaniCuisine,
    '🇺🇦': t.tag.ukrainianCuisine,
    '🇧🇾': t.tag.belarusianCuisine,
    '🇰🇿': t.tag.kazakhCuisine,
    '🇺🇿': t.tag.uzbekCuisine,
    '🇰🇬': t.tag.kyrgyzCuisine,
    '🇹🇲': t.tag.turkmenCuisine,
    '🇹🇯': t.tag.tajikCuisine,
    '🇲🇻': t.tag.maldivianCuisine,
    '🇳🇵': t.tag.nepaleseCuisine,
    '🇧🇩': t.tag.bangladeshiCuisine,
    '🇲🇲': t.tag.myanmarCuisine,
    '🇧🇳': t.tag.bruneianCuisine,
    '🇹🇼': t.tag.taiwaneseCuisine,
    '🇳🇬': t.tag.nigerianCuisine,
    '🇰🇪': t.tag.kenyanCuisine,
    '🇬🇭': t.tag.ghanaianCuisine,
    '🇪🇹': t.tag.ethiopianCuisine,
    '🇸🇩': t.tag.sudaneseCuisine,
    '🇹🇳': t.tag.tunisianCuisine,
    '🇦🇴': t.tag.angolanCuisine,
    '🇨🇩': t.tag.congoleseCuisine,
    '🇿🇼': t.tag.zimbabweanCuisine,
    '🇲🇬': t.tag.malagasyCuisine,
    '🇵🇬': t.tag.papuaNewGuineanCuisine,
    '🇼🇸': t.tag.samoanCuisine,
    '🇹🇻': t.tag.tuvaluanCuisine,
    '🇫🇯': t.tag.fijianCuisine,
    '🇵🇼': t.tag.palauanCuisine,
    '🇰🇮': t.tag.kiribatiCuisine,
    '🇻🇺': t.tag.vanuatuanCuisine,
    '🇧🇭': t.tag.bahrainiCuisine,
    '🇶🇦': t.tag.qatariCuisine,
    '🇰🇼': t.tag.kuwaitiCuisine,
    '🇴🇲': t.tag.omaniCuisine,
    '🇾🇪': t.tag.yemeniCuisine,
    '🇱🇧': t.tag.lebaneseCuisine,
    '🇸🇾': t.tag.syrianCuisine,
    '🇯🇴': t.tag.jordanianCuisine,
  };
  return countryNameMap[emoji] ?? t.tag.otherCuisine;
}

final Map<String, List<String>> foodCategory = {
  '麺類': [
    '🍝',
    '🍜',
    'tag:udon',
    'tag:soba',
    'tag:yakisoba',
    'tag:tantanmen',
  ],
  '肉料理': ['🥩', '🍗', '🍖', '🥓', 'tag:tonkatsu', 'tag:tsukune'],
  '軽食系': ['🍔', '🍟', '🍕', '🥙', '🌯', '🍤', '🥟', 'tag:takoyaki'],
  'ご飯物': ['🍲', '🍛', '🫕', '🍙', '🍚', '🍱', '🥘', '🍳', 'tag:omurice', 'tag:stew'],
  '魚介類': ['🍣', '🐟', '🐙', '🦑', '🦐', '🦀', '🐚', '🦪', '🐡', '🦞', '🐳', '🦈'],
  'パン類': ['🍞', '🥪', '🌭', '🍩', '🥞', '🥐', '🥯', '🥖', '🥨', '🧁', '🧇', '🍰', 'tag:frenchtoast'],
  'おやつ': ['🍦', '🍮', '🍘', '🍡', '🍧', '🍨', '🥧', '🍭', '🍫', '🍿', '🍪', '🥜', '🌰', '🥮', '🍯', 'tag:montblanc'],
  'フルーツ': ['🍎', '🍐', '🍊', '🍋', '🍋‍🟩', '🍌', '🍉', '🍇', '🍓', '🫐', '🍈', '🍒', '🍑', '🥭', '🍍', '🥥', '🥝'],
  '野菜類': ['🥗', '🍅', '🍆', '🥑', '🫛', '🥦', '🥬', '🥒', '🌶️', '🫑', '🌽', '🥕', '🫒', '🧄', '🧅', '🥔', '🍠', '🫚', '🍄‍🟫'],
  'ドリンク': ['🫖', '☕️', '🍵', '🧃', '🥤', '🧋', '🍶', '🍺', '🥂', '🍷', '🥃', '🍸', '🍹', '🧉', '🍾', '🍼'],
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
  };
  final customName = customFoodNameMap[tagId];
  if (customName != null) {
    return customName;
  }

  final foodNameMap = {
    '🍝': t.tag.pasta,
    '🍜': t.tag.ramen,
    '🥩': t.tag.steak,
    '🍖': t.tag.yakiniku,
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
    '🥬': t.tag.lettuce,
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
    '🥂': t.tag.champagne,
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

/// 国の絵文字からアイコンと料理名の両方を取得する関数
({String emoji, String name}) getCountryTagData(String emoji) {
  final name = countryEmojis.contains(emoji) ? emoji : '';
  return (emoji: emoji, name: name);
}

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
