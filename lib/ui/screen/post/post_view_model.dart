import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/supabase/post/services/post_service.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
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
  String _uploadImage = '';
  late Uint8List _imageBytes;
  final logger = Logger();

  TextEditingController get foodController => _foodController;

  TextEditingController get commentController => _commentController;

  Loading get loading => ref.read(loadingProvider.notifier);

  String get uploadImage => _uploadImage;

  Uint8List get imageBytes => _imageBytes;

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
    if (_isPostDataMissing()) {
      loading.state = false;
      state = state.copyWith(status: PostStatus.missingInfo.name);
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
    return _pickImage(
      ImageSource.gallery,
      PostStatus.albumPermission.name,
    );
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
    final result = await ref.read(postServiceProvider.notifier).post(
          foodName: foodController.text,
          comment: commentController.text,
          uploadImage: _uploadImage,
          imageBytes: _imageBytes,
          restaurant: state.restaurant,
          lng: state.lng,
          lat: state.lat,
          restaurantTag: restaurantTag,
          foodTag: foodTag,
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

  bool _isPostDataMissing() {
    return foodController.text.isEmpty ||
        state.restaurant == defaultRestaurantText ||
        _uploadImage.isEmpty;
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
      logger.e(error.message);
      state = state.copyWith(status: errorMessage);
      return false;
    }
  }

  Future<void> _processImage(File cropImage) async {
    _imageBytes = await cropImage.readAsBytes();
    _uploadImage = cropImage.path;
    state = state.copyWith(
      foodImage: cropImage.path,
      status: PostStatus.photoSuccess.name,
    );
  }

  Future<File> _cropImage(XFile image) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: _getCropperSettings(),
    );
    return File(croppedFile!.path);
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
}

enum PostStatus {
  missingInfo,
  error,
  photoSuccess,
  cameraPermission,
  albumPermission,
  success,
  loading,
  initial,
}
