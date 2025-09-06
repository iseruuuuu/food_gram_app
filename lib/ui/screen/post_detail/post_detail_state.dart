import 'package:food_gram_app/core/model/posts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_detail_state.freezed.dart';

@freezed
abstract class PostDetailState with _$PostDetailState {
  const factory PostDetailState({
    @Default('') String status,
    @Default(0) int heart,
    @Default(false) bool isSuccess,
    @Default(false) bool isLoading,
    @Default(false) bool isStore,
    @Default(false) bool isHeart,
    @Default(false) bool isAppearHeart,
    @Default([]) List<String> heartList,
  }) = _PostDetailState;
}

@freezed
abstract class PostState with _$PostState {
  const factory PostState.loading() = PostStateLoading;

  const factory PostState.data({
    required Posts posts,
  }) = _PostStateData;

  const factory PostState.error() = PostStateError;
}
