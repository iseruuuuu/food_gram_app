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
    // 初回以外は既存のシンボルをクリア
    if (!isInitialLoading) {
      await state.mapController!.clearSymbols();
    }
    try {
      final symbols = <SymbolOptions>[];
      // 投稿データを取得
      final mapRepositoryValue = ref.read(mapRepositoryProvider);
      final posts = mapRepositoryValue.whenOrNull(
        data: (value) => value,
      );
      if (posts != null && posts.isNotEmpty) {
        // 使用されるピン画像の種類を収集
        final pinImageTypes = <String>{};
        for (final post in posts) {
          final imageType = post.foodTag.isEmpty
              ? 'default'
              : post.foodTag.split(',').first.trim();
          pinImageTypes.add(imageType);
        }

        // 画像を事前生成（並列処理）
        final imageKeyMap = <String, String>{};
        var imageIndex = 0;
        final imageTasks = <Future<void>>[];
        for (final imageType in pinImageTypes) {
          final imageKey = 'pin_${imageType}_$imageIndex';
          imageKeyMap[imageType] = imageKey;
          if (_imageCache.containsKey(imageType)) {
            imageTasks.add(
              state.mapController!.addImage(
                imageKey,
                _imageCache[imageType]!,
              ),
            );
          } else {
            final samplePost = posts.firstWhere(
              (post) =>
                  (post.foodTag.isEmpty
                      ? 'default'
                      : post.foodTag.split(',').first.trim()) ==
                  imageType,
              orElse: () => posts.first,
            );
            imageTasks.add(() async {
              final screenshotBytes =
                  await screenshotController.captureFromWidget(
                AppFoodTagPinWidget(foodTag: samplePost.foodTag),
              );
              final list = screenshotBytes.buffer.asUint8List();
              _imageCache[imageType] = list;
              await state.mapController!.addImage(imageKey, list);
            }());
          }
          imageIndex++;
        }
        // 全ての画像生成を並列で実行
        await Future.wait(imageTasks);

        for (final post in posts) {
          final foodTag = post.foodTag.isEmpty
              ? 'default'
              : post.foodTag.split(',').first.trim();
          symbols.add(
            SymbolOptions(
              geometry: LatLng(post.lat, post.lng),
              iconImage: imageKeyMap[foodTag],
              iconSize: iconSize,
            ),
          );
        }
      }
      if (symbols.isNotEmpty) {
        await state.mapController?.addSymbols(symbols);
        // 他のシンボルがアイコンに衝突した場合、表示されないようにする
        await state.mapController?.setSymbolIconIgnorePlacement(true);
        // アイコンは以前に描画された他のシンボルと衝突しても表示される
        await state.mapController?.setSymbolIconAllowOverlap(true);
      }

      // タップイベントを設定
      state.mapController?.onSymbolTapped.add((symbol) async {
        state = state.copyWith(isLoading: true);
        final latLng = symbol.options.geometry;
        final lat = latLng!.latitude;
        final lng = latLng.longitude;
        final restaurant = await ref
            .read(postRepositoryProvider.notifier)
            .getRestaurantPosts(lat: lat, lng: lng);

        restaurant.whenOrNull(
          success: (posts) {
            onPinTap(posts);
          },
        );
        await state.mapController?.animateCamera(
          CameraUpdate.newLatLng(latLng),
          duration: const Duration(seconds: 1),
        );
        isInitialLoading = false;
        state = state.copyWith(
          isLoading: false,
          hasError: false,
        );
      });
    } on PlatformException catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
      );
    }
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
