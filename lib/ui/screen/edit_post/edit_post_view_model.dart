import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/supabase/post/services/post_service.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/ui/screen/edit_post/edit_post_state.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_post_view_model.g.dart';

@riverpod
class EditPostViewModel extends _$EditPostViewModel {
  final logger = Logger();

  // 画像設定の定数
  static const _imageConfig = (
    maxSize: 960.0,
    quality: 100,
  );

  // UI設定
  final _androidSettings = AndroidUiSettings(
    toolbarColor: Colors.blue,
    toolbarWidgetColor: Colors.white,
    initAspectRatio: CropAspectRatioPreset.original,
    lockAspectRatio: false,
    hideBottomControls: false,
  );

  final _iosSettings = IOSUiSettings(
    cancelButtonTitle: 'Cancel',
    doneButtonTitle: 'Done',
    hidesNavigationBar: false,
    showCancelConfirmationDialog: true,
  );

  // コントローラーとプロパティ
  final _foodController = TextEditingController();
  final _commentController = TextEditingController();
  final _picker = ImagePicker();
  String _uploadImage = '';
  Uint8List? _imageBytes;
  late Posts _posts;

  TextEditingController get foodController => _foodController;

  TextEditingController get commentController => _commentController;

  Loading get loading => ref.read(loadingProvider.notifier);

  String get uploadImage => _uploadImage;

  Uint8List? get imageBytes => _imageBytes;

  @override
  EditPostState build({EditPostState? initState}) {
    ref.onDispose(() {
      _foodController.dispose();
      _commentController.dispose();
    });
    return initState ?? const EditPostState();
  }

  void initializeWithPosts(Posts posts) {
    _posts = posts;
    _foodController.text = posts.foodName;
    _commentController.text = posts.comment;
    state = state.copyWith(
      restaurant: posts.restaurant,
      lat: posts.lat,
      lng: posts.lng,
    );
  }

  Future<bool> update({
    required String restaurantTag,
    required String foodTag,
  }) async {
    primaryFocus?.unfocus();
    loading.state = true;
    state = state.copyWith(status: EditStatus.loading.name);
    if (_foodController.text.isEmpty) {
      loading.state = false;
      state = state.copyWith(status: EditStatus.missingInfo.name);
      return false;
    }
    try {
      await _updatePost(restaurantTag, foodTag);
      return state.isSuccess;
    } finally {
      loading.state = false;
    }
  }

  Future<bool> camera() async {
    return _pickImage(
      ImageSource.camera,
      EditStatus.cameraPermission.name,
    );
  }

  Future<bool> album() async {
    return _pickImage(
      ImageSource.gallery,
      EditStatus.albumPermission.name,
    );
  }

  Future<void> _updatePost(String restaurantTag, String foodTag) async {
    final result = await ref.read(postServiceProvider.notifier).updatePost(
          posts: _posts,
          foodName: _foodController.text,
          comment: _commentController.text,
          restaurant: state.restaurant,
          restaurantTag: restaurantTag,
          foodTag: foodTag,
          lat: state.lat,
          lng: state.lng,
          newImagePath: state.foodImage.isNotEmpty ? _uploadImage : null,
          imageBytes: state.foodImage.isNotEmpty ? _imageBytes : null,
        );

    await result.when(
      success: (_) async {
        state = state.copyWith(
          status: EditStatus.success.name,
          isSuccess: true,
        );
      },
      failure: (error) {
        state = state.copyWith(
          status: EditStatus.error.name,
          isSuccess: false,
        );
      },
    );
  }

  Future<bool> _pickImage(ImageSource source, String errorMessage) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        maxHeight: _imageConfig.maxSize,
        maxWidth: _imageConfig.maxSize,
        imageQuality: _imageConfig.quality,
      );
      if (image == null) {
        return false;
      }
      final cropImage = await _cropImage(image);
      await _processImage(cropImage);
      return true;
    } on PlatformException catch (error) {
      logger.e('Failed to pick image: ${error.message}');
      state = state.copyWith(status: errorMessage);
      return false;
    }
  }

  Future<void> _processImage(File cropImage) async {
    _imageBytes = await cropImage.readAsBytes();
    _uploadImage = cropImage.path;
    state = state.copyWith(
      foodImage: cropImage.path,
      status: EditStatus.photoSuccess.name,
    );
  }

  Future<File> _cropImage(XFile image) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: [_androidSettings, _iosSettings],
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

enum EditStatus {
  missingInfo,
  error,
  photoSuccess,
  cameraPermission,
  albumPermission,
  success,
  loading,
  initial,
}
