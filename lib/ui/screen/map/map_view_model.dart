import 'package:flutter/services.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
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
  final Set<String> _registeredImageKeys = {};
  bool _symbolTapHandlerRegistered = false;

  // ピン情報をキャッシュ
  List<Posts>? _cachedPosts;
  Map<String, String>? _cachedImageKeys;
  double? _cachedIconSize;

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

      // ピン情報をキャッシュ
      _cachedPosts = posts;
      _cachedIconSize = iconSize;

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
      _cachedImageKeys = imageKeys;

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

      // 意図的に1度だけ呼ぶにようにする
      if (!_symbolTapHandlerRegistered) {
        // タップイベントを設定
        state.mapController?.onSymbolTapped.add((symbol) async {
          state = state.copyWith(isLoading: true);
          final latLng = symbol.options.geometry;
          final restaurant = await ref
              .read(mapPostRepositoryProvider.notifier)
              .getRestaurantPosts(lat: latLng!.latitude, lng: latLng.longitude);
          restaurant.whenOrNull(success: (posts) => onPinTap(posts));
          await state.mapController?.animateCamera(
            CameraUpdate.newLatLng(latLng),
            duration: const Duration(seconds: 1),
          );
          isInitialLoading = false;
          state = state.copyWith(isLoading: false, hasError: false);
        });

        _symbolTapHandlerRegistered = true;
      }
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
        if (!_registeredImageKeys.contains(imageKey)) {
          imageTasks.add(
            state.mapController!.addImage(imageKey, _imageCache[imageType]!),
          );
          _registeredImageKeys.add(imageKey);
        }
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
          if (!_registeredImageKeys.contains(imageKey)) {
            await state.mapController!.addImage(
              imageKey,
              _imageCache[imageType]!,
            );
            _registeredImageKeys.add(imageKey);
          }
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

  /// スタイル切り替え時の処理
  void handleStyleChange() {
    if (state.mapController == null) {
      return;
    }
    // スタイル変更時に画像登録情報をクリア（復元はスタイルロード完了後に実行）
    _registeredImageKeys.clear();
  }

  /// マップスタイルのロード完了時に呼ばれる
  void onStyleLoaded() {
    if (state.mapController == null) {
      return;
    }
    if (_cachedPosts != null) {
      _restorePinsFromCache();
    } else {
      _addPinsToMap();
    }
  }

  /// キャッシュされたピン情報からマップにピンを復元
  Future<void> _restorePinsFromCache() async {
    if (state.mapController == null ||
        _cachedPosts == null ||
        _cachedImageKeys == null) {
      return;
    }
    await state.mapController!.clearSymbols();
    for (final imageKey in _cachedImageKeys!.values) {
      final imageType = _cachedImageKeys!.entries
          .firstWhere((entry) => entry.value == imageKey)
          .key;
      if (_imageCache.containsKey(imageType)) {
        await state.mapController!.addImage(imageKey, _imageCache[imageType]!);
        _registeredImageKeys.add(imageKey);
      }
    }
    final symbols = _cachedPosts!.map((post) {
      final imageType = post.foodTag.isEmpty
          ? 'default'
          : post.foodTag.split(',').first.trim();
      return SymbolOptions(
        geometry: LatLng(post.lat, post.lng),
        iconImage: _cachedImageKeys![imageType],
        iconSize: _cachedIconSize ?? 0.6,
      );
    }).toList();

    if (symbols.isNotEmpty && state.mapController != null) {
      await state.mapController!.addSymbols(symbols);
      await state.mapController!.setSymbolIconIgnorePlacement(true);
      await state.mapController!.setSymbolIconAllowOverlap(true);
    }
  }

  void _addPinsToMap() {
    if (state.mapController == null) {
      return;
    }
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
    _generatePinImages(imageTypes, posts).then((imageKeys) {
      final symbols = posts.map((post) {
        final imageType = post.foodTag.isEmpty
            ? 'default'
            : post.foodTag.split(',').first.trim();
        return SymbolOptions(
          geometry: LatLng(post.lat, post.lng),
          iconImage: imageKeys[imageType],
          iconSize: 0.6,
        );
      }).toList();
      if (symbols.isNotEmpty && state.mapController != null) {
        state.mapController!.addSymbols(symbols);
        state.mapController!.setSymbolIconIgnorePlacement(true);
        state.mapController!.setSymbolIconAllowOverlap(true);
      }
    });
  }
}
