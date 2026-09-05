import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/gen/strings.g.dart';

/// 店舗名の表示用。番兵の「不明」は機械翻訳せず、各言語の文言に置き換える。
String localizedRestaurantName(String name, Translations t) {
  if (isUnknownRestaurantName(name)) {
    return t.post.unknownRestaurant;
  }
  return name;
}

extension PostsRestaurantDisplay on Posts {
  String localizedRestaurant(Translations t) =>
      localizedRestaurantName(restaurant, t);

  String localizedDisplayTitle(Translations t) {
    if (hasFoodName) {
      return foodName.trim();
    }
    return localizedRestaurant(t);
  }
}
