import 'package:food_gram_app/core/model/posts.dart';

/// 近隣モーダル用：レストラン名単位にまとめたグループ
class RestaurantGroup {
  const RestaurantGroup({
    required this.name,
    required this.lat,
    required this.lng,
    required this.posts,
  });

  final String name;
  final double lat;
  final double lng;
  final List<Posts> posts;
}

/// モーダル内の表示切替で使用する選択状態モデル
class MapModalSelection {
  MapModalSelection({
    required this.name,
    required this.lat,
    required this.lng,
  });
  final String name;
  final double lat;
  final double lng;
}
