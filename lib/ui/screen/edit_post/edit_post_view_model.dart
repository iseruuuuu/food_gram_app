import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/post/services/detail_post_service.dart';
import 'package:food_gram_app/core/supabase/post/services/post_service.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/core/vision/food_image_labeler.dart';
import 'package:food_gram_app/ui/screen/edit_post/edit_post_state.dart';
import 'package:food_gram_app/ui/screen/post_detail/post_detail_view_model.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_post_view_model.g.dart';

@riverpod
class EditPostViewModel extends _$EditPostViewModel {
  final logger = Logger();
  final _foodLabeler = FoodImageLabeler();

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
  final Map<String, Uint8List> _imageBytesMap = {};
  late Posts _posts;

  TextEditingController get foodController => _foodController;

  TextEditingController get commentController => _commentController;

  Loading get loading => ref.read(loadingProvider.notifier);

  Map<String, Uint8List> get imageBytesMap => _imageBytesMap;

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
    // 既存の画像パスをカンマ区切りからリストに変換
    final existingImages = posts.foodImage.isNotEmpty
        ? posts.foodImage.split(',').where((path) => path.isNotEmpty).toList()
        : <String>[];
    state = state.copyWith(
      restaurant: posts.restaurant,
      lat: posts.lat,
      lng: posts.lng,
      star: posts.star,
      isAnonymous: posts.isAnonymous,
      existingImagePaths: existingImages,
    );
  }

  Future<bool> update({
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
      await _updatePost(foodTag);
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
    return _pickMultiImage(EditStatus.albumPermission.name);
  }

  Future<void> _updatePost(String foodTag) async {
    final result = await ref.read(postServiceProvider.notifier).updatePost(
          posts: _posts,
          foodName: _foodController.text,
          comment: _commentController.text,
          restaurant: state.restaurant,
          foodTag: foodTag,
          lat: state.lat,
          lng: state.lng,
          star: state.star,
          isAnonymous: state.isAnonymous,
          newImagePaths: state.foodImages,
          imageBytesMap: _imageBytesMap,
          existingImagePaths: state.existingImagePaths,
        );

    await result.when(
      success: (_) async {
        // キャッシュを無効化
        CacheManager().invalidatePostCache(_posts.id);
        // 更新した投稿を取得
        final updatedPostResult = await ref
            .read(detailPostServiceProvider.notifier)
            .getPost(_posts.id);
        updatedPostResult.when(
          success: (data) {
            final updatedPost =
                Posts.fromJson(data['post'] as Map<String, dynamic>);
            state = state.copyWith(
              posts: updatedPost,
              status: EditStatus.success.name,
              isSuccess: true,
            );
            ref.invalidate(postsStreamProvider);
            ref.invalidate(postsViewModelProvider(_posts.id));
          },
          failure: (error) {
            logger.e('Failed to get updated post: $error');
            state = state.copyWith(
              status: EditStatus.error.name,
              isSuccess: false,
            );
          },
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
      if (cropImage == null) {
        return false;
      }
      await _processImage(cropImage);
      return true;
    } on PlatformException catch (error) {
      logger.e('Failed to pick image: ${error.message}');
      state = state.copyWith(status: errorMessage);
      return false;
    }
  }

  Future<bool> _pickMultiImage(String errorMessage) async {
    try {
      final images = await _picker.pickMultiImage(
        maxHeight: _imageConfig.maxSize,
        maxWidth: _imageConfig.maxSize,
        imageQuality: _imageConfig.quality,
      );
      if (images.isEmpty) {
        return false;
      }

      // 選択した画像を順番にトリミング
      final croppedImages = <File>[];
      for (final image in images) {
        final cropImage = await _cropImage(image);
        if (cropImage != null) {
          croppedImages.add(cropImage);
        }
      }

      // すべてのトリミングが完了したら、すべての画像を追加
      if (croppedImages.isNotEmpty) {
        for (final cropImage in croppedImages) {
          await _processImage(cropImage);
        }
        return true;
      }
      return false;
    } on PlatformException catch (error) {
      logger.e('Failed to pick images: ${error.message}');
      state = state.copyWith(status: errorMessage);
      return false;
    }
  }

  Future<void> _processImage(File cropImage) async {
    final imageBytes = await cropImage.readAsBytes();
    final imagePath = cropImage.path;
    _imageBytesMap[imagePath] = imageBytes;
    final updatedImages = [...state.foodImages, imagePath];
    final isFood = await _foodLabeler.isFood(imagePath);
    state = state.copyWith(
      foodImages: updatedImages,
      status:
          isFood ? EditStatus.photoSuccess.name : EditStatus.maybeNotFood.name,
    );
  }

  void removeImage(String imagePath) {
    _imageBytesMap.remove(imagePath);
    final updatedImages =
        state.foodImages.where((path) => path != imagePath).toList();
    state = state.copyWith(foodImages: updatedImages);
  }

  void removeExistingImage(String imagePath) {
    final updatedExisting =
        state.existingImagePaths.where((path) => path != imagePath).toList();
    state = state.copyWith(existingImagePaths: updatedExisting);
  }

  Future<File?> _cropImage(XFile image) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: [_androidSettings, _iosSettings],
    );
    if (croppedFile == null) {
      return null;
    }
    return File(croppedFile.path);
  }

  void getPlace(Restaurant restaurant) {
    state = state.copyWith(
      restaurant: restaurant.name,
      lat: restaurant.lat,
      lng: restaurant.lng,
    );
  }

  void setStar(double value) {
    state = state.copyWith(star: value);
  }

  void setAnonymous({required bool value}) {
    state = state.copyWith(isAnonymous: value);
  }

  void resetStatus() {
    state = state.copyWith(status: EditStatus.initial.name);
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
  maybeNotFood,
}
