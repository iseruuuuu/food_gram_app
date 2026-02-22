import 'dart:typed_data';

import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/ui/component/app_pin_widget.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:screenshot/screenshot.dart';

/// ピン画像のキャッシュとマップへの登録
class MapPinImageLoader {
  MapPinImageLoader(this._screenshotController);

  final ScreenshotController _screenshotController;
  final Map<String, Uint8List> _cache = {};
  final Set<String> _registeredKeys = {};

  Map<String, Uint8List> get cache => _cache;
  Set<String> get registeredKeys => _registeredKeys;

  /// デフォルト・赤ドットを事前生成
  Future<void> preload() async {
    if (!_cache.containsKey('default')) {
      final bytes = await _screenshotController.captureFromWidget(
        const AppFoodTagPinWidget(foodTag: ''),
      );
      _cache['default'] = bytes.buffer.asUint8List();
    }
    if (!_cache.containsKey('small_red_dot')) {
      final bytes = await _screenshotController.captureFromWidget(
        const AppSmallRedDotWidget(),
      );
      _cache['small_red_dot'] = bytes.buffer.asUint8List();
    }
  }

  /// imageTypes に応じて画像を生成し、コントローラーに登録。imageKey の Map を返す。
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
          tasks.add(controller.addImage(imageKey, _cache[imageType]!));
          _registeredKeys.add(imageKey);
        }
      } else {
        final samplePost = posts.firstWhere(
          (p) =>
              (p.foodTag.isEmpty
                  ? 'default'
                  : p.foodTag.split(',').first.trim()) ==
              imageType,
          orElse: () => posts.first,
        );
        tasks.add(() async {
          final bytes = await _screenshotController.captureFromWidget(
            AppFoodTagPinWidget(foodTag: samplePost.foodTag),
          );
          _cache[imageType] = bytes.buffer.asUint8List();
          if (!_registeredKeys.contains(imageKey)) {
            await controller.addImage(imageKey, _cache[imageType]!);
            _registeredKeys.add(imageKey);
          }
        }());
      }
    }

    await Future.wait(tasks);
    return imageKeys;
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
