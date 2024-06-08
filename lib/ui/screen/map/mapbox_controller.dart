import 'package:flutter/services.dart';
import 'package:food_gram_app/core/utils/location.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mapbox_controller.g.dart';

@Riverpod(keepAlive: true)
class MapboxController extends _$MapboxController {
  @override
  void build() {}

  late MapboxMap mapboxMap;

  Future<void> pin(LatLng location) async {
    final location = ref.watch(locationProvider).value;
    final pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    final bytes = await rootBundle.load(Assets.image.currentPin.path);
    final image = bytes.buffer.asUint8List();
    final options = PointAnnotationOptions(
      image: image,
      iconSize: 0.15,
      geometry: Point(
        coordinates: Position(
          location!.longitude,
          location.latitude,
        ),
      ),
    );
    await pointAnnotationManager.create(options);
  }
