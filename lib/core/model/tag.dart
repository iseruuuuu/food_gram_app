// ignore_for_file: lines_longer_than_80_chars, document_ignores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';

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
  final l10n = L10n.of(context);
  final countryNameMap = {
    '🇯🇵': l10n.tagJapaneseCuisine,
    '🇮🇹': l10n.tagItalianCuisine,
    '🇫🇷': l10n.tagFrenchCuisine,
    '🇨🇳': l10n.tagChineseCuisine,
    '🇮🇳': l10n.tagIndianCuisine,
    '🇲🇽': l10n.tagMexicanCuisine,
    '🇭🇰': l10n.tagHongKongCuisine,
    '🇺🇸': l10n.tagAmericanCuisine,
    '🇲🇹': l10n.tagMediterraneanCuisine,
    '🇹🇭': l10n.tagThaiCuisine,
    '🇬🇷': l10n.tagGreekCuisine,
    '🇹🇷': l10n.tagTurkishCuisine,
    '🇰🇷': l10n.tagKoreanCuisine,
    '🇷🇺': l10n.tagRussianCuisine,
    '🇪🇸': l10n.tagSpanishCuisine,
    '🇻🇳': l10n.tagVietnameseCuisine,
    '🇵🇹': l10n.tagPortugueseCuisine,
    '🇦🇹': l10n.tagAustrianCuisine,
    '🇧🇪': l10n.tagBelgianCuisine,
    '🇸🇪': l10n.tagSwedishCuisine,
    '🇩🇪': l10n.tagGermanCuisine,
    '🇬🇧': l10n.tagBritishCuisine,
    '🇳🇱': l10n.tagDutchCuisine,
    '🇦🇺': l10n.tagAustralianCuisine,
    '🇧🇷': l10n.tagBrazilianCuisine,
    '🇦🇷': l10n.tagArgentineCuisine,
    '🇨🇴': l10n.tagColombianCuisine,
    '🇵🇪': l10n.tagPeruvianCuisine,
    '🇳🇴': l10n.tagNorwegianCuisine,
    '🇩🇰': l10n.tagDanishCuisine,
    '🇵🇱': l10n.tagPolishCuisine,
    '🇨🇿': l10n.tagCzechCuisine,
    '🇭🇺': l10n.tagHungarianCuisine,
    '🇿🇦': l10n.tagSouthAfricanCuisine,
    '🇪🇬': l10n.tagEgyptianCuisine,
    '🇲🇦': l10n.tagMoroccanCuisine,
    '🇳🇿': l10n.tagNewZealandCuisine,
    '🇵🇭': l10n.tagFilipinoCuisine,
    '🇲🇾': l10n.tagMalaysianCuisine,
    '🇸🇬': l10n.tagSingaporeanCuisine,
    '🇮🇩': l10n.tagIndonesianCuisine,
    '🇮🇷': l10n.tagIranianCuisine,
    '🇸🇦': l10n.tagSaudiArabianCuisine,
    '🇲🇳': l10n.tagMongolianCuisine,
    '🇰🇭': l10n.tagCambodianCuisine,
    '🇱🇦': l10n.tagLaotianCuisine,
    '🇨🇺': l10n.tagCubanCuisine,
    '🇯🇲': l10n.tagJamaicanCuisine,
    '🇨🇱': l10n.tagChileanCuisine,
    '🇻🇪': l10n.tagVenezuelanCuisine,
    '🇵🇦': l10n.tagPanamanianCuisine,
    '🇧🇴': l10n.tagBolivianCuisine,
    '🇮🇸': l10n.tagIcelandicCuisine,
    '🇱🇹': l10n.tagLithuanianCuisine,
    '🇪🇪': l10n.tagEstonianCuisine,
    '🇱🇻': l10n.tagLatvianCuisine,
    '🇫🇮': l10n.tagFinnishCuisine,
    '🇭🇷': l10n.tagCroatianCuisine,
    '🇸🇮': l10n.tagSlovenianCuisine,
    '🇸🇰': l10n.tagSlovakCuisine,
    '🇷🇴': l10n.tagRomanianCuisine,
    '🇧🇬': l10n.tagBulgarianCuisine,
    '🇷🇸': l10n.tagSerbianCuisine,
    '🇦🇱': l10n.tagAlbanianCuisine,
    '🇬🇪': l10n.tagGeorgianCuisine,
    '🇦🇲': l10n.tagArmenianCuisine,
    '🇦🇿': l10n.tagAzerbaijaniCuisine,
    '🇺🇦': l10n.tagUkrainianCuisine,
    '🇧🇾': l10n.tagBelarusianCuisine,
    '🇰🇿': l10n.tagKazakhCuisine,
    '🇺🇿': l10n.tagUzbekCuisine,
    '🇰🇬': l10n.tagKyrgyzCuisine,
    '🇹🇲': l10n.tagTurkmenCuisine,
    '🇹🇯': l10n.tagTajikCuisine,
    '🇲🇻': l10n.tagMaldivianCuisine,
    '🇳🇵': l10n.tagNepaleseCuisine,
    '🇧🇩': l10n.tagBangladeshiCuisine,
    '🇲🇲': l10n.tagMyanmarCuisine,
    '🇧🇳': l10n.tagBruneianCuisine,
    '🇹🇼': l10n.tagTaiwaneseCuisine,
    '🇳🇬': l10n.tagNigerianCuisine,
    '🇰🇪': l10n.tagKenyanCuisine,
    '🇬🇭': l10n.tagGhanaianCuisine,
    '🇪🇹': l10n.tagEthiopianCuisine,
    '🇸🇩': l10n.tagSudaneseCuisine,
    '🇹🇳': l10n.tagTunisianCuisine,
    '🇦🇴': l10n.tagAngolanCuisine,
    '🇨🇩': l10n.tagCongoleseCuisine,
    '🇿🇼': l10n.tagZimbabweanCuisine,
    '🇲🇬': l10n.tagMalagasyCuisine,
    '🇵🇬': l10n.tagPapuaNewGuineanCuisine,
    '🇼🇸': l10n.tagSamoanCuisine,
    '🇹🇻': l10n.tagTuvaluanCuisine,
    '🇫🇯': l10n.tagFijianCuisine,
    '🇵🇼': l10n.tagPalauanCuisine,
    '🇰🇮': l10n.tagKiribatiCuisine,
    '🇻🇺': l10n.tagVanuatuanCuisine,
    '🇧🇭': l10n.tagBahrainiCuisine,
    '🇶🇦': l10n.tagQatariCuisine,
    '🇰🇼': l10n.tagKuwaitiCuisine,
    '🇴🇲': l10n.tagOmaniCuisine,
    '🇾🇪': l10n.tagYemeniCuisine,
    '🇱🇧': l10n.tagLebaneseCuisine,
    '🇸🇾': l10n.tagSyrianCuisine,
    '🇯🇴': l10n.tagJordanianCuisine,
  };
  return countryNameMap[emoji] ?? l10n.tagOtherCuisine;
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
  final l10n = L10n.of(context);

  final foodNameMap = {
    '🍝': l10n.tagPasta,
    '🍜': l10n.tagRamen,
    '🥩': l10n.tagSteak,
    '🍖': l10n.tagYakiniku,
    '🍗': l10n.tagChicken,
    '🥓': l10n.tagBacon,
    '🍔': l10n.tagHamburger,
    '🍟': l10n.tagFrenchFries,
    '🍕': l10n.tagPizza,
    '🥙': l10n.tagTacos,
    '🫔': l10n.tagTamales,
    '🥟': l10n.tagGyoza,
    '🍤': l10n.tagFriedShrimp,
    '🍲': l10n.tagHotPot,
    '🍛': l10n.tagCurry,
    '🥘': l10n.tagPaella,
    '🫕': l10n.tagFondue,
    '🍙': l10n.tagOnigiri,
    '🍚': l10n.tagRice,
    '🍱': l10n.tagBento,
    '🍣': l10n.tagSushi,
    '🐟': l10n.tagFish,
    '🐙': l10n.tagOctopus,
    '🦑': l10n.tagSquid,
    '🦐': l10n.tagShrimp,
    '🦀': l10n.tagCrab,
    '🐚': l10n.tagShellfish,
    '🦪': l10n.tagOyster,
    '🍞': l10n.tagBread,
    '🥪': l10n.tagSandwich,
    '🌭': l10n.tagHotDog,
    '🍩': l10n.tagDonut,
    '🥞': l10n.tagPancake,
    '🥐': l10n.tagCroissant,
    '🥯': l10n.tagBagel,
    '🥖': l10n.tagBaguette,
    '🥨': l10n.tagPretzel,
    '🌮': l10n.tagTacos,
    '🌯': l10n.tagBurrito,
    '🍦': l10n.tagIceCream,
    '🍮': l10n.tagPudding,
    '🍘': l10n.tagRiceCracker,
    '🍡': l10n.tagDango,
    '🍧': l10n.tagShavedIce,
    '🍨': l10n.tagIceCream,
    '🥧': l10n.tagPie,
    '🧁': l10n.tagCupcake,
    '🍰': l10n.tagCake,
    '🍭': l10n.tagLollipop,
    '🍬': l10n.tagCandy,
    '🍫': l10n.tagChocolate,
    '🍿': l10n.tagPopcorn,
    '🍪': l10n.tagCookie,
    '🥜': l10n.tagPeanuts,
    '🫘': l10n.tagBeans,
    '🌰': l10n.tagChestnut,
    '🥠': l10n.tagFortuneCookie,
    '🥮': l10n.tagMooncake,
    '🍯': l10n.tagHoney,
    '🧇': l10n.tagWaffle,
    '🍏': l10n.tagApple,
    '🍎': l10n.tagApple,
    '🍐': l10n.tagPear,
    '🍊': l10n.tagOrange,
    '🍋': l10n.tagLemon,
    '🍋‍🟩': l10n.tagLime,
    '🍌': l10n.tagBanana,
    '🍉': l10n.tagWatermelon,
    '🍇': l10n.tagGrapes,
    '🍓': l10n.tagStrawberry,
    '🫐': l10n.tagBlueberry,
    '🍈': l10n.tagMelon,
    '🍒': l10n.tagCherry,
    '🍑': l10n.tagPeach,
    '🥭': l10n.tagMango,
    '🍍': l10n.tagPineapple,
    '🥥': l10n.tagCoconut,
    '🥝': l10n.tagKiwi,
    '🥗': l10n.tagSalad,
    '🍅': l10n.tagTomato,
    '🍆': l10n.tagEggplant,
    '🥑': l10n.tagAvocado,
    '🫛': l10n.tagGreenBeans,
    '🥦': l10n.tagBroccoli,
    '🥬': l10n.tagLettuce,
    '🥒': l10n.tagCucumber,
    '🌶️': l10n.tagChili,
    '🫑': l10n.tagBellPepper,
    '🌽': l10n.tagCorn,
    '🥕': l10n.tagCarrot,
    '🫒': l10n.tagOlive,
    '🧄': l10n.tagGarlic,
    '🧅': l10n.tagOnion,
    '🥔': l10n.tagPotato,
    '🍠': l10n.tagSweetPotato,
    '🫚': l10n.tagGinger,
    '🍄‍🟫': l10n.tagShiitake,
    '🫖': l10n.tagTeapot,
    '☕️': l10n.tagCoffee,
    '🍵': l10n.tagTea,
    '🧃': l10n.tagJuice,
    '🥤': l10n.tagSoftDrink,
    '🧋': l10n.tagBubbleTea,
    '🍶': l10n.tagSake,
    '🍺': l10n.tagBeer,
    '🥂': l10n.tagChampagne,
    '🍷': l10n.tagWine,
    '🥃': l10n.tagWhiskey,
    '🍸': l10n.tagCocktail,
    '🍹': l10n.tagTropicalCocktail,
    '🧉': l10n.tagMateTea,
    '🍾': l10n.tagChampagne,
    '🍼': l10n.tagMilk,
    '🍥': l10n.tagKamaboko,
    '🍢': l10n.tagOden,
    '🧀': l10n.tagCheese,
    '🥚': l10n.tagEgg,
    '🍳': l10n.tagFriedEgg,
    '🧈': l10n.tagButter,
  };

  return foodNameMap[emoji] ?? l10n.tagOtherFood;
}

String getLocalizedCategoryName(String categoryName, BuildContext context) {
  final l10n = L10n.of(context);

  switch (categoryName) {
    case '麺類':
      return l10n.tagNoodles;
    case '肉料理':
      return l10n.tagMeatDishes;
    case '軽食系':
      return l10n.tagFastFood;
    case 'ご飯物':
      return l10n.tagRiceDishes;
    case '魚介類':
      return l10n.tagSeafood;
    case 'パン類':
      return l10n.tagBread;
    case 'おやつ':
      return l10n.tagSweetsAndSnacks;
    case 'フルーツ':
      return l10n.tagFruits;
    case '野菜類':
      return l10n.tagVegetables;
    case 'ドリンク':
      return l10n.tagBeverages;
    case 'その他':
      return l10n.tagOthers;
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
