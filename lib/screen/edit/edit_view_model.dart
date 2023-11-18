import 'package:flutter/cupertino.dart';
import 'package:food_gram_app/screen/edit/edit_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_view_model.g.dart';

@riverpod
class EditViewModel extends _$EditViewModel {
  @override
  EditState build({
    //TODO ユーザーのデータを初期値に入れる
    EditState initState = const EditState(),
  }) {
    return initState;
  }

  final nameTextController = TextEditingController();
  final idTextController = TextEditingController();
  final selfIntroduceTextController = TextEditingController();

  void update() {
    //TODO 投稿の処理を追記
  }

  void selectIcon(int number) {
    state = state.copyWith(number: number);
  }
}
