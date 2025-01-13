import 'package:freezed_annotation/freezed_annotation.dart';

part 'detail_post_state.freezed.dart';

@freezed
abstract class DetailPostState with _$DetailPostState {
  const factory DetailPostState({
    @Default('') String status,
    @Default(0) heart,
    @Default(false) isSuccess,
  }) = _DetailPostState;
}
