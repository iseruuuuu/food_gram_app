// ignore_for_file: lines_longer_than_80_chars, document_ignores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/i18n/strings.g.dart';

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
    '🇯🇵': t.tagJapaneseCuisine,
    '🇮🇹': t.tagItalianCuisine,
    '🇫🇷': t.tagFrenchCuisine,
    '🇨🇳': t.tagChineseCuisine,
    '🇮🇳': t.tagIndianCuisine,
    '🇲🇽': t.tagMexicanCuisine,
    '🇭🇰': t.tagHongKongCuisine,
    '🇺🇸': t.tagAmericanCuisine,
    '🇲🇹': t.tagMediterraneanCuisine,
    '🇹🇭': t.tagThaiCuisine,
    '🇬🇷': t.tagGreekCuisine,
    '🇹🇷': t.tagTurkishCuisine,
    '🇰🇷': t.tagKoreanCuisine,
    '🇷🇺': t.tagRussianCuisine,
    '🇪🇸': t.tagSpanishCuisine,
    '🇻🇳': t.tagVietnameseCuisine,
    '🇵🇹': t.tagPortugueseCuisine,
    '🇦🇹': t.tagAustrianCuisine,
    '🇧🇪': t.tagBelgianCuisine,
    '🇸🇪': t.tagSwedishCuisine,
    '🇩🇪': t.tagGermanCuisine,
    '🇬🇧': t.tagBritishCuisine,
    '🇳🇱': t.tagDutchCuisine,
    '🇦🇺': t.tagAustralianCuisine,
    '🇧🇷': t.tagBrazilianCuisine,
    '🇦🇷': t.tagArgentineCuisine,
    '🇨🇴': t.tagColombianCuisine,
    '🇵🇪': t.tagPeruvianCuisine,
    '🇳🇴': t.tagNorwegianCuisine,
    '🇩🇰': t.tagDanishCuisine,
    '🇵🇱': t.tagPolishCuisine,
    '🇨🇿': t.tagCzechCuisine,
    '🇭🇺': t.tagHungarianCuisine,
    '🇿🇦': t.tagSouthAfricanCuisine,
    '🇪🇬': t.tagEgyptianCuisine,
    '🇲🇦': t.tagMoroccanCuisine,
    '🇳🇿': t.tagNewZealandCuisine,
    '🇵🇭': t.tagFilipinoCuisine,
    '🇲🇾': t.tagMalaysianCuisine,
    '🇸🇬': t.tagSingaporeanCuisine,
    '🇮🇩': t.tagIndonesianCuisine,
    '🇮🇷': t.tagIranianCuisine,
    '🇸🇦': t.tagSaudiArabianCuisine,
    '🇲🇳': t.tagMongolianCuisine,
    '🇰🇭': t.tagCambodianCuisine,
    '🇱🇦': t.tagLaotianCuisine,
    '🇨🇺': t.tagCubanCuisine,
    '🇯🇲': t.tagJamaicanCuisine,
    '🇨🇱': t.tagChileanCuisine,
    '🇻🇪': t.tagVenezuelanCuisine,
    '🇵🇦': t.tagPanamanianCuisine,
    '🇧🇴': t.tagBolivianCuisine,
    '🇮🇸': t.tagIcelandicCuisine,
    '🇱🇹': t.tagLithuanianCuisine,
    '🇪🇪': t.tagEstonianCuisine,
    '🇱🇻': t.tagLatvianCuisine,
    '🇫🇮': t.tagFinnishCuisine,
    '🇭🇷': t.tagCroatianCuisine,
    '🇸🇮': t.tagSlovenianCuisine,
    '🇸🇰': t.tagSlovakCuisine,
    '🇷🇴': t.tagRomanianCuisine,
    '🇧🇬': t.tagBulgarianCuisine,
    '🇷🇸': t.tagSerbianCuisine,
    '🇦🇱': t.tagAlbanianCuisine,
    '🇬🇪': t.tagGeorgianCuisine,
    '🇦🇲': t.tagArmenianCuisine,
    '🇦🇿': t.tagAzerbaijaniCuisine,
    '🇺🇦': t.tagUkrainianCuisine,
    '🇧🇾': t.tagBelarusianCuisine,
    '🇰🇿': t.tagKazakhCuisine,
    '🇺🇿': t.tagUzbekCuisine,
    '🇰🇬': t.tagKyrgyzCuisine,
    '🇹🇲': t.tagTurkmenCuisine,
    '🇹🇯': t.tagTajikCuisine,
    '🇲🇻': t.tagMaldivianCuisine,
    '🇳🇵': t.tagNepaleseCuisine,
    '🇧🇩': t.tagBangladeshiCuisine,
    '🇲🇲': t.tagMyanmarCuisine,
    '🇧🇳': t.tagBruneianCuisine,
    '🇹🇼': t.tagTaiwaneseCuisine,
    '🇳🇬': t.tagNigerianCuisine,
    '🇰🇪': t.tagKenyanCuisine,
    '🇬🇭': t.tagGhanaianCuisine,
    '🇪🇹': t.tagEthiopianCuisine,
    '🇸🇩': t.tagSudaneseCuisine,
    '🇹🇳': t.tagTunisianCuisine,
    '🇦🇴': t.tagAngolanCuisine,
    '🇨🇩': t.tagCongoleseCuisine,
    '🇿🇼': t.tagZimbabweanCuisine,
    '🇲🇬': t.tagMalagasyCuisine,
    '🇵🇬': t.tagPapuaNewGuineanCuisine,
    '🇼🇸': t.tagSamoanCuisine,
    '🇹🇻': t.tagTuvaluanCuisine,
    '🇫🇯': t.tagFijianCuisine,
    '🇵🇼': t.tagPalauanCuisine,
    '🇰🇮': t.tagKiribatiCuisine,
    '🇻🇺': t.tagVanuatuanCuisine,
    '🇧🇭': t.tagBahrainiCuisine,
    '🇶🇦': t.tagQatariCuisine,
    '🇰🇼': t.tagKuwaitiCuisine,
    '🇴🇲': t.tagOmaniCuisine,
    '🇾🇪': t.tagYemeniCuisine,
    '🇱🇧': t.tagLebaneseCuisine,
    '🇸🇾': t.tagSyrianCuisine,
    '🇯🇴': t.tagJordanianCuisine,
  };
  return countryNameMap[emoji] ?? t.tagOtherCuisine;
}

