import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/screen/post/post_state.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
  final picker = ImagePicker();
  String uploadImage = '';
  late Uint8List imageBytes;

  Future<bool> post() async {
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
        'heart': 0,
        //TODO あとでレストラン名を入れる
        'restaurant': '吉野家',
        'food_image': '/$user/$uploadImage',
        //TODO　あとでレストランからの座標を入れる
        'lat': 0.1,
        //TODO　あとでレストランからの座標を入れる
        'lng': 0.1,
      };
      try {
        await supabase.storage
            .from('food')
            .uploadBinary('/$user/$uploadImage', imageBytes);
        await supabase.from('posts').insert(updates);
        state = state.copyWith(status: '投稿が完了しました');
        await Future.delayed(Duration(seconds: 2));
        return true;
      } on PostgrestException catch (error) {
        state = state.copyWith(status: error.message);
        return false;
      } finally {
        loading.state = false;
      }
    } else {
      state = state.copyWith(status: '必要な情報が入力されていません');
      return false;
    }
  }

  void onTapImage(BuildContext context) {
    primaryFocus?.unfocus();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              context.pop();
              camera();
            },
            child: const Text(
              'カメラ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              context.pop();
              album();
            },
            child: const Text(
              'アルバム',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => context.pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  Future<void> camera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) {
        return;
      }
      imageBytes = await image.readAsBytes();
      uploadImage = image.name;
      state = state.copyWith(
        foodImage: image.path,
        status: '写真の添付が成功しました',
      );
    } on PlatformException catch (e) {
      state = state.copyWith(status: e.message!);
    }
  }

  Future<void> album() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }
      imageBytes = await image.readAsBytes();
      uploadImage = image.name;
      state = state.copyWith(
        foodImage: image.path,
        status: '写真の添付が成功しました',
      );
    } on PlatformException catch (e) {
      state = state.copyWith(status: e.message!);
    }
  }

  void onTapRestaurant() {
    //TODO レストラン画面の選択の遷移を追記
  }
}