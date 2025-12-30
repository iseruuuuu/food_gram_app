import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/core/vision/food_image_labeler.dart';
import 'package:food_gram_app/ui/screen/post/post_state.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_view_model.g.dart';

@riverpod
class PostViewModel extends _$PostViewModel {
  static const defaultRestaurantText = '場所を追加';
  static const _imageConfig = (maxSize: 960.0, quality: 100);

  late final TextEditingController _foodController;
  late final TextEditingController _commentController;
  final _picker = ImagePicker();
  final Map<String, Uint8List> _imageBytesMap = {};
  final logger = Logger();
  final _foodLabeler = FoodImageLabeler();

  TextEditingController get foodController => _foodController;

  TextEditingController get commentController => _commentController;

  Loading get loading => ref.read(loadingProvider.notifier);

  Map<String, Uint8List> get imageBytesMap => _imageBytesMap;

  @override
  PostState build({PostState initState = const PostState()}) {
    _initializeControllers();
    return initState;
  }

  void _initializeControllers() {
    _foodController = TextEditingController();
    _commentController = TextEditingController();

    ref.onDispose(() {
      _foodController.dispose();
      _commentController.dispose();
    });
  }

  Future<bool> post({
    required String restaurantTag,
    required String foodTag,
  }) async {
    primaryFocus?.unfocus();
    loading.state = true;
    state = state.copyWith(status: PostStatus.loading.name);
    if (_isPostMissing()) {
      loading.state = false;
      return false;
    }
    await _submitPost(restaurantTag, foodTag);
    loading.state = false;
    return state.isSuccess;
  }

  Future<bool> camera() async {
    return _pickImage(
      ImageSource.camera,
      PostStatus.cameraPermission.name,
    );
  }

  Future<bool> album() async {
    return _pickMultiImage(PostStatus.albumPermission.name);
  }

  void loadRestaurant(Restaurant? restaurant) {
    if (restaurant == null) {
      return;
    }
    _updateRestaurantState(restaurant);
  }

  void getPlace(Restaurant restaurant) {
    _updateRestaurantState(restaurant);
  }

  Future<void> _submitPost(String restaurantTag, String foodTag) async {
    final result = await ref.read(postRepositoryProvider.notifier).createPost(
          foodName: foodController.text,
          comment: commentController.text,
          uploadImages: state.foodImages,
          imageBytesMap: _imageBytesMap,
          restaurant: state.restaurant,
          lng: state.lng,
          lat: state.lat,
          restaurantTag: restaurantTag,
          foodTag: foodTag,
          isAnonymous: state.isAnonymous,
        );
    await result.when(
      success: (_) async {
        state = state.copyWith(
          status: PostStatus.success.name,
          isSuccess: true,
        );
      },
      failure: (error) {
        state = state.copyWith(
          status: PostStatus.error.name,
          isSuccess: false,
        );
      },
    );
  }

  bool _isPostMissing() {
    if (state.foodImages.isEmpty) {
      state = state.copyWith(status: PostStatus.missingPhoto.name);
      return true;
    }
    if (foodController.text.isEmpty) {
      state = state.copyWith(status: PostStatus.missingFoodName.name);
      return true;
    }
    if (state.restaurant == defaultRestaurantText) {
      state = state.copyWith(status: PostStatus.missingRestaurant.name);
      return true;
    }

    return false;
  }

  Future<bool> _pickImage(ImageSource source, String errorPickerImage) async {
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
      logger.e(error.message);
      state = state.copyWith(status: errorPickerImage);
      return false;
    }
  }

  Future<bool> _pickMultiImage(String errorPickerImage) async {
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
      logger.e(error.message);
      state = state.copyWith(status: errorPickerImage);
      return false;
    }
  }

  Future<void> _processImage(File cropImage) async {
    final imageBytes = await cropImage.readAsBytes();
    final imagePath = cropImage.path;
    _imageBytesMap[imagePath] = imageBytes;
    final updatedImages = [...state.foodImages, imagePath];
    // 画像を一旦追加した上で、食べ物判定
    final isFood = await _foodLabeler.isFood(imagePath);
    state = state.copyWith(
      foodImages: updatedImages,
      status:
          isFood ? PostStatus.photoSuccess.name : PostStatus.maybeNotFood.name,
    );
  }

  void removeImage(String imagePath) {
    _imageBytesMap.remove(imagePath);
    final updatedImages =
        state.foodImages.where((path) => path != imagePath).toList();
    state = state.copyWith(foodImages: updatedImages);
  }

  Future<File?> _cropImage(XFile image) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: _getCropperSettings(),
    );
    if (croppedFile == null) {
      return null;
    }
    return File(croppedFile.path);
  }

  void _updateRestaurantState(Restaurant restaurant) {
    state = state.copyWith(
      restaurant: restaurant.name,
      lat: restaurant.lat,
      lng: restaurant.lng,
    );
  }

  List<PlatformUiSettings> _getCropperSettings() {
    return [
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
    ];
  }

  void setAnonymous({required bool value}) {
    state = state.copyWith(isAnonymous: value);
  }

  void resetStatus() {
    state = state.copyWith(status: PostStatus.initial.name);
  }
}

enum PostStatus {
  error,
  photoSuccess,
  cameraPermission,
  albumPermission,
  success,
  loading,
  initial,
  errorPickImage,
  missingPhoto,
  missingFoodName,
  missingRestaurant,
  maybeNotFood,
}
