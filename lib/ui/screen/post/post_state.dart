import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_state.freezed.dart';

@freezed
class PostState with _$PostState {
  const factory PostState({
    @Default('') String foodImage,
    @Default('場所を追加') String restaurant,
    @Default('') String status,
    @Default(false) bool isSuccess,
    @Default(0.0) double lat,
    @Default(0.0) double lng,
  }) = _PostState;
}
