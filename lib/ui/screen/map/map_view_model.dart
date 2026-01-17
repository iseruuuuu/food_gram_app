import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
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

  final screenshotController = ScreenshotController();
  final Map<String, Uint8List> _imageCache = {};
  final Set<String> _registeredImageKeys = {};
  bool _symbolTapHandlerRegistered = false;

  // ピン情報をキャッシュ
  List<Posts>? _cachedPosts;
  Map<String, String>? _cachedImageKeys;

  // ランタイムスタイル（SymbolLayer）を使用するためのID
  static const String _runtimeSourceId = 'fg_posts_source';
  static const String _runtimeLayerId = 'fg_posts_layer';

  /// JSONレイヤーの icon-size と同等の線形補間（Annotation用フォールバック）
  double _interpolatedIconSize(double zoom) {
    // アンカー: 3.5->0.17, 5->0.21, 7->0.25, 9->0.31, 10.5->0.35, 12->0.41,
    // 13->0.47, 14->0.53, 15->0.57, 16->0.61, 17->0.61, 22->0.61
    final anchors = <double, double>{
      3.5: 0.17,
      5.0: 0.21,
      7.0: 0.25,
      9.0: 0.31,
      10.5: 0.35,
      12.0: 0.41,
      13.0: 0.47,
      14.0: 0.53,
      15.0: 0.57,
      16.0: 0.61,
      17.0: 0.61,
      22.0: 0.61,
    };
    final keys = anchors.keys.toList()..sort();
    final z = zoom.clamp(keys.first, keys.last);
    for (var i = 0; i < keys.length - 1; i++) {
      final z0 = keys[i];
      final z1 = keys[i + 1];
      if (z >= z0 && z <= z1) {
        final s0 = anchors[z0]!;
        final s1 = anchors[z1]!;
        final t = (z - z0) / (z1 - z0);
        return s0 + (s1 - s0) * t;
      }
    }
    return anchors.values.last;
  }

  String _latLngKey(double lat, double lng, {int fractionDigits = 6}) {
    // 小数点以下を丸めたキーで安定比較（DB由来の微小誤差対策）
    return '${lat.toStringAsFixed(fractionDigits)},'
        '${lng.toStringAsFixed(fractionDigits)}';
  }

  /// 同一座標の投稿を1つにまとめる（代表選出は非空の foodTag を優先）
  List<Posts> _dedupeByLatLng(List<Posts> posts) {
    final deduped = <String, Posts>{};
    for (final post in posts) {
      final key = _latLngKey(post.lat, post.lng);
      final existing = deduped[key];
      if (existing == null) {
        deduped[key] = post;
      } else {
        final existingHasTag = existing.foodTag.isNotEmpty;
        final currentHasTag = post.foodTag.isNotEmpty;
        if (!existingHasTag && currentHasTag) {
          deduped[key] = post;
        }
      }
    }
    return deduped.values.toList();
  }

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
    await updateVisibleMealsCount();
  }

  Future<void> setPin({
    required void Function(List<Posts> posts) onPinTap,
    required double iconSize,
  }) async {
    try {
      // 投稿データを取得
      final posts =
          ref.read(mapRepositoryProvider).whenOrNull(data: (value) => value);
      if (posts == null || posts.isEmpty) {
        return;
      }
      // 同一座標の重複排除
      final uniqueLocationPosts = _dedupeByLatLng(posts);
      // ピン情報をキャッシュ（重複排除後）
      _cachedPosts = uniqueLocationPosts;
      // ピン画像の種類を収集
      final imageTypes = <String>{};
      for (final post in uniqueLocationPosts) {
        final type = post.foodTag.isEmpty
            ? 'default'
            : post.foodTag.split(',').first.trim();
        imageTypes.add(type);
      }
      // 画像を並列で生成してマップに追加
      final imageKeys =
          await _generatePinImages(imageTypes, uniqueLocationPosts);
      _cachedImageKeys = imageKeys;
      await _addSymbolsAnnotation(imageKeys, uniqueLocationPosts);
      if (!_symbolTapHandlerRegistered) {
        state.mapController?.onSymbolTapped.add((symbol) async {
          state = state.copyWith(isLoading: true);
          final latLng = symbol.options.geometry;
          if (latLng == null) {
            state = state.copyWith(isLoading: false);
            return;
          }
          final restaurant = await ref
              .read(mapPostRepositoryProvider.notifier)
              .getRestaurantPosts(lat: latLng.latitude, lng: latLng.longitude);
          restaurant.whenOrNull(success: (posts) => onPinTap(posts));
          await state.mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(latLng, 14),
            duration: const Duration(seconds: 1),
          );
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

  /// スタイル切り替え時の処理
  void handleStyleChange() {
    if (state.mapController == null) {
      return;
    }
    // 旧スタイルのシンボル削除＋タップ登録のリセット
    state.mapController!.clearSymbols();
    _registeredImageKeys.clear();
    _symbolTapHandlerRegistered = false;
  }

  /// マップスタイルのロード完了時に呼ばれる
  void onStyleLoaded() {
    if (state.mapController == null) {
      return;
    }
    // キャッシュがあれば高速復元、なければ通常追加
    if (_cachedPosts != null && _cachedImageKeys != null) {
      _restorePinsFromCache();
    } else {
      _addPinsToMap();
    }
    updateVisibleMealsCount();
  }

  /// 表示範囲内の投稿件数を計算して状態に反映
  Future<void> updateVisibleMealsCount() async {
    final ctrl = state.mapController;
    if (ctrl == null) {
      return;
    }
    final posts =
        ref.read(mapRepositoryProvider).whenOrNull(data: (value) => value);
    if (posts == null || posts.isEmpty) {
      state = state.copyWith(visibleMealsCount: 0);
      return;
    }
    try {
      final bounds = await ctrl.getVisibleRegion();
      var count = 0;
      for (final post in posts) {
        if (bounds.contains(LatLng(post.lat, post.lng))) {
          count++;
        }
      }
      state = state.copyWith(visibleMealsCount: count);
    } on Exception catch (_) {
      // 取得失敗時はそのまま
    }
  }

  /// キャッシュからピンを復元（画像の再登録→シンボル再追加）
  Future<void> _restorePinsFromCache() async {
    if (state.mapController == null ||
        _cachedPosts == null ||
        _cachedImageKeys == null) {
      return;
    }
    await state.mapController!.clearSymbols();
    // スタイル切替後は画像登録が失われるため、キャッシュ画像を再登録
    for (final entry in _cachedImageKeys!.entries) {
      final imageType = entry.key;
      final imageKey = entry.value;
      final bytes = _imageCache[imageType];
      if (bytes != null) {
        await state.mapController!.addImage(imageKey, bytes);
        _registeredImageKeys.add(imageKey);
      }
    }
    // シンボル再追加
    final symbols = _cachedPosts!.map((post) {
      final imageType = post.foodTag.isEmpty
          ? 'default'
          : post.foodTag.split(',').first.trim();
      final zoom = state.mapController?.cameraPosition?.zoom ?? 14.0;
      return SymbolOptions(
        geometry: LatLng(post.lat, post.lng),
        iconImage: _cachedImageKeys![imageType],
        iconSize: _interpolatedIconSize(zoom),
      );
    }).toList();
    if (symbols.isNotEmpty) {
      await _addSymbolsInChunks(symbols);
      await state.mapController!.setSymbolIconIgnorePlacement(true);
      await state.mapController!.setSymbolIconAllowOverlap(true);
    }
  }

  Future<void> _addPinsToMap() async {
    if (state.mapController == null) {
      return;
    }
    // 投稿データを取得
    final posts =
        ref.read(mapRepositoryProvider).whenOrNull(data: (value) => value);
    if (posts == null || posts.isEmpty) {
      return;
    }
    // 同一座標の重複排除
    final uniqueLocationPosts = _dedupeByLatLng(posts);
    // ピン画像の種類を収集
    final imageTypes = <String>{};
    for (final post in uniqueLocationPosts) {
      final type = post.foodTag.isEmpty
          ? 'default'
          : post.foodTag.split(',').first.trim();
      imageTypes.add(type);
    }
    final imageKeys = await _generatePinImages(imageTypes, uniqueLocationPosts);
    await _setupRuntimeLayer(imageKeys, uniqueLocationPosts);
  }

  // Annotation追加（フォールバック用）
  Future<void> _addSymbolsAnnotation(
    Map<String, String> imageKeys,
    List<Posts> posts,
  ) async {
    if (state.mapController == null) {
      return;
    }
    await state.mapController!.clearSymbols();
    final symbols = posts.map((post) {
      final imageType = post.foodTag.isEmpty
          ? 'default'
          : post.foodTag.split(',').first.trim();
      final zoom = state.mapController?.cameraPosition?.zoom ?? 14.0;
      return SymbolOptions(
        geometry: LatLng(post.lat, post.lng),
        iconImage: imageKeys[imageType],
        iconSize: _interpolatedIconSize(zoom),
      );
    }).toList();
    if (symbols.isEmpty) {
      return;
    }
    await _addSymbolsInChunks(symbols);
    await state.mapController!.setSymbolIconIgnorePlacement(true);
    await state.mapController!.setSymbolIconAllowOverlap(true);
  }

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

  /// ランタイムスタイル（SymbolLayer）を追加・更新
  Future<void> _setupRuntimeLayer(
    Map<String, String> imageKeys,
    List<Posts> posts,
  ) async {
    if (state.mapController == null) {
      return;
    }
    // GeoJSON FeatureCollection を構築
    final features = posts.map((post) {
      final imageType = post.foodTag.isEmpty
          ? 'default'
          : post.foodTag.split(',').first.trim();
      return {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [post.lng, post.lat],
        },
        'properties': {
          'icon': imageKeys[imageType],
          'lat': post.lat,
          'lng': post.lng,
          'selected': false,
        },
      };
    }).toList();
    final source = {
      'type': 'geojson',
      'data': {
        'type': 'FeatureCollection',
        'features': features,
      },
    };
    // レイヤー定義（通常表示）
    final layerJsonString =
        await rootBundle.loadString(Assets.map.overlayPostsLayer);
    final layer = jsonDecode(layerJsonString) as Map<String, dynamic>
      ..['id'] = _runtimeLayerId
      ..['source'] = _runtimeSourceId;
    // レイヤー定義（選択表示）
    final selectedLayerJsonString =
        await rootBundle.loadString(Assets.map.overlayPostsSelectedLayer);
    final selectedLayer =
        jsonDecode(selectedLayerJsonString) as Map<String, dynamic>
          ..['id'] = '${_runtimeLayerId}_selected'
          ..['source'] = _runtimeSourceId;
    final dynamic c = state.mapController;
    try {
      try {
        await c.removeLayer(_runtimeLayerId);
      } on Exception catch (_) {}
      try {
        await c.removeSource(_runtimeSourceId);
      } on Exception catch (_) {}
      await c.addSource(_runtimeSourceId, source);
      await c.addLayer(layer);
      await c.addLayer(selectedLayer);
    } on Exception catch (_) {
      await _addSymbolsAnnotation(imageKeys, posts);
    }
  }
}
