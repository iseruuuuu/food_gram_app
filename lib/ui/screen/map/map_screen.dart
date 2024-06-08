import 'package:flutter/material.dart';
import 'package:food_gram_app/core/utils/location.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/ui/screen/map/mapbox_controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapboxController = ref.watch(mapboxControllerProvider.notifier);
    final location = ref.watch(locationProvider);
    return Scaffold(
      body: location.when(
        data: (value) {
          return MapWidget(
            onMapCreated: (mapboxMap) {
              mapboxController
                ..mapboxMap = mapboxMap
                ..pin(value);
            },
            key: ValueKey('mapWidget'),
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(value.longitude, value.latitude),
              ),
              zoom: 16.5,
            ),
          );
        },
        error: (_, __) {
          //TODO エラー画面を作成する
          return Container();
        },
        loading: () {
          return Center(
            child: Assets.image.loading.image(
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
          );
        },
      ),
    );
  }
}
