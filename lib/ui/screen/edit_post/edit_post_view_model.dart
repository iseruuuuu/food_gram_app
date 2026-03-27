import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/post/services/detail_post_service.dart';
import 'package:food_gram_app/core/supabase/post/services/post_service.dart';
import 'package:food_gram_app/core/utils/format/post_price_formatter.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/core/vision/food_image_labeler.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/screen/edit_post/edit_post_state.dart';
import 'package:food_gram_app/ui/screen/post_detail/post_detail_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
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

  // コントローラーとプロパティ
  final _foodController = TextEditingController();
  final _commentController = TextEditingController();
  final _priceController = TextEditingController();
  final _picker = ImagePicker();
  final Map<String, Uint8List> _imageBytesMap = {};
  late Posts _posts;

  TextEditingController get foodController => _foodController;

  TextEditingController get commentController => _commentController;

  TextEditingController get priceController => _priceController;

  Loading get loading => ref.read(loadingProvider.notifier);

  Map<String, Uint8List> get imageBytesMap => _imageBytesMap;

  @override
  EditPostState build({EditPostState? initState}) {
    ref.onDispose(() {
      _foodController.dispose();
      _commentController.dispose();
      _priceController.dispose();
      _imageBytesMap.clear();
    });
    return initState ?? const EditPostState();
  }

  void initializeWithPosts(Posts posts) {
    // ビルド中にプロバイダを更新しないよう遅延
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editPostRemovingPathsProvider.notifier).state = {};
    });
    _posts = posts;
    _foodController.text = posts.foodName;
    _commentController.text = posts.comment;
    _priceController.text =
        formatPostPriceForEditing(posts.priceAmount, posts.priceCurrency);
    // 既存の画像パス（表示・Storage 用。ローカル一時パス等は [Posts.foodImageList] で除外）
    final existingImages = posts.foodImageList;
    final currency = posts.priceCurrency?.trim();
    state = state.copyWith(
      restaurant: posts.restaurant,
      lat: posts.lat,
      lng: posts.lng,
      star: posts.star,
      isAnonymous: posts.isAnonymous,
      existingImagePaths: existingImages,
      priceCurrency: (currency != null && currency.isNotEmpty)
          ? currency.toUpperCase()
          : defaultPostPriceCurrencyFromPlatform(),
    );
  }

  Future<bool> update({
    required String foodTag,
    Locale? locale,
  }) async {
    primaryFocus?.unfocus();
    loading.state = true;
    state = state.copyWith(status: EditStatus.loading.name);
    if (_foodController.text.isEmpty) {
      loading.state = false;
      state = state.copyWith(status: EditStatus.missingInfo.name);
      return false;
    }
    final currency = state.priceCurrency.isEmpty
        ? defaultPostPriceCurrencyFromPlatform()
        : state.priceCurrency;
    final parsed = parsePostPriceInput(
      rawAmount: _priceController.text,
      currencyCode: currency,
      locale: locale,
    );
    if (parsed.isInvalid) {
      loading.state = false;
      state = state.copyWith(status: EditStatus.invalidPrice.name);
      return false;
    }
    try {
      await _updatePost(foodTag, parsed);
      if (state.isSuccess) {
        _imageBytesMap.clear();
      }
      return state.isSuccess;
    } finally {
      loading.state = false;
    }
  }

  Future<bool> camera(BuildContext context) async {
    return _pickImage(
      context,
      ImageSource.camera,
      EditStatus.cameraPermission.name,
    );
  }

  Future<bool> album(BuildContext context) async {
    return _pickMultiImage(context, EditStatus.albumPermission.name);
  }

  Future<void> _updatePost(
    String foodTag,
    PostPriceParseResult priceParse,
  ) async {
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
          priceAmount: priceParse.isEmpty ? null : priceParse.amount,
          priceCurrency: priceParse.isEmpty ? null : priceParse.currency,
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

  Future<bool> _pickImage(
    BuildContext context,
    ImageSource source,
    String errorMessage,
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
      logger.e('Failed to pick image: ${error.message}');
      state = state.copyWith(status: errorMessage);
      return false;
    }
  }

  Future<bool> _pickMultiImage(
    BuildContext context,
    String errorMessage,
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
        }
      }
      return state.foodImages.isNotEmpty;
    } on PlatformException catch (error) {
      logger.e('Failed to pick images: ${error.message}');
      state = state.copyWith(status: errorMessage);
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
      extra: imagePath,
    );
    return result;
  }

  Future<void> _processImageFromBytes(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/food_gram_edit_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(bytes);
    await _processImage(file);
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
    final idx = state.existingImagePaths.indexOf(imagePath);
    if (idx < 0) {
      return;
    }
    final updatedExisting = List<String>.from(state.existingImagePaths)
      ..removeAt(idx);
    state = state.copyWith(existingImagePaths: updatedExisting);
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

  void setPriceCurrency(String code) {
    state = state.copyWith(priceCurrency: code.toUpperCase());
  }

  void resetStatus() {
    state = state.copyWith(status: EditStatus.initial.name);
  }
}

/// 削除タップ時にそのスロットをプレースホルダー表示にするためのパス一覧
final editPostRemovingPathsProvider = StateProvider<Set<String>>((ref) => {});

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
  invalidPrice,
}
