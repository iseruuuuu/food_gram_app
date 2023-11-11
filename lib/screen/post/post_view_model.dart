import 'package:flutter/cupertino.dart';
import 'package:food_gram_app/screen/post/post_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_view_model.g.dart';

@riverpod
class PostViewModel extends _$PostViewModel {
  @override
  PostState build({
    PostState initState = const PostState(),
  }) {
    return initState;
  }

  final foodTextController = TextEditingController();
  final commentTextController = TextEditingController();

  void post() {
    //TODO 投稿の処理を追記
  }

  void onTapImage() {
    //TODO 画像の添付を追記
  }

  void onTapRestaurant() {
    //TODO レストラン画面の選択の遷移を追記
  }
}
