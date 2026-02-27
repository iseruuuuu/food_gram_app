import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/core/vision/food_image_labeler.dart';
import 'package:food_gram_app/router/image_editor_args.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/screen/post/post_state.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
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
  Completer<void>? _maybeNotFoodCompleter;

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
      _imageBytesMap.clear();
    });
  }

  Future<bool> post({
    required String foodTag,
  }) async {
    primaryFocus?.unfocus();
    loading.state = true;
    state = state.copyWith(status: PostStatus.loading.name);
    if (_isPostMissing()) {
      loading.state = false;
      return false;
    }
    await _submitPost(foodTag);
    if (state.isSuccess) {
      _imageBytesMap.clear();
    }
    loading.state = false;
    return state.isSuccess;
  }

  Future<bool> camera(BuildContext context) async {
    return _pickImage(
      context,
      ImageSource.camera,
      PostStatus.cameraPermission.name,
    );
  }

  Future<bool> album(BuildContext context) async {
    return _pickMultiImage(context, PostStatus.albumPermission.name);
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

  Future<void> _submitPost(String foodTag) async {
    final result = await ref.read(postRepositoryProvider.notifier).createPost(
          foodName: foodController.text,
          comment: commentController.text,
          uploadImages: state.foodImages,
          imageBytesMap: _imageBytesMap,
          restaurant: state.restaurant,
          lng: state.lng,
          lat: state.lat,
          foodTag: foodTag,
          star: state.star,
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

  Future<bool> _pickImage(
    BuildContext context,
    ImageSource source,
    String errorPickerImage,
  ) async {
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
      final bytes = await _openImageEditor(context, image.path);
      if (bytes == null) {
        return false;
      }
      await _processImageFromBytes(bytes);
      return true;
    } on PlatformException catch (error) {
      logger.e(error.message);
      state = state.copyWith(status: errorPickerImage);
      return false;
    }
  }

  Future<bool> _pickMultiImage(
    BuildContext context,
    String errorPickerImage,
  ) async {
    try {
      final images = await _picker.pickMultiImage(
        maxHeight: _imageConfig.maxSize,
        maxWidth: _imageConfig.maxSize,
        imageQuality: _imageConfig.quality,
      );
      if (images.isEmpty) {
        return false;
      }

      for (final image in images) {
        final bytes = await _openImageEditor(context, image.path);
        if (bytes != null) {
          await _processImageFromBytes(bytes);
          if (state.status == PostStatus.maybeNotFood.name) {
            await _waitMaybeNotFoodHandled();
          }
        }
      }
      return state.foodImages.isNotEmpty;
    } on PlatformException catch (error) {
      logger.e(error.message);
      state = state.copyWith(status: errorPickerImage);
      return false;
    }
  }

  Future<Uint8List?> _openImageEditor(
    BuildContext context,
    String imagePath,
  ) async {
    if (!context.mounted) {
      return null;
    }
    final result = await context.pushNamed<Uint8List?>(
      RouterPath.imageEditor,
      extra: ImageEditorArgs(imagePath),
    );
    return result;
  }

  Future<void> _processImageFromBytes(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/food_gram_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    try {
      await file.writeAsBytes(bytes);
      await _processImage(file);
    } catch (e) {
      logger.e('Failed to process image from bytes: $e');
      state = state.copyWith(status: PostStatus.errorPickImage.name);
      rethrow;
    } finally {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<void> _waitMaybeNotFoodHandled() async {
    // UI側のダイアログで「続行」または「削除」によって
    // resetStatus() が呼ばれ、Completer が完了するまで待機
    _maybeNotFoodCompleter = Completer<void>();
    return _maybeNotFoodCompleter!.future;
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

  void _updateRestaurantState(Restaurant restaurant) {
    state = state.copyWith(
      restaurant: restaurant.name,
      lat: restaurant.lat,
      lng: restaurant.lng,
    );
  }

  void setAnonymous({required bool value}) {
    state = state.copyWith(isAnonymous: value);
  }

  void setStar(double value) {
    state = state.copyWith(star: value);
  }

  void resetStatus() {
    state = state.copyWith(status: PostStatus.initial.name);
    _maybeNotFoodCompleter?.complete();
    _maybeNotFoodCompleter = null;
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
