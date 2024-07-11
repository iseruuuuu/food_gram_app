import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/data/supabase/map_service.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/utils/async_value_group.dart';
import 'package:food_gram_app/core/utils/location.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/map/mapbox_controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

class MapScreen extends HookConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapboxController = ref.watch(mapboxControllerProvider.notifier);
    final location = ref.watch(locationProvider);
    final mapService = ref.watch(mapServiceProvider);
    final isTapPin = useState(false);
    final post = useState<List<Posts?>>([]);
    return Scaffold(
      body: AsyncValueSwitcher(
        asyncValue: AsyncValueGroup.group2(location, mapService),
        onData: (value) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              mapbox.MapWidget(
                onMapCreated: (mapboxMap) {
                  mapboxController
                    ..mapboxMap = mapboxMap
                    ..getCurrentPin()
                    ..setPin(
                      openDialog: (posts) {
                        isTapPin.value = true;
                        post.value = posts;
                      },
                    );
                },
                key: ValueKey('mapWidget'),
                styleUri: 'mapbox://styles/ryuuuuu/clxpeougo00k001pu6d8o8tq3',
                cameraOptions: mapbox.CameraOptions(
                  center: mapbox.Point(
                    coordinates: mapbox.Position(
                      value.$1.longitude,
                      value.$1.latitude,
                    ),
                  ),
                  zoom: 16.5,
                ),
              ),
              Visibility(
                visible: isTapPin.value,
                child: RestaurantInfoModalSheet(post: post.value),
              ),
            ],
          );
        },
      ),
    );
  }
}
