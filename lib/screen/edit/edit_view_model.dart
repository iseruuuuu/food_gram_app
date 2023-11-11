import 'package:flutter/cupertino.dart';
import 'package:food_gram_app/screen/edit/edit_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_view_model.g.dart';

@riverpod
class EditViewModel extends _$EditViewModel {
  @override
  EditState build({
    EditState initState = const EditState(),
  }) {
    return initState;
  }

  //TODO データの初期値を入れる
  final nameTextController = TextEditingController();
  final idTextController = TextEditingController();
  final selfIntroduceTextController = TextEditingController();

  void update() {
    //TODO 投稿の処理を追記
  }

  void onTapImage() {
    //TODO 画像の添付を追記
  }
}
