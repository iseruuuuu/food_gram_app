import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/data/supabase/map_service.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/utils/async_value_group.dart';
import 'package:food_gram_app/core/utils/location.dart';
import 'package:food_gram_app/env.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_map_restaurant_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/map/maplibre_controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

final String apiKey = Env.mapLibre;
const styleUrl =
    'https://tile.openstreetmap.jp/styles/maptiler-basic-ja/style.json';

class MapScreen extends HookConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapLibreController = ref.watch(mapLibreControllerProvider.notifier);
    final location = ref.watch(locationProvider);
    final mapService = ref.watch(mapServiceProvider);
    final isTapPin = useState(false);
    final post = useState<List<Posts?>>([]);
    return Scaffold(
      backgroundColor: Colors.white,
      body: AsyncValueSwitcher(
        asyncValue: AsyncValueGroup.group2(location, mapService),
        onData: (value) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              MapLibreMap(
                onMapCreated: (mapLibre) {
                  mapLibreController
                    ..controller = mapLibre
                    ..setPin(
                      openDialog: (posts) {
                        isTapPin.value = true;
                        post.value = posts;
                      },
                    );
                },
                onMapClick: (_, __) {
                  isTapPin.value = false;
                },
                annotationOrder: const [AnnotationType.symbol],
                key: ValueKey('mapWidget'),
                myLocationEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    value.$1.latitude,
                    value.$1.longitude,
                  ),
                  zoom: 15,
                ),
                trackCameraPosition: true,
                styleString: '$styleUrl?key=$apiKey',
              ),
              Visibility(
                visible: isTapPin.value,
                child: AppMapRestaurantModalSheet(post: post.value),
              ),
            ],
          );
        },
      ),
    );
  }
}
