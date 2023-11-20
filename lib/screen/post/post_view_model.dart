import 'package:flutter/cupertino.dart';
import 'package:food_gram_app/provider/loading.dart';
import 'package:food_gram_app/screen/post/post_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'post_view_model.g.dart';

@riverpod
class PostViewModel extends _$PostViewModel {
  @override
  PostState build({
    PostState initState = const PostState(),
  }) {
    ref.onDispose(() {
      foodTextController.dispose();
      commentTextController.dispose();
    });
    return initState;
  }

  final foodTextController = TextEditingController();
  final commentTextController = TextEditingController();

  Loading get loading => ref.read(loadingProvider.notifier);
  final supabase = Supabase.instance.client;

  Future<void> post(BuildContext context) async {
    if (foodTextController.text.isNotEmpty &&
        commentTextController.text.isNotEmpty) {
      primaryFocus?.unfocus();
      loading.state = true;
      final user = supabase.auth.currentUser?.id;
      final updates = {
        'user_id': user,
        'food_name': foodTextController.text,
        'comment': commentTextController.text,
        'created_at': DateTime.now().toIso8601String(),
        //TODO あとでレストラン名を入れる
        'restaurant': '吉野家',
        //TODO あとで画像を入れる
        'food_image': 'assets/icon/icon2.png',
        //TODO　あとでレストランからの座標を入れる
        'lat': 0.1,
        //TODO　あとでレストランからの座標を入れる
        'lng': 0.1,
      };
      try {
        await supabase.from('posts').insert(updates);
        state = state.copyWith(status: '投稿が完了しました');
        await Future.delayed(Duration(seconds: 2));
        Navigator.pop(context);
      } on PostgrestException catch (error) {
        state = state.copyWith(status: error.message);
        print(error);
      } finally {
        loading.state = false;
      }
    } else {
      state = state.copyWith(status: '必要な情報が入力されていません');
    }
  }

  void onTapImage() {
    //TODO 画像の添付を追記
  }

  void onTapRestaurant() {
    //TODO レストラン画面の選択の遷移を追記
  }
}
