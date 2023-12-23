import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/model/restaurant.dart';
import 'package:food_gram_app/service/database_service.dart';
import 'package:food_gram_app/ui/screen/post/post_state.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    primaryFocus?.unfocus();
    loading.state = true;
    state = state.copyWith(status: 'Loading...');
    if (foodTextController.text.isNotEmpty &&
        state.restaurant != '食べた場所' &&
        uploadImage != '') {
      final result = await ref.read(databaseServiceProvider).post(
            foodName: foodTextController.text,
            comment: commentTextController.text,
            uploadImage: uploadImage,
            imageBytes: imageBytes,
            restaurant: state.restaurant,
            lng: state.lng,
            lat: state.lat,
          );
      await result.when(
        success: (_) async {
          state = state.copyWith(
            status: 'Success 🎉',
            isSuccess: true,
          );
          await Future.delayed(Duration(seconds: 2));
        },
        failure: (error) {
          state = state.copyWith(
            status: 'エラーが発生しました',
            isSuccess: false,
          );
        },
      );
      loading.state = false;
      return state.isSuccess;
    } else {
      loading.state = false;
      state = state.copyWith(status: '必要な情報が入力されていません');
      return false;
    }
  }

  Future<void> camera() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: 960,
        maxWidth: 960,
        imageQuality: 100,
      );
      if (image == null) {
        return;
      }
      imageBytes = await image.readAsBytes();
      uploadImage = image.name;
      state = state.copyWith(
        foodImage: image.path,
      );
    } on PlatformException catch (error) {
      logger.e(error.message);
      state = state.copyWith(status: error.message!);
    }
  }

  Future<void> album() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 960,
        maxWidth: 960,
        imageQuality: 100,
      );
      if (image == null) {
        return;
      }
      imageBytes = await image.readAsBytes();
      uploadImage = image.name;
      state = state.copyWith(
        foodImage: image.path,
        status: '写真の添付が成功しました',
      );
    } on PlatformException catch (error) {
      logger.e(error.message);
      state = state.copyWith(status: error.message!);
    }
  }

  void getPlace(Restaurant restaurant) {
    state = state.copyWith(
      restaurant: restaurant.restaurant,
      lat: restaurant.lat,
      lng: restaurant.lng,
    );
  }
}
