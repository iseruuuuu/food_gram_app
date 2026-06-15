import 'package:food_gram_app/core/model/restaurant.dart';

/// 写真の撮影位置から提案するレストラン候補
class PhotoRestaurantCandidate {
  const PhotoRestaurantCandidate({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.distanceMeters,
    required this.source,
    this.rating,
    this.isOpenNow,
    this.hint,
  });

  final String name;
  final String address;
  final double lat;
  final double lng;
  final double distanceMeters;
  final PhotoRestaurantSource source;
  final double? rating;
  final bool? isOpenNow;
  final String? hint;

  Restaurant toRestaurant() => Restaurant(
        name: name,
        address: address,
        lat: lat,
        lng: lng,
      );
}

enum PhotoRestaurantSource {
  /// FoodGram の既存投稿から
  community,

  /// Google Places Nearby Search
  google,
}
