import 'dart:convert';

/// 投稿画面の下書き（写真パス・バイナリは含まない）
class PostDraft {
  const PostDraft({
    required this.foodName,
    required this.comment,
    required this.priceInput,
    required this.restaurant,
    required this.lat,
    required this.lng,
    required this.foodTags,
    required this.star,
    required this.isAnonymous,
    required this.priceCurrency,
  });

  final String foodName;
  final String comment;
  final String priceInput;
  final String restaurant;
  final double lat;
  final double lng;
  final List<String> foodTags;
  final double star;
  final bool isAnonymous;
  final String priceCurrency;

  static const _version = 1;

  bool get hasRestorableContent {
    final hasText = foodName.isNotEmpty ||
        comment.isNotEmpty ||
        priceInput.isNotEmpty ||
        foodTags.isNotEmpty;
    final hasPlace = restaurant.isNotEmpty && restaurant != '場所を追加';
    final hasGeo = lat != 0 || lng != 0;
    return hasText ||
        hasPlace ||
        hasGeo ||
        star > 0 ||
        isAnonymous;
  }

  Map<String, dynamic> toJson() => {
        'v': _version,
        'foodName': foodName,
        'comment': comment,
        'priceInput': priceInput,
        'restaurant': restaurant,
        'lat': lat,
        'lng': lng,
        'foodTags': foodTags,
        'star': star,
        'isAnonymous': isAnonymous,
        'priceCurrency': priceCurrency,
      };

  static PostDraft? fromJsonString(String raw) {
    if (raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (decoded['v'] is! int) {
        return null;
      }
      final tags = decoded['foodTags'];
      return PostDraft(
        foodName: decoded['foodName'] as String? ?? '',
        comment: decoded['comment'] as String? ?? '',
        priceInput: decoded['priceInput'] as String? ?? '',
        restaurant: decoded['restaurant'] as String? ?? '場所を追加',
        lat: (decoded['lat'] as num?)?.toDouble() ?? 0,
        lng: (decoded['lng'] as num?)?.toDouble() ?? 0,
        foodTags: tags is List
            ? tags.map((e) => e.toString()).toList()
            : const <String>[],
        star: (decoded['star'] as num?)?.toDouble() ?? 0,
        isAnonymous: decoded['isAnonymous'] as bool? ?? false,
        priceCurrency: decoded['priceCurrency'] as String? ?? '',
      );
    } on Object {
      return null;
    }
  }

  String toJsonString() => jsonEncode(toJson());
}
