/// Google Places Nearby Search で拾う飲食系の type 一覧。
///
/// 吉野家などのチェーン店は primary type が [fast_food_restaurant] のため必須。
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

/// Text Search フォールバック用クエリ（日本向け）
const photoNearbyTextSearchQueries = [
  '飲食店',
  'レストラン',
  'ファストフード',
];
