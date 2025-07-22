// 国の絵文字と料理名を紐付けるマップ
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';

// 元のマップ（既存のロジック用）
final Map<String, String> countryCategory = {
  '🇯🇵': '日本料理',
  '🇮🇹': 'イタリアン料理',
  '🇫🇷': 'フレンチ料理',
  '🇨🇳': '中華料理',
  '🇮🇳': 'インド料理',
  '🇲🇽': 'メキシカン料理',
  '🇭🇰': '香港料理',
  '🇺🇸': 'アメリカ料理',
  '🇲🇹': '地中海料理',
  '🇹🇭': 'タイ料理',
  '🇬🇷': 'ギリシャ料理',
  '🇹🇷': 'トルコ料理',
  '🇰🇷': '韓国料理',
  '🇷🇺': 'ロシア料理',
  '🇪🇸': 'スペイン料理',
  '🇻🇳': 'ベトナム料理',
  '🇵🇹': 'ポルトガル料理',
  '🇦🇹': 'オーストリア料理',
  '🇧🇪': 'ベルギー料理',
  '🇸🇪': 'スウェーデン料理',
  '🇩🇪': 'ドイツ料理',
  '🇬🇧': 'イギリス料理',
  '🇳🇱': 'オランダ料理',
  '🇦🇺': 'オーストラリア料理',
  '🇧🇷': 'ブラジル料理',
  '🇦🇷': 'アルゼンチン料理',
  '🇨🇴': 'コロンビア料理',
  '🇵🇪': 'ペルー料理',
  '🇳🇴': 'ノルウェー料理',
  '🇩🇰': 'デンマーク料理',
  '🇵🇱': 'ポーランド料理',
  '🇨🇿': 'チェコ料理',
  '🇭🇺': 'ハンガリー料理',
  '🇿🇦': '南アフリカ料理',
  '🇪🇬': 'エジプト料理',
  '🇲🇦': 'モロッコ料理',
  '🇳🇿': 'ニュージーランド料理',
  '🇵🇭': 'フィリピン料理',
  '🇲🇾': 'マレーシア料理',
  '🇸🇬': 'シンガポール料理',
  '🇮🇩': 'インドネシア料理',
  '🇮🇷': 'イラン料理',
  '🇸🇦': 'サウジアラビア料理',
  '🇲🇳': 'モンゴル料理',
  '🇰🇭': 'カンボジア料理',
  '🇱🇦': 'ラオス料理',
  '🇨🇺': 'キューバ料理',
  '🇯🇲': 'ジャマイカ料理',
  '🇨🇱': 'チリ料理',
  '🇻🇪': 'ベネズエラ料理',
  '🇵🇦': 'パナマ料理',
  '🇧🇴': 'ボリビア料理',
  '🇮🇸': 'アイスランド料理',
  '🇱🇹': 'リトアニア料理',
  '🇪🇪': 'エストニア料理',
  '🇱🇻': 'ラトビア料理',
  '🇫🇮': 'フィンランド料理',
  '🇭🇷': 'クロアチア料理',
  '🇸🇮': 'スロベニア料理',
  '🇸🇰': 'スロバキア料理',
  '🇷🇴': 'ルーマニア料理',
  '🇧🇬': 'ブルガリア料理',
  '🇷🇸': 'セルビア料理',
  '🇦🇱': 'アルバニア料理',
  '🇬🇪': 'ジョージア料理',
  '🇦🇲': 'アルメニア料理',
  '🇦🇿': 'アゼルバイジャン料理',
  '🇺🇦': 'ウクライナ料理',
  '🇧🇾': 'ベラルーシ料理',
  '🇰🇿': 'カザフスタン料理',
  '🇺🇿': 'ウズベキスタン料理',
  '🇰🇬': 'キルギス料理',
  '🇹🇲': 'トルクメニスタン料理',
  '🇹🇯': 'タジキスタン料理',
  '🇲🇻': 'モルディブ料理',
  '🇳🇵': 'ネパール料理',
  '🇧🇩': 'バングラデシュ料理',
  '🇲🇲': 'ミャンマー料理',
  '🇧🇳': 'ブルネイ料理',
  '🇹🇼': '台湾料理',
  '🇳🇬': 'ナイジェリア料理',
  '🇰🇪': 'ケニア料理',
  '🇬🇭': 'ガーナ料理',
  '🇪🇹': 'エチオピア料理',
  '🇸🇩': 'スーダン料理',
  '🇹🇳': 'チュニジア料理',
  '🇦🇴': 'アンゴラ料理',
  '🇨🇩': 'コンゴ料理',
  '🇿🇼': 'ジンバブエ料理',
  '🇲🇬': 'マダガスカル料理',
  '🇵🇬': 'パプアニューギニア料理',
  '🇼🇸': 'サモア料理',
  '🇹🇻': 'ツバル料理',
  '🇫🇯': 'フィジー料理',
  '🇵🇼': 'パラオ料理',
  '🇰🇮': 'キリバス料理',
  '🇻🇺': 'バヌアツ料理',
  '🇧🇭': 'バーレーン料理',
  '🇶🇦': 'カタール料理',
  '🇰🇼': 'クウェート料理',
  '🇴🇲': 'オマーン料理',
  '🇾🇪': 'イエメン料理',
  '🇱🇧': 'レバノン料理',
  '🇸🇾': 'シリア料理',
  '🇯🇴': 'ヨルダン料理',
};

