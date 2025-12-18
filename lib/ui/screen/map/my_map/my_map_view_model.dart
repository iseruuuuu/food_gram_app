import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/utils/location/country_detector.dart';
import 'package:food_gram_app/core/utils/location/prefecture_detector.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/ui/component/app_pin_widget.dart';
import 'package:food_gram_app/ui/screen/map/my_map/my_map_state.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:screenshot/screenshot.dart';

part 'my_map_view_model.g.dart';

@riverpod
class MyMapViewModel extends _$MyMapViewModel {
  @override
  MyMapState build() {
    _preloadDefaultImages();
    return const MyMapState();
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
      // 自分の投稿データを取得
      final posts =
          ref.read(myMapRepositoryProvider).whenOrNull(data: (value) => value);
      if (posts == null || posts.isEmpty) {
        return;
      }

      // 統計情報を計算
      final stats = _calculateStats(posts);
      state = state.copyWith(
        visitedCitiesCount: stats.visitedCitiesCount,
        postsCount: stats.postsCount,
        completionPercentage: stats.completionPercentage,
        visitedPrefecturesCount: stats.visitedPrefecturesCount,
        visitedCountriesCount: stats.visitedCountriesCount,
        visitedAreasCount: stats.visitedAreasCount,
        activityDays: stats.activityDays,
      );

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
        await _addSymbolsInChunks(symbols);
        await state.mapController?.setSymbolIconIgnorePlacement(false);
        await state.mapController?.setSymbolIconAllowOverlap(false);
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
          CameraUpdate.newLatLngZoom(currentLatLng, 7),
        );
      },
    );
  }

  /// 方位をリセット（北を上にする）
  Future<void> resetBearing() async {
    if (state.mapController == null) {
      return;
    }
    final currentPosition = state.mapController!.cameraPosition;
    await state.mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentPosition?.target ?? const LatLng(0, 0),
          zoom: currentPosition?.zoom ?? 0,
          tilt: currentPosition?.tilt ?? 0,
        ),
      ),
    );
  }

  /// ビュータイプを変更
  void changeViewType(MapViewType viewType) {
    state = state.copyWith(viewType: viewType);
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
      await _addSymbolsInChunks(symbols);
      await state.mapController!.setSymbolIconIgnorePlacement(false);
      await state.mapController!.setSymbolIconAllowOverlap(false);
    }
  }

  Future<void> _addPinsToMap() async {
    if (state.mapController == null) {
      return;
    }
    // 自分の投稿データを取得
    final posts =
        ref.read(myMapRepositoryProvider).whenOrNull(data: (value) => value);
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
    final imageKeys = await _generatePinImages(imageTypes, posts);
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
      await _addSymbolsInChunks(symbols);
      await state.mapController!.setSymbolIconIgnorePlacement(false);
      await state.mapController!.setSymbolIconAllowOverlap(false);
    }
  }

  /// シンボルをチャンクに分けて追加し、UI スレッド負荷を軽減
  Future<void> _addSymbolsInChunks(
    List<SymbolOptions> symbols, {
    int chunkSize = 250,
  }) async {
    if (state.mapController == null || symbols.isEmpty) {
      return;
    }
    final total = symbols.length;
    for (var start = 0; start < total; start += chunkSize) {
      if (state.mapController == null) {
        break;
      }
      final end = math.min(start + chunkSize, total);
      final chunk = symbols.sublist(start, end);
      await state.mapController!.addSymbols(chunk);
    }
  }

  /// 統計情報を計算
  _MapStats _calculateStats(List<Posts> posts) {
    // 緯度経度が0の投稿を除外
    final validPosts =
        posts.where((post) => post.lat != 0 && post.lng != 0).toList();

    // ユニークな位置を計算（訪問都市数）
    final uniqueLocations = <String>{};
    final visitedPrefectures = <String>{};
    final visitedCountries = <String>{};
    final visitedAreas = <String>{};

    for (final post in validPosts) {
      // 緯度経度を小数点2桁で丸めて、同じ場所とみなす
      final locationKey =
          '${post.lat.toStringAsFixed(2)}_${post.lng.toStringAsFixed(2)}';
      uniqueLocations.add(locationKey);

      // 詳細エリア（小数点3桁で丸める = 約100mの精度）
      final areaKey =
          '${post.lat.toStringAsFixed(3)}_${post.lng.toStringAsFixed(3)}';
      visitedAreas.add(areaKey);

      // 都道府県を判定
      final prefecture =
          PrefectureDetector.detectPrefecture(post.lat, post.lng);
      if (prefecture != null) {
        visitedPrefectures.add(prefecture);
      }

      // 国を判定（'その他'は除外）
      final country = CountryDetector.detectCountry(post.lat, post.lng);
      if (country != null && country != 'その他') {
        visitedCountries.add(country);
      }
    }

    // 地図埋め率を計算（訪問エリア数ベース）
    final completionPercentage =
        (visitedAreas.length / 100 * 100).clamp(0.0, 100.0);

    // 活動日数を計算（初投稿から最後の投稿までの日数）
    var activityDays = 0;
    if (validPosts.isNotEmpty) {
      final sortedPosts = validPosts.toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final firstPostDate = sortedPosts.first.createdAt;
      final lastPostDate = sortedPosts.last.createdAt;
      activityDays = lastPostDate.difference(firstPostDate).inDays;
    }

    return _MapStats(
      visitedCitiesCount: uniqueLocations.length,
      postsCount: posts.length,
      completionPercentage: completionPercentage,
      visitedPrefecturesCount: visitedPrefectures.length,
      visitedCountriesCount: visitedCountries.length,
      visitedAreasCount: visitedAreas.length,
      activityDays: activityDays,
    );
  }
}

/// 統計情報を保持するクラス
class _MapStats {
  const _MapStats({
    required this.visitedCitiesCount,
    required this.postsCount,
    required this.completionPercentage,
    required this.visitedPrefecturesCount,
    required this.visitedCountriesCount,
    required this.visitedAreasCount,
    required this.activityDays,
  });

  final int visitedCitiesCount;
  final int postsCount;
  final double completionPercentage;
  final int visitedPrefecturesCount;
  final int visitedCountriesCount;
  final int visitedAreasCount;
  final int activityDays;
}
