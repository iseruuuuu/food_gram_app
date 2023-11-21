import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_gram_app/provider/loading.dart';
import 'package:food_gram_app/screen/post/post_state.dart';
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
  final supabase = Supabase.instance.client;
  final picker = ImagePicker();
  String uploadImage = '';
  late Uint8List imageBytes;

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

  void onTapImage(BuildContext context) {
    primaryFocus?.unfocus();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
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
              Navigator.pop(context);
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
            onPressed: () => Navigator.pop(context),
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