/// 国の絵文字から料理名を取得する関数（既存ロジック用）
String getCountryName(String emoji) {
  return countryCategory[emoji] ?? 'その他の料理';
}

/// 国の絵文字から料理名を取得する関数（多言語表示用）
String getLocalizedCountryName(String emoji, BuildContext context) {
  final l10n = L10n.of(context);

  // マップベースのアプローチに変更
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

/// 食べ物のカテゴリーと絵文字、食べ物名の対応（既存ロジック用）
final Map<String, List<List<String>>> foodCategory = {
  '麺類': [
    ['🍝', 'パスタ'],
    ['🍜', 'ラーメン'],
  ],
  '肉料理': [
    ['🥩', 'ステーキ'],
    ['🍖', '焼き肉'],
    ['🍗', 'チキン'],
    ['🥓', 'ベーコン'],
  ],
  '軽食系': [
    ['🍔', 'ハンバーガー'],
    ['🍟', 'フライドポテト'],
    ['🍕', 'ピザ'],
    ['🥙', 'タコス'],
    ['🫔', 'タマル'],
    ['🥟', '餃子'],
    ['🍤', 'エビフライ'],
  ],
  'ご飯物': [
    ['🍲', '鍋'],
    ['🍛', 'カレー'],
    ['🥘', 'パエリア'],
    ['🫕', 'フォンデュ'],
    ['🍙', 'おにぎり'],
    ['🍚', 'ご飯'],
    ['🍱', '弁当'],
  ],
  '魚介類': [
    ['🍣', '寿司'],
    ['🐟', '魚'],
    ['🐙', 'タコ'],
    ['🦑', 'イカ'],
    ['🦐', 'エビ'],
    ['🦀', 'カニ'],
    ['🐚', '貝'],
    ['🦪', 'カキ'],
  ],
  'パン類': [
    ['🍞', 'パン'],
    ['🥪', 'サンドイッチ'],
    ['🌭', 'ホットドッグ'],
    ['🍩', 'ドーナツ'],
    ['🥞', 'パンケーキ'],
    ['🥐', 'クロワッサン'],
    ['🥯', 'ベーグル'],
    ['🥖', 'バゲット'],
    ['🥨', 'プレッツェル'],
    ['🌮', 'タコス'],
    ['🌯', 'ブリトー'],
  ],
  'おやつ': [
    ['🍦', 'アイスクリーム'],
    ['🍮', 'プリン'],
    ['🍘', 'せんべい'],
    ['🍡', '団子'],
    ['🍧', 'かき氷'],
    ['🍨', 'アイスクリーム'],
    ['🥧', 'パイ'],
    ['🧁', 'カップケーキ'],
    ['🍰', 'ケーキ'],
    ['🍭', 'キャンディ'],
    ['🍬', '飴'],
    ['🍫', 'チョコレート'],
    ['🍿', 'ポップコーン'],
    ['🍪', 'クッキー'],
    ['🥜', 'ピーナッツ'],
    ['🫘', '豆'],
    ['🌰', '栗'],
    ['🥠', 'フォーチュンクッキー'],
    ['🥮', '月餅'],
    ['🍯', 'はちみつ'],
    ['🧇', 'ワッフル'],
  ],
  'フルーツ': [
    ['🍏', 'りんご'],
    ['🍎', 'りんご'],
    ['🍐', '梨'],
    ['🍊', 'みかん'],
    ['🍋', 'レモン'],
    ['🍋‍🟩', 'ライム'],
    ['🍌', 'バナナ'],
    ['🍉', 'スイカ'],
    ['🍇', 'ぶどう'],
    ['🍓', 'いちご'],
    ['🫐', 'ブルーベリー'],
    ['🍈', 'メロン'],
    ['🍒', 'さくらんぼ'],
    ['🍑', 'もも'],
    ['🥭', 'マンゴー'],
    ['🍍', 'パイナップル'],
    ['🥥', 'ココナッツ'],
    ['🥝', 'キウイ'],
  ],
  '野菜類': [
    ['🥗', 'サラダ'],
    ['🍅', 'トマト'],
    ['🍆', 'なす'],
    ['🥑', 'アボカド'],
    ['🫛', 'さやいんげん'],
    ['🥦', 'ブロッコリー'],
    ['🥬', 'レタス'],
    ['🥒', 'きゅうり'],
    ['🌶️', '唐辛子'],
    ['🫑', 'ピーマン'],
    ['🌽', 'とうもろこし'],
    ['🥕', 'にんじん'],
    ['🫒', 'オリーブ'],
    ['🧄', 'にんにく'],
    ['🧅', '玉ねぎ'],
    ['🥔', 'じゃがいも'],
    ['🍠', 'さつまいも'],
    ['🫚', 'しょうが'],
    ['🍄‍🟫', 'しいたけ'],
  ],
  'ドリンク': [
    ['🫖', 'ティーポット'],
    ['☕️', 'コーヒー'],
    ['🍵', 'お茶'],
    ['🧃', 'ジュース'],
    ['🥤', 'ソフトドリンク'],
    ['🧋', 'タピオカティー'],
    ['🍶', '日本酒'],
    ['🍺', 'ビール'],
    ['🥂', 'シャンパン'],
    ['🍷', 'ワイン'],
    ['🥃', 'ウィスキー'],
    ['🍸', 'カクテル'],
    ['🍹', 'トロピカルカクテル'],
    ['🧉', 'マテ茶'],
    ['🍾', 'シャンパン'],
    ['🍼', 'ミルク'],
  ],
  'その他': [
    ['🍥', 'かまぼこ'],
    ['🍢', 'おでん'],
    ['🧀', 'チーズ'],
    ['🥚', '卵'],
    ['🍳', '目玉焼き'],
    ['🧈', 'バター'],
  ],
};

/// 食べ物の絵文字から食べ物名を取得する関数（既存ロジック用）
String getFoodName(String emoji) {
  for (final category in foodCategory.values) {
    for (final food in category) {
      if (food[0] == emoji) {
        return food[1];
      }
    }
  }
  return 'その他の食べ物';
}

/// 食べ物の絵文字から食べ物名を取得する関数（多言語表示用）
String getLocalizedFoodName(String emoji, BuildContext context) {
  final l10n = L10n.of(context);

  // マップベースのアプローチに変更
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

/// カテゴリー名を多言語化する関数
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

/// カテゴリーを表すレコード型
typedef CategoryData = ({String name, String displayIcon, bool isAllCategory});

/// 国の絵文字からアイコンと料理名の両方を取得する関数（既存ロジック用）
({String emoji, String name}) getCountryTagData(String emoji) {
  final name = countryCategory[emoji] ?? '';
  return (emoji: emoji, name: name);
}

/// 食べ物の絵文字からアイコンと食べ物名の両方を取得する関数（既存ロジック用）
({String emoji, String name}) getFoodTagData(String emoji) {
  for (final category in foodCategory.values) {
    for (final food in category) {
      if (food[0] == emoji) {
        return (emoji: emoji, name: food[1]);
      }
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
        displayIcon: foodEmojis.isNotEmpty && foodEmojis[0].isNotEmpty
            ? foodEmojis[0][0]
            : '🍽️',
        isAllCategory: false
      ),
    );
  });
  return result;
});
