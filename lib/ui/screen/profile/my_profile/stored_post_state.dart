import 'package:food_gram_app/core/model/posts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stored_post_state.freezed.dart';

@freezed
class StoredPostState with _$StoredPostState {
  const factory StoredPostState.loading() = StoredPostStateLoading;
  const factory StoredPostState.data({
    required List<Posts> posts,
  }) = StoredPostStateData;
  const factory StoredPostState.error() = StoredPostStateError;
}
