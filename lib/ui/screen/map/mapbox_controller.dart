import 'package:flutter/services.dart';
import 'package:food_gram_app/core/data/supabase/map_service.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mapbox_controller.g.dart';

@Riverpod(keepAlive: true)
class MapboxController extends _$MapboxController {
  @override
  void build() {}

  late MapboxMap mapboxMap;

  void getCurrentPin() {
    mapboxMap.location.updateSettings(
      LocationComponentSettings(
        // ユーザー位置情報表示
        enabled: true,
        // ユーザーの向きを表す矢印を表示
        puckBearingEnabled: true,
        // ユーザー位置情報のアイコンからパルスを表示
        pulsingEnabled: true,
        // 精度リングを表示
        showAccuracyRing: true,
      ),
    );
  }

  Future<void> setPin() async {
    await mapboxMap.annotations
        .createPointAnnotationManager()
        .then((pointAnnotationManager) async {
      final bytes = await rootBundle.load(Assets.image.pin.path);
      final list = bytes.buffer.asUint8List();
      final options = <PointAnnotationOptions>[];
      ref.read(mapServiceProvider).whenOrNull(
        data: (value) {
          for (var i = 0; i < value.length; i++) {
            options.add(
              //TODO ピンをタップすると、投稿内容を取得できる
              PointAnnotationOptions(
                geometry: Point(
                  coordinates: Position(
                    value[i].lng,
                    value[i].lat,
                  ),
                ),
                image: list,
                iconSize: 0.15,
              ),
            );
          }
        },
      );
      await pointAnnotationManager.createMulti(options);
    });
  }
}
