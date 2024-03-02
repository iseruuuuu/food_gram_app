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
  }) = _Posts;

  factory Posts.fromJson(Map<String, dynamic> json) => _$PostsFromJson(json);
}
