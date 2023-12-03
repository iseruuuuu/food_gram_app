import 'package:freezed_annotation/freezed_annotation.dart';

part 'detail_post_state.freezed.dart';

part 'detail_post_state.g.dart';

@freezed
abstract class DetailPostState with _$DetailPostState {
  const factory DetailPostState({
    @Default('') String status,
    @Default(0) heart,
  }) = _DetailPostState;

  factory DetailPostState.fromJson(Map<String, dynamic> json) =>
      _$DetailPostStateFromJson(json);
}
