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

  switch (emoji) {
    case '🇯🇵':
      return l10n.tagJapaneseCuisine;
    case '🇮🇹':
      return l10n.tagItalianCuisine;
    case '🇫🇷':
      return l10n.tagFrenchCuisine;
    case '🇨🇳':
      return l10n.tagChineseCuisine;
    case '🇮🇳':
      return l10n.tagIndianCuisine;
    case '🇲🇽':
      return l10n.tagMexicanCuisine;
    case '🇭🇰':
      return l10n.tagHongKongCuisine;
    case '🇺🇸':
      return l10n.tagAmericanCuisine;
    case '🇲🇹':
      return l10n.tagMediterraneanCuisine;
    case '🇹🇭':
      return l10n.tagThaiCuisine;
    case '🇬🇷':
      return l10n.tagGreekCuisine;
    case '🇹🇷':
      return l10n.tagTurkishCuisine;
    case '🇰🇷':
      return l10n.tagKoreanCuisine;
    case '🇷🇺':
      return l10n.tagRussianCuisine;
    case '🇪🇸':
      return l10n.tagSpanishCuisine;
    case '🇻🇳':
      return l10n.tagVietnameseCuisine;
    case '🇵🇹':
      return l10n.tagPortugueseCuisine;
    case '🇦🇹':
      return l10n.tagAustrianCuisine;
    case '🇧🇪':
      return l10n.tagBelgianCuisine;
    case '🇸🇪':
      return l10n.tagSwedishCuisine;
    case '🇩🇪':
      return l10n.tagGermanCuisine;
    case '🇬🇧':
      return l10n.tagBritishCuisine;
    case '🇳🇱':
      return l10n.tagDutchCuisine;
    case '🇦🇺':
      return l10n.tagAustralianCuisine;
    case '🇧🇷':
      return l10n.tagBrazilianCuisine;
    case '🇦🇷':
      return l10n.tagArgentineCuisine;
    case '🇨🇴':
      return l10n.tagColombianCuisine;
    case '🇵🇪':
      return l10n.tagPeruvianCuisine;
    case '🇳🇴':
      return l10n.tagNorwegianCuisine;
    case '🇩🇰':
      return l10n.tagDanishCuisine;
    case '🇵🇱':
      return l10n.tagPolishCuisine;
    case '🇨🇿':
      return l10n.tagCzechCuisine;
    case '🇭🇺':
      return l10n.tagHungarianCuisine;
    case '🇿🇦':
      return l10n.tagSouthAfricanCuisine;
    case '🇪🇬':
      return l10n.tagEgyptianCuisine;
    case '🇲🇦':
      return l10n.tagMoroccanCuisine;
    case '🇳🇿':
      return l10n.tagNewZealandCuisine;
    case '🇵🇭':
      return l10n.tagFilipinoCuisine;
    case '🇲🇾':
      return l10n.tagMalaysianCuisine;
    case '🇸🇬':
      return l10n.tagSingaporeanCuisine;
    case '🇮🇩':
      return l10n.tagIndonesianCuisine;
    case '🇮🇷':
      return l10n.tagIranianCuisine;
    case '🇸🇦':
      return l10n.tagSaudiArabianCuisine;
    case '🇲🇳':
      return l10n.tagMongolianCuisine;
    case '🇰🇭':
      return l10n.tagCambodianCuisine;
    case '🇱🇦':
      return l10n.tagLaotianCuisine;
    case '🇨🇺':
      return l10n.tagCubanCuisine;
    case '🇯🇲':
      return l10n.tagJamaicanCuisine;
    case '🇨🇱':
      return l10n.tagChileanCuisine;
    case '🇻🇪':
      return l10n.tagVenezuelanCuisine;
    case '🇵🇦':
      return l10n.tagPanamanianCuisine;
    case '🇧🇴':
      return l10n.tagBolivianCuisine;
    case '🇮🇸':
      return l10n.tagIcelandicCuisine;
    case '🇱🇹':
      return l10n.tagLithuanianCuisine;
    case '🇪🇪':
      return l10n.tagEstonianCuisine;
    case '🇱🇻':
      return l10n.tagLatvianCuisine;
    case '🇫🇮':
      return l10n.tagFinnishCuisine;
    case '🇭🇷':
      return l10n.tagCroatianCuisine;
    case '🇸🇮':
      return l10n.tagSlovenianCuisine;
    case '🇸🇰':
      return l10n.tagSlovakCuisine;
    case '🇷🇴':
      return l10n.tagRomanianCuisine;
    case '🇧🇬':
      return l10n.tagBulgarianCuisine;
    case '🇷🇸':
      return l10n.tagSerbianCuisine;
    case '🇦🇱':
      return l10n.tagAlbanianCuisine;
    case '🇬🇪':
      return l10n.tagGeorgianCuisine;
    case '🇦🇲':
      return l10n.tagArmenianCuisine;
    case '🇦🇿':
      return l10n.tagAzerbaijaniCuisine;
    case '🇺🇦':
      return l10n.tagUkrainianCuisine;
    case '🇧🇾':
      return l10n.tagBelarusianCuisine;
    case '🇰🇿':
      return l10n.tagKazakhCuisine;
    case '🇺🇿':
      return l10n.tagUzbekCuisine;
    case '🇰🇬':
      return l10n.tagKyrgyzCuisine;
    case '🇹🇲':
      return l10n.tagTurkmenCuisine;
    case '🇹🇯':
      return l10n.tagTajikCuisine;
    case '🇲🇻':
      return l10n.tagMaldivianCuisine;
    case '🇳🇵':
      return l10n.tagNepaleseCuisine;
    case '🇧🇩':
      return l10n.tagBangladeshiCuisine;
    case '🇲🇲':
      return l10n.tagMyanmarCuisine;
    case '🇧🇳':
      return l10n.tagBruneianCuisine;
    case '🇹🇼':
      return l10n.tagTaiwaneseCuisine;
    case '🇳🇬':
      return l10n.tagNigerianCuisine;
    case '🇰🇪':
      return l10n.tagKenyanCuisine;
    case '🇬🇭':
      return l10n.tagGhanaianCuisine;
    case '🇪🇹':
      return l10n.tagEthiopianCuisine;
    case '🇸🇩':
      return l10n.tagSudaneseCuisine;
    case '🇹🇳':
      return l10n.tagTunisianCuisine;
    case '🇦🇴':
      return l10n.tagAngolanCuisine;
    case '🇨🇩':
      return l10n.tagCongoleseCuisine;
    case '🇿🇼':
      return l10n.tagZimbabweanCuisine;
    case '🇲🇬':
      return l10n.tagMalagasyCuisine;
    case '🇵🇬':
      return l10n.tagPapuaNewGuineanCuisine;
    case '🇼🇸':
      return l10n.tagSamoanCuisine;
    case '🇹🇻':
      return l10n.tagTuvaluanCuisine;
    case '🇫🇯':
      return l10n.tagFijianCuisine;
    case '🇵🇼':
      return l10n.tagPalauanCuisine;
    case '🇰🇮':
      return l10n.tagKiribatiCuisine;
    case '🇻🇺':
      return l10n.tagVanuatuanCuisine;
    case '🇧🇭':
      return l10n.tagBahrainiCuisine;
    case '🇶🇦':
      return l10n.tagQatariCuisine;
    case '🇰🇼':
      return l10n.tagKuwaitiCuisine;
    case '🇴🇲':
      return l10n.tagOmaniCuisine;
    case '🇾🇪':
      return l10n.tagYemeniCuisine;
    case '🇱🇧':
      return l10n.tagLebaneseCuisine;
    case '🇸🇾':
      return l10n.tagSyrianCuisine;
    case '🇯🇴':
      return l10n.tagJordanianCuisine;
    default:
      return l10n.tagOtherCuisine;
  }
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

  switch (emoji) {
    case '🍝':
      return l10n.tagPasta;
    case '🍜':
      return l10n.tagRamen;
    case '🥩':
      return l10n.tagSteak;
    case '🍖':
      return l10n.tagYakiniku;
    case '🍗':
      return l10n.tagChicken;
    case '🥓':
      return l10n.tagBacon;
    case '🍔':
      return l10n.tagHamburger;
    case '🍟':
      return l10n.tagFrenchFries;
    case '🍕':
      return l10n.tagPizza;
    case '🥙':
      return l10n.tagTacos;
    case '🫔':
      return l10n.tagTamales;
    case '🥟':
      return l10n.tagGyoza;
    case '🍤':
      return l10n.tagFriedShrimp;
    case '🍲':
      return l10n.tagHotPot;
    case '🍛':
      return l10n.tagCurry;
    case '🥘':
      return l10n.tagPaella;
    case '🫕':
      return l10n.tagFondue;
    case '🍙':
      return l10n.tagOnigiri;
    case '🍚':
      return l10n.tagRice;
    case '🍱':
      return l10n.tagBento;
    case '🍣':
      return l10n.tagSushi;
    case '🐟':
      return l10n.tagFish;
    case '🐙':
      return l10n.tagOctopus;
    case '🦑':
      return l10n.tagSquid;
    case '🦐':
      return l10n.tagShrimp;
    case '🦀':
      return l10n.tagCrab;
    case '🐚':
      return l10n.tagShellfish;
    case '🦪':
      return l10n.tagOyster;
    case '🍞':
      return l10n.tagBread;
    case '🥪':
      return l10n.tagSandwich;
    case '🌭':
      return l10n.tagHotDog;
    case '🍩':
      return l10n.tagDonut;
    case '🥞':
      return l10n.tagPancake;
    case '🥐':
      return l10n.tagCroissant;
    case '🥯':
      return l10n.tagBagel;
    case '🥖':
      return l10n.tagBaguette;
    case '🥨':
      return l10n.tagPretzel;
    case '🌮':
      return l10n.tagTacos;
    case '🌯':
      return l10n.tagBurrito;
    case '🍦':
      return l10n.tagIceCream;
    case '🍮':
      return l10n.tagPudding;
    case '🍘':
      return l10n.tagRiceCracker;
    case '🍡':
      return l10n.tagDango;
    case '🍧':
      return l10n.tagShavedIce;
    case '🍨':
      return l10n.tagIceCream;
    case '🥧':
      return l10n.tagPie;
    case '🧁':
      return l10n.tagCupcake;
    case '🍰':
      return l10n.tagCake;
    case '🍭':
      return l10n.tagLollipop;
    case '🍬':
      return l10n.tagCandy;
    case '🍫':
      return l10n.tagChocolate;
    case '🍿':
      return l10n.tagPopcorn;
    case '🍪':
      return l10n.tagCookie;
    case '🥜':
      return l10n.tagPeanuts;
    case '🫘':
      return l10n.tagBeans;
    case '🌰':
      return l10n.tagChestnut;
    case '🥠':
      return l10n.tagFortuneCookie;
    case '🥮':
      return l10n.tagMooncake;
    case '🍯':
      return l10n.tagHoney;
    case '🧇':
      return l10n.tagWaffle;
    case '🍏':
      return l10n.tagApple;
    case '🍎':
      return l10n.tagApple;
    case '🍐':
      return l10n.tagPear;
    case '🍊':
      return l10n.tagOrange;
    case '🍋':
      return l10n.tagLemon;
    case '🍋‍🟩':
      return l10n.tagLime;
    case '🍌':
      return l10n.tagBanana;
    case '🍉':
      return l10n.tagWatermelon;
    case '🍇':
      return l10n.tagGrapes;
    case '🍓':
      return l10n.tagStrawberry;
    case '🫐':
      return l10n.tagBlueberry;
    case '🍈':
      return l10n.tagMelon;
    case '🍒':
      return l10n.tagCherry;
    case '🍑':
      return l10n.tagPeach;
    case '🥭':
      return l10n.tagMango;
    case '🍍':
      return l10n.tagPineapple;
    case '🥥':
      return l10n.tagCoconut;
    case '🥝':
      return l10n.tagKiwi;
    case '🥗':
      return l10n.tagSalad;
    case '🍅':
      return l10n.tagTomato;
    case '🍆':
      return l10n.tagEggplant;
    case '🥑':
      return l10n.tagAvocado;
    case '🫛':
      return l10n.tagGreenBeans;
    case '🥦':
      return l10n.tagBroccoli;
    case '🥬':
      return l10n.tagLettuce;
    case '🥒':
      return l10n.tagCucumber;
    case '🌶️':
      return l10n.tagChili;
    case '🫑':
      return l10n.tagBellPepper;
    case '🌽':
      return l10n.tagCorn;
    case '🥕':
      return l10n.tagCarrot;
    case '🫒':
      return l10n.tagOlive;
    case '🧄':
      return l10n.tagGarlic;
    case '🧅':
      return l10n.tagOnion;
    case '🥔':
      return l10n.tagPotato;
    case '🍠':
      return l10n.tagSweetPotato;
    case '🫚':
      return l10n.tagGinger;
    case '🍄‍🟫':
      return l10n.tagShiitake;
    case '🫖':
      return l10n.tagTeapot;
    case '☕️':
      return l10n.tagCoffee;
    case '🍵':
      return l10n.tagTea;
    case '🧃':
      return l10n.tagJuice;
    case '🥤':
      return l10n.tagSoftDrink;
    case '🧋':
      return l10n.tagBubbleTea;
    case '🍶':
      return l10n.tagSake;
    case '🍺':
      return l10n.tagBeer;
    case '🥂':
      return l10n.tagChampagne;
    case '🍷':
      return l10n.tagWine;
    case '🥃':
      return l10n.tagWhiskey;
    case '🍸':
      return l10n.tagCocktail;
    case '🍹':
      return l10n.tagTropicalCocktail;
    case '🧉':
      return l10n.tagMateTea;
    case '🍾':
      return l10n.tagChampagne;
    case '🍼':
      return l10n.tagMilk;
    case '🍥':
      return l10n.tagKamaboko;
    case '🍢':
      return l10n.tagOden;
    case '🧀':
      return l10n.tagCheese;
    case '🥚':
      return l10n.tagEgg;
    case '🍳':
      return l10n.tagFriedEgg;
    case '🧈':
      return l10n.tagButter;
    default:
      return l10n.tagOtherFood;
  }
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
