import 'dart:typed_data';

import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/ui/component/app_pin_widget.dart';
import 'package:food_gram_app/ui/screen/map/components/map_pin_data.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:screenshot/screenshot.dart';

/// ピン画像のキャッシュとマップへの登録
class MapPinImageLoader {
  MapPinImageLoader(this._screenshotController);

  final ScreenshotController _screenshotController;
  final Map<String, Uint8List> _cache = {};
  final Set<String> _registeredKeys = {};
  Future<void>? _baseImages;

  Map<String, Uint8List> get cache => _cache;
  Set<String> get registeredKeys => _registeredKeys;

  static const String smallRedDotKey = 'small_red_dot';

  /// デフォルト・赤ドットを事前生成
  Future<void> preload() {
    final running = _baseImages;
    if (running != null) {
      return running;
    }
    late final Future<void> run;
    run = () async {
      try {
        await _loadBaseImages();
      } on Object {
        if (identical(_baseImages, run)) {
          _baseImages = null;
        }
        rethrow;
      }
    }();
    _baseImages = run;
    return run;
  }

  Future<void> _loadBaseImages() async {
    if (!_cache.containsKey('default')) {
      final bytes = await _screenshotController.captureFromWidget(
        const AppFoodTagPinWidget(foodTag: ''),
      );
      _cache['default'] = bytes.buffer.asUint8List();
    }
    if (!_cache.containsKey(smallRedDotKey)) {
      final bytes = await _screenshotController.captureFromWidget(
        const AppSmallRedDotWidget(),
      );
      _cache[smallRedDotKey] = bytes.buffer.asUint8List();
    }
  }

  /// imageTypes に応じて画像を並列生成し、コントローラーに登録する。
  Future<Map<String, String>> generatePinImages(
    MapLibreMapController controller,
    Set<String> imageTypes,
    List<Posts> posts,
  ) async {
    final imageKeys = <String, String>{};
    final tasks = <Future<void>>[];

    for (final imageType in imageTypes) {
      final imageKey = 'pin_$imageType';
      imageKeys[imageType] = imageKey;
      if (_cache.containsKey(imageType)) {
        if (!_registeredKeys.contains(imageKey)) {
          tasks.add(registerImage(controller, imageKey, _cache[imageType]!));
        }
        continue;
      }
      final sample = _samplePost(imageType, posts);
      tasks.add(() async {
        final bytes = await _screenshotController.captureFromWidget(
          AppFoodTagPinWidget(foodTag: sample?.foodTag ?? ''),
        );
        _cache[imageType] = bytes.buffer.asUint8List();
        await registerImage(controller, imageKey, _cache[imageType]!);
      }());
    }

    await Future.wait(tasks);
    return imageKeys;
  }

  Posts? _samplePost(String imageType, List<Posts> posts) {
    for (final post in posts) {
      if (MapPinData.imageTypeFor(post) == imageType) {
        return post;
      }
    }
    if (imageType == 'default' || posts.isEmpty) {
      return null;
    }
    return posts.first;
  }

  /// 画像をコントローラーに1件登録（復元用）
  Future<void> registerImage(
    MapLibreMapController controller,
    String imageKey,
    Uint8List bytes,
  ) async {
    if (_registeredKeys.contains(imageKey)) {
      return;
    }
    await controller.addImage(imageKey, bytes);
    _registeredKeys.add(imageKey);
  }

  void clearRegisteredKeys() => _registeredKeys.clear();
}
