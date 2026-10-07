import 'package:food_gram_app/core/model/posts.dart';

/// ピン用の投稿データ整理（重複排除・imageType 収集）
class MapPinData {
  MapPinData._();

  /// 自分の投稿ピン画像のキャッシュキー接頭辞
  static const ownImageTypePrefix = 'own:';

  static String _latLngKey(double lat, double lng, {int fractionDigits = 6}) {
    final latStr = lat.toStringAsFixed(fractionDigits);
    final lngStr = lng.toStringAsFixed(fractionDigits);
    return '$latStr,$lngStr';
  }

  static String latLngKey(double lat, double lng) => _latLngKey(lat, lng);

  static String ownImageType(String imageType) =>
      '$ownImageTypePrefix$imageType';

  /// 自分の投稿がある座標。同一地点に他人の投稿があってもオレンジにする。
  static Set<String> ownLatLngKeys(List<Posts> posts, String? userId) {
    if (userId == null || userId.isEmpty) {
      return const {};
    }
    final keys = <String>{};
    for (final post in posts) {
      if (post.userId == userId) {
        keys.add(_latLngKey(post.lat, post.lng));
      }
    }
    return keys;
  }

  static bool isOwnLocation(Posts post, Set<String> ownKeys) {
    return ownKeys.contains(_latLngKey(post.lat, post.lng));
  }

  /// 自分の地点ならオレンジ用キー、なければ共有ピンのキー。
  static String? iconImageFor(
    Posts post,
    Map<String, String> imageKeys,
    Set<String> ownKeys,
  ) {
    final type = imageTypeFor(post);
    if (isOwnLocation(post, ownKeys)) {
      return imageKeys[ownImageType(type)] ?? imageKeys[type];
    }
    return imageKeys[type];
  }

  /// 同一座標の投稿を1つにまとめる（代表は非空の foodTag を優先）
  static List<Posts> dedupeByLatLng(List<Posts> posts) {
    final deduped = <String, Posts>{};
    for (final post in posts) {
      final key = _latLngKey(post.lat, post.lng);
      final existing = deduped[key];
      if (existing == null) {
        deduped[key] = post;
      } else {
        final existingHasTag = existing.foodTag.isNotEmpty;
        final currentHasTag = post.foodTag.isNotEmpty;
        if (!existingHasTag && currentHasTag) {
          deduped[key] = post;
        }
      }
    }
    return deduped.values.toList();
  }

  /// 投稿リストからピン用 imageType の集合を取得
  static Set<String> collectImageTypes(List<Posts> posts) {
    final types = <String>{};
    for (final post in posts) {
      types.add(
        post.foodTag.isEmpty ? 'default' : post.foodTag.split(',').first.trim(),
      );
    }
    return types;
  }

  static String imageTypeFor(Posts post) {
    return post.foodTag.isEmpty
        ? 'default'
        : post.foodTag.split(',').first.trim();
  }
}
