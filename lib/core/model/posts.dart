import 'package:freezed_annotation/freezed_annotation.dart';

part 'posts.freezed.dart';
part 'posts.g.dart';

@freezed
abstract class Posts with _$Posts {
  const factory Posts({
    required int id,
    required String foodImage,
    required String foodName,
    required String restaurant,
    required String comment,
    required DateTime createdAt,
    required double lat,
    required double lng,
    required String userId,
    required int heart,
    @JsonKey(defaultValue: 0.0) required double star,
    required String foodTag,
    required bool isAnonymous,
  }) = _Posts;

  factory Posts.fromJson(Map<String, dynamic> json) => _$PostsFromJson(json);
}

extension PostsExtension on Posts {
  /// カンマ区切りのfoodImageから画像パスのリストを取得
  List<String> get foodImageList {
    if (foodImage.isEmpty) {
      return [];
    }
    return foodImage.split(',').where((path) => path.isNotEmpty).toList();
  }

  /// 最初の画像パスを取得
  String get firstFoodImage {
    final images = foodImageList;
    return images.isNotEmpty ? images.first : '';
  }
}
