import 'package:food_gram_app/core/model/posts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_post_state.freezed.dart';

@freezed
class EditPostState with _$EditPostState {
  const factory EditPostState({
    @Default('') String status,
    @Default(false) bool isSuccess,
    @Default('') String foodImage,
    @Default('') String restaurant,
    @Default(0.0) double lat,
    @Default(0.0) double lng,
    @Default(false) bool isAnonymous,
    Posts? posts,
  }) = _EditPostState;
}
