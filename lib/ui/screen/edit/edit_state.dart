import 'package:food_gram_app/core/model/users.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_state.freezed.dart';

@freezed
class EditState with _$EditState {
  const factory EditState({
    @Default('') String status,
    @Default(1) int number,
    @Default('') String uploadImage,
    @Default('') String initialImage,
    @Default(false) bool isSelectedIcon,
    @Default('') String favoriteTags,
    @Default(false) bool isSubscribe,
    Users? user,
  }) = _EditState;
}
