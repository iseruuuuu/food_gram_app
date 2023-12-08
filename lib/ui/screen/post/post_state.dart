import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_state.freezed.dart';

@freezed
class PostState with _$PostState {
  const factory PostState({
    @Default('') String foodImage,
    @Default('レストランを選択') String restaurant,
    @Default('') String status,
    @Default(false) isSuccess,
  }) = _PostState;
}
