import 'package:flutter/material.dart';
import 'package:food_gram_app/core/data/supabase/map_service.dart';
import 'package:food_gram_app/core/utils/async_value_group.dart';
import 'package:food_gram_app/core/utils/location.dart';
import 'package:food_gram_app/ui/screen/map/mapbox_controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapboxController = ref.watch(mapboxControllerProvider.notifier);
    final location = ref.watch(locationProvider);
    final mapService = ref.watch(mapServiceProvider);
    return Scaffold(
      body: AsyncValueSwitcher(
        asyncValue: AsyncValueGroup.group2(location, mapService),
        onData: (value) {
          //TODO 登録したレストラン以外のピンを外したい
          return MapWidget(
            onMapCreated: (mapboxMap) {
              mapboxController
                ..mapboxMap = mapboxMap
                ..getCurrentPin()
                ..setPin()
                ..removeOtherPin();
            },
            key: ValueKey('mapWidget'),
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(
                  value.$1!.longitude,
                  value.$1!.latitude,
                ),
              ),
              zoom: 16.5,
            ),
          );
        },
      ),
    );
  }
}
