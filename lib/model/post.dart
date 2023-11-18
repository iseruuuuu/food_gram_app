import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';

part 'post.g.dart';

@freezed
abstract class Post with _$Post {
  const factory Post({
    required int id,
    required String foodImage,
    required String foodName,
    required String restaurant,
    required String comment,
    required DateTime eatTime,
    required DateTime createdAt,
    required double lat,
    required double lng,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
