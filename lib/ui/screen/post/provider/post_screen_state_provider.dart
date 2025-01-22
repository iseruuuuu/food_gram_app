import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_gram_app/core/data/supabase/post/post_service.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/screen/post/post_ui_state.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_screen_state_provider.g.dart';

@riverpod
class PostScreenState extends _$PostScreenState {
  @override
  PostUiState build({
    PostUiState initState = const PostUiState(),
  }) {
    ref.onDispose(() {
      food.dispose();
      comment.dispose();
    });
    return initState;
  }

  final food = TextEditingController();
  final comment = TextEditingController();

  Loading get loading => ref.read(loadingProvider.notifier);
  final picker = ImagePicker();
  String uploadImage = '';
  late Uint8List imageBytes;

  void loadRestaurant(Restaurant? restaurant) {
    if (restaurant == null) {
      return;
    }
    state = state.copyWith(
      restaurant: restaurant.name,
      lat: restaurant.lat,
      lng: restaurant.lng,
    );
  }

  Future<bool> post({
    required String restaurantTag,
    required String foodTag,
  }) async {
    primaryFocus?.unfocus();
    loading.state = true;
    state = state.copyWith(status: 'Loading...');
    if (food.text.isNotEmpty &&
        state.restaurant != '場所を追加' &&
        uploadImage != '') {
      final result = await ref.read(postServiceProvider).post(
            foodName: food.text,
            comment: comment.text,
            uploadImage: uploadImage,
            imageBytes: imageBytes,
            restaurant: state.restaurant,
            lng: state.lng,
            lat: state.lat,
            restaurantTag: restaurantTag,
            foodTag: foodTag,
          );
      await result.when(
        success: (_) async {
          state = state.copyWith(
            status: 'Success 🎉',
            isSuccess: true,
          );
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

  Future<bool> camera() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: 960,
        maxWidth: 960,
        imageQuality: 100,
      );
      if (image == null) {
        return false;
      }
      final cropImage = await _cropImage(image);
      imageBytes = await cropImage.readAsBytes();
      uploadImage = cropImage.path;
      state = state.copyWith(
        foodImage: cropImage.path,
        status: '写真の添付が成功しました',
      );
      return true;
    } on PlatformException catch (error) {
      logger.e(error.message);
      state = state.copyWith(status: 'カメラへのアクセス許可が必要です');
      return false;
    }
  }

  Future<bool> album() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 960,
        maxWidth: 960,
        imageQuality: 100,
      );
      if (image == null) {
        return false;
      }
      final cropImage = await _cropImage(image);
      imageBytes = await cropImage.readAsBytes();
      uploadImage = cropImage.path;
      state = state.copyWith(
        foodImage: cropImage.path,
        status: '写真の添付が成功しました',
      );
      return true;
    } on PlatformException catch (error) {
      logger.e(error.message);
      state = state.copyWith(status: 'アルバムへのアクセス許可が必要です');
      return false;
    }
  }

  Future<File> _cropImage(XFile image) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          cancelButtonTitle: 'Cancel',
          doneButtonTitle: 'Done',
          hidesNavigationBar: false,
          showCancelConfirmationDialog: true,
        ),
      ],
    );
    return File(croppedFile!.path);
  }

  void getPlace(Restaurant restaurant) {
    state = state.copyWith(
      restaurant: restaurant.name,
      lat: restaurant.lat,
      lng: restaurant.lng,
    );
  }
}