final Map<String, List<String>> foodCategory = {
  '麺類': ['🍝', '🍜'],
  '肉料理': ['🥩', '🍖', '🍗', '🥓'],
  '軽食系': ['🍔', '🍟', '🍕', '🥙', '🫔', '🥟', '🍤'],
  'ご飯物': ['🍲', '🍛', '🫕', '🍙', '🍚', '🍱', '🥘', '🌮', '🌯'],
  '魚介類': ['🍣', '🐟', '🐙', '🦑', '🦐', '🦀', '🐚', '🦪'],
  'パン類': ['🍞', '🥪', '🌭', '🍩', '🥞', '🥐', '🥯', '🥖', '🥨'],
  'おやつ': ['🍦', '🧇', '🍮', '🍘', '🍡', '🍧', '🍨', '🥧', '🧁', '🍰', '🍭', '🍬', '🍫', '🍿', '🍪', '🥜', '🫘', '🌰', '🥠', '🥮', '🍯'],
  'フルーツ': ['🍎', '🍏', '🍐', '🍊', '🍋', '🍋‍🟩', '🍌', '🍉', '🍇', '🍓', '🫐', '🍈', '🍒', '🍑', '🥭', '🍍', '🥥', '🥝'],
  '野菜類': ['🥗', '🍅', '🍆', '🥑', '🫛', '🥦', '🥬', '🥒', '🌶️', '🫑', '🌽', '🥕', '🫒', '🧄', '🧅', '🥔', '🍠', '🫚', '🍄‍🟫'],
  'ドリンク': ['🫖', '☕️', '🍵', '🧃', '🥤', '🧋', '🍶', '🍺', '🥂', '🍷', '🥃', '🍸', '🍹', '🧉', '🍾', '🍼'],
  'その他': ['🍥', '🍢', '🧀', '🥚', '🍳', '🧈'],
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

String getLocalizedFoodName(String emoji, BuildContext context) {
  final t = Translations.of(context);

  final foodNameMap = {
    '🍝': t.tagPasta,
    '🍜': t.tagRamen,
    '🥩': t.tagSteak,
    '🍖': t.tagYakiniku,
    '🍗': t.tagChicken,
    '🥓': t.tagBacon,
    '🍔': t.tagHamburger,
    '🍟': t.tagFrenchFries,
    '🍕': t.tagPizza,
    '🥙': t.tagTacos,
    '🫔': t.tagTamales,
    '🥟': t.tagGyoza,
    '🍤': t.tagFriedShrimp,
    '🍲': t.tagHotPot,
    '🍛': t.tagCurry,
    '🥘': t.tagPaella,
    '🫕': t.tagFondue,
    '🍙': t.tagOnigiri,
    '🍚': t.tagRice,
    '🍱': t.tagBento,
    '🍣': t.tagSushi,
    '🐟': t.tagFish,
    '🐙': t.tagOctopus,
    '🦑': t.tagSquid,
    '🦐': t.tagShrimp,
    '🦀': t.tagCrab,
    '🐚': t.tagShellfish,
    '🦪': t.tagOyster,
    '🍞': t.tagBread,
    '🥪': t.tagSandwich,
    '🌭': t.tagHotDog,
    '🍩': t.tagDonut,
    '🥞': t.tagPancake,
    '🥐': t.tagCroissant,
    '🥯': t.tagBagel,
    '🥖': t.tagBaguette,
    '🥨': t.tagPretzel,
    '🌮': t.tagTacos,
    '🌯': t.tagBurrito,
    '🍦': t.tagIceCream,
    '🍮': t.tagPudding,
    '🍘': t.tagRiceCracker,
    '🍡': t.tagDango,
    '🍧': t.tagShavedIce,
    '🍨': t.tagIceCream,
    '🥧': t.tagPie,
    '🧁': t.tagCupcake,
    '🍰': t.tagCake,
    '🍭': t.tagLollipop,
    '🍬': t.tagCandy,
    '🍫': t.tagChocolate,
    '🍿': t.tagPopcorn,
    '🍪': t.tagCookie,
    '🥜': t.tagPeanuts,
    '🫘': t.tagBeans,
    '🌰': t.tagChestnut,
    '🥠': t.tagFortuneCookie,
    '🥮': t.tagMooncake,
    '🍯': t.tagHoney,
    '🧇': t.tagWaffle,
    '🍏': t.tagApple,
    '🍎': t.tagApple,
    '🍐': t.tagPear,
    '🍊': t.tagOrange,
    '🍋': t.tagLemon,
    '🍋‍🟩': t.tagLime,
    '🍌': t.tagBanana,
    '🍉': t.tagWatermelon,
    '🍇': t.tagGrapes,
    '🍓': t.tagStrawberry,
    '🫐': t.tagBlueberry,
    '🍈': t.tagMelon,
    '🍒': t.tagCherry,
    '🍑': t.tagPeach,
    '🥭': t.tagMango,
    '🍍': t.tagPineapple,
    '🥥': t.tagCoconut,
    '🥝': t.tagKiwi,
    '🥗': t.tagSalad,
    '🍅': t.tagTomato,
    '🍆': t.tagEggplant,
    '🥑': t.tagAvocado,
    '🫛': t.tagGreenBeans,
    '🥦': t.tagBroccoli,
    '🥬': t.tagLettuce,
    '🥒': t.tagCucumber,
    '🌶️': t.tagChili,
    '🫑': t.tagBellPepper,
    '🌽': t.tagCorn,
    '🥕': t.tagCarrot,
    '🫒': t.tagOlive,
    '🧄': t.tagGarlic,
    '🧅': t.tagOnion,
    '🥔': t.tagPotato,
    '🍠': t.tagSweetPotato,
    '🫚': t.tagGinger,
    '🍄‍🟫': t.tagShiitake,
    '🫖': t.tagTeapot,
    '☕️': t.tagCoffee,
    '🍵': t.tagTea,
    '🧃': t.tagJuice,
    '🥤': t.tagSoftDrink,
    '🧋': t.tagBubbleTea,
    '🍶': t.tagSake,
    '🍺': t.tagBeer,
    '🥂': t.tagChampagne,
    '🍷': t.tagWine,
    '🥃': t.tagWhiskey,
    '🍸': t.tagCocktail,
    '🍹': t.tagTropicalCocktail,
    '🧉': t.tagMateTea,
    '🍾': t.tagChampagne,
    '🍼': t.tagMilk,
    '🍥': t.tagKamaboko,
    '🍢': t.tagOden,
    '🧀': t.tagCheese,
    '🥚': t.tagEgg,
    '🍳': t.tagFriedEgg,
    '🧈': t.tagButter,
  };

  return foodNameMap[emoji] ?? t.tagOtherFood;
}

String getLocalizedCategoryName(String categoryName, BuildContext context) {
  final t = Translations.of(context);

  switch (categoryName) {
    case '麺類':
      return t.tagNoodles;
    case '肉料理':
      return t.tagMeatDishes;
    case '軽食系':
      return t.tagFastFood;
    case 'ご飯物':
      return t.tagRiceDishes;
    case '魚介類':
      return t.tagSeafood;
    case 'パン類':
      return t.tagBread;
    case 'おやつ':
      return t.tagSweetsAndSnacks;
    case 'フルーツ':
      return t.tagFruits;
    case '野菜類':
      return t.tagVegetables;
    case 'ドリンク':
      return t.tagBeverages;
    case 'その他':
      return t.tagOthers;
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
