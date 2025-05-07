import 'package:food_gram_app/core/model/posts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'detail_post_state.freezed.dart';

@freezed
abstract class DetailPostState with _$DetailPostState {
  const factory DetailPostState({
    @Default('') String status,
    @Default(0) int heart,
    @Default(false) bool isSuccess,
    @Default(false) bool isLoading,
  }) = _DetailPostState;
}

@freezed
abstract class PostState with _$PostState {
  const factory PostState.loading() = PostStateLoading;

  const factory PostState.data({
    required Posts posts,
  }) = _PostStateData;

  const factory PostState.error() = PostStateError;
}
