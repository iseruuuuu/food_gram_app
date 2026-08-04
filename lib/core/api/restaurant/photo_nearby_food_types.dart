import 'package:food_gram_app/gen/strings.g.dart';

/// Google Places Nearby Search で拾う飲食系の type 一覧。
const photoNearbyFoodPlaceTypes = [
  'restaurant',
  'fast_food_restaurant',
  'japanese_restaurant',
  'cafe',
  'bakery',
  'meal_takeaway',
  'meal_delivery',
  'food_court',
  'ramen_restaurant',
  'hamburger_restaurant',
];

/// Text Search フォールバック用クエリ（端末ロケール向け）。
List<String> photoNearbyTextSearchQueries([AppLocale? locale]) {
  final current = locale ?? LocaleSettings.currentLocale;
  return switch (current) {
    AppLocale.ja => const ['飲食店', 'レストラン', 'ファストフード'],
    AppLocale.ko => const ['음식점', '레스토랑', '패스트푸드'],
    AppLocale.zh => const ['餐厅', '饭店', '快餐'],
    AppLocale.zhTw => const ['餐廳', '餐館', '速食'],
    AppLocale.th => const ['ร้านอาหาร', 'ร้านกาแฟ', 'ฟาสต์ฟู้ด'],
    AppLocale.vi => const ['nhà hàng', 'quán ăn', 'đồ ăn nhanh'],
    AppLocale.de => const ['Restaurant', 'Café', 'Fast Food'],
    AppLocale.es => const ['restaurante', 'café', 'comida rápida'],
    AppLocale.fr => const ['restaurant', 'café', 'fast-food'],
    AppLocale.pt => const ['restaurante', 'café', 'fast food'],
    AppLocale.en => const ['restaurant', 'cafe', 'fast food'],
  };
}
