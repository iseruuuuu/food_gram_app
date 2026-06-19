import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/photo_restaurant_candidate.dart';
import 'package:food_gram_app/core/model/post_draft.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/core/utils/format/post_price_formatter.dart';
import 'package:food_gram_app/core/utils/image/upload_image_bytes.dart';
import 'package:food_gram_app/core/utils/location/image_gps_reader.dart';
import 'package:food_gram_app/core/utils/location/post_price_currency_from_location.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/core/vision/food_image_labeler.dart';
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
  final _logger = Logger();
  final _picker = ImagePicker();
  final _foodLabeler = FoodImageLabeler();
  final _preference = Preference();
  late final TextEditingController _foodController;
  late final TextEditingController _commentController;
  late final TextEditingController _priceController;
  final Map<String, Uint8List> _imageBytesMap = {};
  final Map<String, ({double latitude, double longitude})> _imageGpsByPath = {};
  Completer<void>? _maybeNotFoodCompleter;
  bool _restoredFromDraft = false;
  bool _priceCurrencyManuallySet = false;
  bool _disposed = false;
  int _currencyAutoDetectSeq = 0;
  TextEditingController get foodController => _foodController;
  TextEditingController get commentController => _commentController;
  TextEditingController get priceController => _priceController;
  Loading get loading => ref.read(loadingProvider.notifier);
  Map<String, Uint8List> get imageBytesMap => _imageBytesMap;

  @override
  PostState build({PostState initState = const PostState()}) {
    _initializeControllers();
    final withCurrency = initState.priceCurrency.isEmpty
        ? initState.copyWith(priceCurrency: defaultPostPriceCurrencyForLocale())
        : initState;
    return withCurrency;
  }

  void _initializeControllers() {
    _foodController = TextEditingController();
    _commentController = TextEditingController();
    _priceController = TextEditingController();
    ref.onDispose(() {
      _disposed = true;
      _foodController.dispose();
      _commentController.dispose();
      _priceController.dispose();
      if (!(_maybeNotFoodCompleter?.isCompleted ?? true)) {
        _maybeNotFoodCompleter!.complete();
      }
      _maybeNotFoodCompleter = null;
      _imageBytesMap.clear();
      _imageGpsByPath.clear();
      _currencyAutoDetectSeq++;
    });
  }

  // --- 投稿 ---
  Future<bool> post({
    required String foodTag,
    Locale? locale,
  }) async {
    primaryFocus?.unfocus();
    loading.state = true;
    state = state.copyWith(status: PostStatus.loading.name);
    if (_isPostMissing()) {
      loading.state = false;
      return false;
    }
    final currency = state.priceCurrency.isEmpty
        ? defaultPostPriceCurrencyForLocale()
        : state.priceCurrency;
    final parsed = parsePostPriceInput(
      rawAmount: _priceController.text,
      currencyCode: currency,
      locale: locale,
    );
    if (parsed.isInvalid) {
      loading.state = false;
      state = state.copyWith(status: PostStatus.invalidPrice.name);
      return false;
    }
    await _submitPost(foodTag, parsed);
    if (state.isSuccess) {
      _imageBytesMap.clear();
      _imageGpsByPath.clear();
    }
    loading.state = false;
    return state.isSuccess;
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

  Future<void> _submitPost(
    String foodTag,
    PostPriceParseResult priceParse,
  ) async {
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
          priceAmount: priceParse.isEmpty ? null : priceParse.amount,
          priceCurrency: priceParse.isEmpty ? null : priceParse.currency,
        );
    await result.when(
      success: (_) async {
        final fromDraft = _restoredFromDraft;
        _restoredFromDraft = false;
        await _preference.clearPostDraft();
        state = state.copyWith(
          status: PostStatus.success.name,
          isSuccess: true,
        );
        final hasComment = commentController.text.trim().isNotEmpty;
        final hasRestaurant = state.restaurant != defaultRestaurantText &&
            state.restaurant != '不明';
        unawaited(
          ref.read(firebaseAnalyticsServiceProvider).logPostSuccess(
                fromDraft: fromDraft,
                hasComment: hasComment,
                hasRestaurant: hasRestaurant,
              ),
        );
      },
      failure: (error) {
        unawaited(
          ref
              .read(firebaseAnalyticsServiceProvider)
              .logPostFailed(reason: error.toString()),
        );
        state = state.copyWith(
          status: PostStatus.error.name,
          isSuccess: false,
        );
      },
    );
  }

  // --- 画像 ---
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

  void removeImage(String imagePath) {
    _imageBytesMap.remove(imagePath);
    _imageGpsByPath.remove(imagePath);
    final updatedImages =
        state.foodImages.where((path) => path != imagePath).toList();
    state = state.copyWith(
      foodImages: updatedImages,
      nearbySuggestionDismissed:
          updatedImages.isNotEmpty && state.nearbySuggestionDismissed,
    );
    _applyPhotoGpsFromImages(updatedImages);
  }

  Future<bool> _pickImage(
    BuildContext context,
    ImageSource source,
    String errorPickerImage,
  ) async {
    try {
      final image = await _picker.pickImage(
        source: source,
      );
      if (image == null) {
        return false;
      }
      unawaited(_tryApplyCurrencyFromImage(image.path));
      final photoGps = await readGpsFromImagePath(image.path);
      final bytes = await _openImageEditor(context, image.path);
      if (bytes == null) {
        return false;
      }
      await _processImageFromBytes(bytes, photoGps: photoGps);
      ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
            name: AnalyticsEvent.postPhotoSelected,
          );
      return true;
    } on PlatformException catch (error) {
      _logger.e(error.message);
      state = state.copyWith(status: errorPickerImage);
      return false;
    }
  }

  Future<bool> _pickMultiImage(
    BuildContext context,
    String errorPickerImage,
  ) async {
    try {
      final images = await _picker.pickMultiImage();
      if (images.isEmpty) {
        return false;
      }
      ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
        name: AnalyticsEvent.postMultiplePhotoSelected,
        parameters: {AnalyticsParam.photoCount: images.length},
      );
      for (final image in images) {
        unawaited(_tryApplyCurrencyFromImage(image.path));
        final photoGps = await readGpsFromImagePath(image.path);
        final bytes = await _openImageEditor(context, image.path);
        if (bytes != null) {
          await _processImageFromBytes(bytes, photoGps: photoGps);
          if (state.status == PostStatus.maybeNotFood.name) {
            await _waitMaybeNotFoodHandled();
          }
        }
      }
      return state.foodImages.isNotEmpty;
    } on PlatformException catch (error) {
      _logger.e(error.message);
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
      extra: imagePath,
    );
    return result;
  }

  Future<void> _processImageFromBytes(
    Uint8List bytes, {
    ({double latitude, double longitude})? photoGps,
  }) async {
    final uploadBytes = await prepareUploadImageBytes(bytes);
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/food_gram_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(uploadBytes);
    await _processImage(file, photoGps: photoGps);
  }

  Future<void> _processImage(
    File cropImage, {
    ({double latitude, double longitude})? photoGps,
  }) async {
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
    if (photoGps != null) {
      _imageGpsByPath[imagePath] = photoGps;
    }
    if (state.restaurant == defaultRestaurantText) {
      _applyPhotoGpsFromImages(updatedImages);
    }
  }

  /// 残っている画像のうち先頭の GPS を photoLat/photoLng に反映する
  void _applyPhotoGpsFromImages(List<String> imagePaths) {
    for (final path in imagePaths) {
      final gps = _imageGpsByPath[path];
      if (gps != null) {
        final gpsChanged =
            state.photoLat != gps.latitude || state.photoLng != gps.longitude;
        state = state.copyWith(
          photoLat: gps.latitude,
          photoLng: gps.longitude,
          nearbySuggestionDismissed:
              !gpsChanged && state.nearbySuggestionDismissed,
        );
        return;
      }
    }
    state = state.copyWith(
      photoLat: null,
      photoLng: null,
      nearbySuggestionDismissed:
          imagePaths.isNotEmpty && state.nearbySuggestionDismissed,
    );
  }

  Future<void> _waitMaybeNotFoodHandled() async {
    // UI側のダイアログで「続行」または「削除」によって
    // resetStatus() が呼ばれ、Completer が完了するまで待機
    _maybeNotFoodCompleter = Completer<void>();
    return _maybeNotFoodCompleter!.future;
  }

  // --- レストラン ---
  void loadRestaurant(Restaurant? restaurant) {
    if (restaurant == null) {
      return;
    }
    _updateRestaurantState(restaurant);
  }

  void getPlace(Restaurant restaurant) {
    _updateRestaurantState(restaurant);
    ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
          name: AnalyticsEvent.postRestaurantManualSelected,
        );
  }

  void selectNearbyCandidate(PhotoRestaurantCandidate candidate) {
    _updateRestaurantState(candidate.toRestaurant());
    ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
          name: AnalyticsEvent.postRestaurantAutoDetectSelected,
        );
  }

  void dismissNearbySuggestion() {
    state = state.copyWith(nearbySuggestionDismissed: true);
  }

  void postWithoutRestaurant() {
    state = state.copyWith(
      restaurant: '不明',
      lat: 0,
      lng: 0,
      nearbySuggestionDismissed: true,
    );
  }

  void _updateRestaurantState(Restaurant restaurant) {
    state = state.copyWith(
      restaurant: restaurant.name,
      lat: restaurant.lat,
      lng: restaurant.lng,
      nearbySuggestionDismissed: true,
    );
    unawaited(
      _tryApplyCurrencyFromCoordinates(restaurant.lat, restaurant.lng),
    );
  }

  // --- 価格・通貨 ---
  void setPriceCurrency(String code) {
    _priceCurrencyManuallySet = true;
    state = state.copyWith(priceCurrency: code.toUpperCase());
    ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
          name: AnalyticsEvent.postPriceInput,
        );
  }

  Future<void> _tryApplyCurrencyFromImage(String imagePath) async {
    if (_priceCurrencyManuallySet || _disposed) {
      return;
    }
    final seq = ++_currencyAutoDetectSeq;
    final code = await postPriceCurrencyFromImagePath(imagePath);
    _applyAutoDetectedCurrency(code, seq);
  }

  Future<void> _tryApplyCurrencyFromCoordinates(double lat, double lng) async {
    if (_priceCurrencyManuallySet || _disposed) {
      return;
    }
    final seq = ++_currencyAutoDetectSeq;
    final code = await postPriceCurrencyFromCoordinates(
      latitude: lat,
      longitude: lng,
    );
    _applyAutoDetectedCurrency(code, seq);
  }

  void _applyAutoDetectedCurrency(String? code, int seq) {
    if (_disposed || seq != _currencyAutoDetectSeq) {
      return;
    }
    if (code == null || code.isEmpty || _priceCurrencyManuallySet) {
      return;
    }
    final upper = code.toUpperCase();
    if (state.priceCurrency == upper) {
      return;
    }
    state = state.copyWith(priceCurrency: upper);
  }

  // --- 投稿の情報 ---
  void setAnonymous({required bool value}) {
    state = state.copyWith(isAnonymous: value);
  }

  void setStar(double value) {
    state = state.copyWith(star: value);
    ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
      name: AnalyticsEvent.postRatingInput,
      parameters: {AnalyticsParam.rating: value},
    );
  }

  void resetStatus() {
    state = state.copyWith(status: PostStatus.initial.name);
    _maybeNotFoodCompleter?.complete();
    _maybeNotFoodCompleter = null;
  }

  // --- 下書き ---
  void markRestoredFromDraft() {
    _restoredFromDraft = true;
  }

  Future<PostDraft?> loadSavedDraft() => _preference.getPostDraft();

  Future<void> saveDraft({required List<String> foodTags}) async {
    final currency = state.priceCurrency.isEmpty
        ? defaultPostPriceCurrencyForLocale()
        : state.priceCurrency;
    final draft = PostDraft(
      foodName: _foodController.text,
      comment: _commentController.text,
      priceInput: _priceController.text,
      restaurant: state.restaurant,
      lat: state.lat,
      lng: state.lng,
      foodTags: List<String>.from(foodTags),
      star: state.star,
      isAnonymous: state.isAnonymous,
      priceCurrency: currency,
    );
    await _preference.savePostDraft(draft);
    unawaited(
      ref.read(firebaseAnalyticsServiceProvider).logEvent(
            name: AnalyticsEvent.draftSave,
          ),
    );
  }

  void applyDraft(PostDraft draft, {required bool applyRestaurant}) {
    _foodController.text = draft.foodName;
    _commentController.text = draft.comment;
    _priceController.text = draft.priceInput;
    final draftCurrency = draft.priceCurrency.trim();
    if (draftCurrency.isNotEmpty) {
      _priceCurrencyManuallySet = true;
    }
    state = state.copyWith(
      restaurant: applyRestaurant ? draft.restaurant : state.restaurant,
      lat: applyRestaurant ? draft.lat : state.lat,
      lng: applyRestaurant ? draft.lng : state.lng,
      star: draft.star,
      isAnonymous: draft.isAnonymous,
      priceCurrency: draftCurrency.isEmpty
          ? state.priceCurrency
          : draftCurrency.toUpperCase(),
    );
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
  invalidPrice,
}
