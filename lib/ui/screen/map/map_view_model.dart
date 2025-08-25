import 'package:flutter/services.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/ui/component/app_pin_widget.dart';
import 'package:food_gram_app/ui/screen/map/map_state.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:screenshot/screenshot.dart';

part 'map_view_model.g.dart';

@riverpod
class MapViewModel extends _$MapViewModel {
  @override
  MapState build() {
    _preloadDefaultImages();
    return const MapState();
  }

  bool isInitialLoading = true;
  final screenshotController = ScreenshotController();
  final Map<String, Uint8List> _imageCache = {};

  /// デフォルト画像を事前生成
  Future<void> _preloadDefaultImages() async {
    if (!_imageCache.containsKey('default')) {
      final screenshotBytes = await screenshotController.captureFromWidget(
        const AppFoodTagPinWidget(foodTag: ''),
      );
      _imageCache['default'] = screenshotBytes.buffer.asUint8List();
    }
  }

  /// マップコントローラーを設定し、ピンを配置
  Future<void> setMapController(
    MapLibreMapController controller, {
    required void Function(List<Posts> posts) onPinTap,
    required double iconSize,
  }) async {
    state = state.copyWith(mapController: controller);
    await setPin(
      onPinTap: onPinTap,
      iconSize: iconSize,
    );
  }

  /// ピンを設定するメインメソッド
  Future<void> setPin({
    required void Function(List<Posts> posts) onPinTap,
    required double iconSize,
  }) async {
    if (!isInitialLoading) {
      await state.mapController!.clearSymbols();
    }

    try {
      // 投稿データを取得
      final posts =
          ref.read(mapRepositoryProvider).whenOrNull(data: (value) => value);
      if (posts == null || posts.isEmpty) {
        return;
      }
      // ピン画像の種類を収集
      final imageTypes = <String>{};
      for (final post in posts) {
        final type = post.foodTag.isEmpty
            ? 'default'
            : post.foodTag.split(',').first.trim();
        imageTypes.add(type);
      }
      // 画像を並列で生成してマップに追加
      final imageKeys = await _generatePinImages(imageTypes, posts);
      // シンボルを作成して追加
      final symbols = posts.map((post) {
        final imageType = post.foodTag.isEmpty
            ? 'default'
            : post.foodTag.split(',').first.trim();
        return SymbolOptions(
          geometry: LatLng(post.lat, post.lng),
          iconImage: imageKeys[imageType],
          iconSize: iconSize,
        );
      }).toList();
      if (symbols.isNotEmpty) {
        await state.mapController?.addSymbols(symbols);
        await state.mapController?.setSymbolIconIgnorePlacement(true);
        await state.mapController?.setSymbolIconAllowOverlap(true);
      }
      // タップイベントを設定
      state.mapController?.onSymbolTapped.add((symbol) async {
        state = state.copyWith(isLoading: true);
        final latLng = symbol.options.geometry;
        final restaurant = await ref
            .read(postRepositoryProvider.notifier)
            .getRestaurantPosts(lat: latLng!.latitude, lng: latLng.longitude);
        restaurant.whenOrNull(success: (posts) => onPinTap(posts));
        await state.mapController?.animateCamera(
          CameraUpdate.newLatLng(latLng),
          duration: const Duration(seconds: 1),
        );
        isInitialLoading = false;
        state = state.copyWith(isLoading: false, hasError: false);
      });
    } on PlatformException catch (_) {
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }

  /// ピン画像を並列で生成してマップに追加
  Future<Map<String, String>> _generatePinImages(
    Set<String> imageTypes,
    List<Posts> posts,
  ) async {
    final imageKeys = <String, String>{};
    final imageTasks = <Future<void>>[];

    for (final imageType in imageTypes) {
      final imageKey = 'pin_$imageType';
      imageKeys[imageType] = imageKey;
      if (_imageCache.containsKey(imageType)) {
        // キャッシュ済み → 即座にマップに追加
        imageTasks.add(
          state.mapController!.addImage(imageKey, _imageCache[imageType]!),
        );
      } else {
        // 新規生成
        final samplePost = posts.firstWhere(
          (post) =>
              (post.foodTag.isEmpty
                  ? 'default'
                  : post.foodTag.split(',').first.trim()) ==
              imageType,
          orElse: () => posts.first,
        );
        imageTasks.add(() async {
          final screenshotBytes = await screenshotController.captureFromWidget(
            AppFoodTagPinWidget(foodTag: samplePost.foodTag),
          );
          _imageCache[imageType] = screenshotBytes.buffer.asUint8List();
          await state.mapController!
              .addImage(imageKey, _imageCache[imageType]!);
        }());
      }
    }

    // 全ての画像生成を並列で実行
    await Future.wait(imageTasks);
    return imageKeys;
  }

  Future<void> moveToCurrentLocation() async {
    final currentLocation = ref.read(locationProvider);
    await currentLocation.whenOrNull(
      data: (location) async {
        final currentLatLng = LatLng(
          location.latitude,
          location.longitude,
        );
        await state.mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(currentLatLng, 16),
        );
      },
    );
  }
}
