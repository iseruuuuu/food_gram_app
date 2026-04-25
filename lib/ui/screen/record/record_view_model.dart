import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:food_gram_app/core/home_widget/map_stats_home_widget_sync.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/repository/user_repository.dart';
import 'package:food_gram_app/core/utils/location/country_detector.dart';
import 'package:food_gram_app/core/utils/location/prefecture_detector.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/ui/component/app_pin_widget.dart';
import 'package:food_gram_app/ui/screen/map/components/map_prefecture_fill_layer.dart';
import 'package:food_gram_app/ui/screen/record/record_state.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:screenshot/screenshot.dart';

part 'record_view_model.g.dart';

@riverpod
class RecordViewModel extends _$RecordViewModel {
  @override
  RecordState build() {
    _preloadDefaultImages();
    return const RecordState();
  }

  bool isInitialLoading = true;
  final screenshotController = ScreenshotController();
  final Map<String, Uint8List> _imageCache = {};
  final Set<String> _registeredImageKeys = {};
  bool _symbolTapHandlerRegistered = false;

  List<Posts>? _cachedPosts;
  Map<String, String>? _cachedImageKeys;
  double? _cachedIconSize;

  /// タグがないピンのビットマップを一度だけキャッシュする。
  Future<void> _preloadDefaultImages() async {
    if (!_imageCache.containsKey('default')) {
      final screenshotBytes = await screenshotController.captureFromWidget(
        const AppFoodTagPinWidget(foodTag: ''),
      );
      _imageCache['default'] = screenshotBytes.buffer.asUint8List();
    }
  }

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
      final posts =
          ref.read(myMapRepositoryProvider).whenOrNull(data: (value) => value);
      if (posts == null) {
        return;
      }
      final prefecturePostCounts = _collectPrefecturePostCounts(posts);
      await MapPrefectureFillLayer.render(
        state.mapController!,
        prefecturePostCounts: prefecturePostCounts,
      );
      if (posts.isEmpty) {
        return;
      }
      final stats = _calculateStats(posts);
      final postingStreakWeeks = await _fetchPostingStreakWeeks();
      state = state.copyWith(
        visitedCitiesCount: stats.visitedCitiesCount,
        postsCount: stats.postsCount,
        completionPercentage: stats.completionPercentage,
        visitedPrefecturesCount: stats.visitedPrefecturesCount,
        visitedCountriesCount: stats.visitedCountriesCount,
        visitedAreasCount: stats.visitedAreasCount,
        activityDays: stats.activityDays,
        postingStreakWeeks: postingStreakWeeks,
      );
      MapStatsHomeWidgetSync.scheduleSyncAllModes(
        postsCount: stats.postsCount,
        visitedPrefecturesCount: stats.visitedPrefecturesCount,
        visitedCountriesCount: stats.visitedCountriesCount,
        visitedAreasCount: stats.visitedAreasCount,
        activityDays: stats.activityDays,
        postingStreakWeeks: postingStreakWeeks,
      );
      _cachedPosts = posts;
      _cachedIconSize = iconSize;
      final imageTypes = <String>{};
      for (final post in posts) {
        final type = post.foodTag.isEmpty
            ? 'default'
            : post.foodTag.split(',').first.trim();
        imageTypes.add(type);
      }
      final imageKeys = await _generatePinImages(imageTypes, posts);
      _cachedImageKeys = imageKeys;
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
        await _applySymbolOverlapPolicy();
      }
      if (!_symbolTapHandlerRegistered) {
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

  void changeViewType(MapViewType viewType) {
    state = state.copyWith(viewType: viewType);
  }

  void handleStyleChange() {
    if (state.mapController == null) {
      return;
    }
    _registeredImageKeys.clear();
  }

  void onStyleLoaded() {
    if (state.mapController == null) {
      return;
    }
    unawaited(_syncPrefectureFillLayer());
    if (_cachedPosts != null) {
      _restorePinsFromCache();
    } else {
      _addPinsToMap();
    }
  }

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
        iconSize: _cachedIconSize ?? 0.5,
      );
    }).toList();
    if (symbols.isNotEmpty && state.mapController != null) {
      await _addSymbolsInChunks(symbols);
      await _applySymbolOverlapPolicy();
    }
  }

  Future<void> _addPinsToMap() async {
    if (state.mapController == null) {
      return;
    }
    final posts =
        ref.read(myMapRepositoryProvider).whenOrNull(data: (value) => value);
    if (posts == null || posts.isEmpty) {
      return;
    }
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
        iconSize: 0.5,
      );
    }).toList();
    if (symbols.isNotEmpty && state.mapController != null) {
      await _addSymbolsInChunks(symbols);
      await _applySymbolOverlapPolicy();
    }
  }

  Future<void> _syncPrefectureFillLayer() async {
    if (state.mapController == null) {
      return;
    }
    final posts =
        ref.read(myMapRepositoryProvider).whenOrNull(data: (value) => value);
    if (posts == null) {
      return;
    }
    final prefecturePostCounts = _collectPrefecturePostCounts(posts);
    await MapPrefectureFillLayer.render(
      state.mapController!,
      prefecturePostCounts: prefecturePostCounts,
    );
  }

  /// ピン（シンボル）同士が重なっても欠けないよう、MapLibre の重なり表示設定を有効にする。
  Future<void> _applySymbolOverlapPolicy() async {
    if (state.mapController == null) {
      return;
    }
    await state.mapController!.setSymbolIconIgnorePlacement(true);
    await state.mapController!.setSymbolIconAllowOverlap(true);
  }

  /// シンボル一覧を一定件数ずつ addSymbols して、大量ピン時の UI 負荷を抑える。
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

  /// ログインユーザーの streak_weeks を取得し、最終投稿から 14 日超なら 0 週として返す週数を得る。
  Future<int> _fetchPostingStreakWeeks() async {
    final result =
        await ref.read(userRepositoryProvider.notifier).getCurrentUser();
    return result.when(
      success: (user) => effectivePostingStreakWeeks(
        lastPostDate: user.lastPostDate,
        streakWeeks: user.streakWeeks,
      ),
      failure: (_) => 0,
    );
  }

  /// 投稿座標から訪問地点・都道府県・国・細かいエリアのユニーク数と活動日数などを集計する。
  RecordMapStats _calculateStats(List<Posts> posts) {
    final validPosts =
        posts.where((post) => post.lat != 0 && post.lng != 0).toList();
    final uniqueLocations = <String>{};
    final visitedPrefectures = <String>{};
    final visitedCountries = <String>{};
    final visitedAreas = <String>{};
    for (final post in validPosts) {
      final locationKey =
          '${post.lat.toStringAsFixed(2)}_${post.lng.toStringAsFixed(2)}';
      uniqueLocations.add(locationKey);
      final areaKey =
          '${post.lat.toStringAsFixed(3)}_${post.lng.toStringAsFixed(3)}';
      visitedAreas.add(areaKey);
      final prefecture =
          PrefectureDetector.detectPrefecture(post.lat, post.lng);
      if (prefecture != null) {
        visitedPrefectures.add(prefecture);
      }
      final country = CountryDetector.detectCountry(post.lat, post.lng);
      if (country != null && country != 'その他') {
        visitedCountries.add(country);
      }
    }
    final completionPercentage =
        (visitedAreas.length / 100 * 100).clamp(0.0, 100.0);
    var activityDays = 0;
    if (validPosts.isNotEmpty) {
      final sortedPosts = validPosts.toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final firstPostDate = sortedPosts.first.createdAt;
      final lastPostDate = sortedPosts.last.createdAt;
      activityDays = lastPostDate.difference(firstPostDate).inDays;
    }
    return RecordMapStats(
      visitedCitiesCount: uniqueLocations.length,
      postsCount: posts.length,
      completionPercentage: completionPercentage,
      visitedPrefecturesCount: visitedPrefectures.length,
      visitedCountriesCount: visitedCountries.length,
      visitedAreasCount: visitedAreas.length,
      activityDays: activityDays,
    );
  }

  Map<String, int> _collectPrefecturePostCounts(List<Posts> posts) {
    final prefecturePostCounts = <String, int>{};
    for (final post in posts) {
      if (post.lat == 0 || post.lng == 0) {
        continue;
      }
      final prefecture =
          PrefectureDetector.detectPrefecture(post.lat, post.lng);
      if (prefecture != null) {
        prefecturePostCounts[prefecture] =
            (prefecturePostCounts[prefecture] ?? 0) + 1;
      }
    }
    return prefecturePostCounts;
  }

  /// 最終投稿から 14 日を超えている場合は週ストリークを 0 とみなし、それ以外は DB の週数をそのまま返す。
  int effectivePostingStreakWeeks({
    required DateTime? lastPostDate,
    required int streakWeeks,
    DateTime? now,
  }) {
    if (streakWeeks <= 0) {
      return 0;
    }
    final last = lastPostDate;
    final n = now ?? DateTime.now();
    if (last != null && n.difference(last).inDays > 14) {
      return 0;
    }
    return streakWeeks;
  }
}
