import 'package:flutter/services.dart';
import 'package:food_gram_app/core/data/supabase/map_service.dart';
import 'package:food_gram_app/core/model/posts.dart';
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

  Future<void> setPin({
    required void Function(List<Posts> post) openDialog,
  }) async {
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
      pointAnnotationManager.addOnPointAnnotationClickListener(
        AnnotationClickListener(ref, openDialog, mapboxMap),
      );
    });
  }
}

class AnnotationClickListener extends OnPointAnnotationClickListener {
  AnnotationClickListener(
    this.ref,
    this.openDialog,
    this.controller,
  );

  final NotifierProviderRef<void> ref;
  final void Function(List<Posts> post) openDialog;
  final MapboxMap controller;

  @override
  Future<void> onPointAnnotationClick(PointAnnotation annotation) async {
    final result = await ref
        .read(getRestaurantProvider(point: annotation.geometry).future);
    final lat = annotation.geometry.coordinates.lat.toDouble();
    final lng = annotation.geometry.coordinates.lng.toDouble();
    await controller.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(lng, lat)),
        zoom: 16.5,
      ),
      MapAnimationOptions(duration: 1000),
    );
    openDialog(result);
  }
}
