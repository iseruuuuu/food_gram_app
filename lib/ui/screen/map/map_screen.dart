import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/env.dart';
import 'package:food_gram_app/ui/component/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/app_floating_button.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_map_restaurant_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/map/map_view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

final String apiKey = Env.mapLibre;
const styleUrl =
    'https://tile.openstreetmap.jp/styles/maptiler-basic-ja/style.json';

class MapScreen extends HookConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapViewModelProvider);
    final controller = ref.watch(mapViewModelProvider.notifier);
    final location = ref.watch(locationProvider);
    final mapService = ref.watch(mapRepositoryProvider);
    final isTapPin = useState(false);
    final post = useState<List<Posts?>>([]);
    final isTapped = useState(false);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          AsyncValueSwitcher(
            asyncValue: AsyncValueGroup.group2(location, mapService),
            onErrorTap: () {
              ref
                ..invalidate(locationProvider)
                ..invalidate(postRepositoryProvider);
            },
            onData: (value) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  MapLibreMap(
                    onMapCreated: (mapLibre) {
                      controller.setMapController(
                        mapLibre,
                        onPinTap: (posts) {
                          isTapPin.value = true;
                          post.value = posts;
                        },
                        iconSize: _calculateIconSize(context),
                      );
                    },
                    onMapClick: (_, __) => isTapPin.value = false,
                    annotationOrder: const [AnnotationType.symbol],
                    key: ValueKey('mapWidget'),
                    myLocationEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        value.$1.latitude,
                        value.$1.longitude,
                      ),
                      zoom: 14,
                    ),
                    trackCameraPosition: true,
                    tiltGesturesEnabled: false,
                    styleString: '$styleUrl?key=$apiKey',
                  ),
                  Visibility(
                    visible: isTapPin.value,
                    child: AppMapRestaurantModalSheet(post: post.value),
                  ),
                  Positioned(
                    top: 40,
                    right: 10,
                    child: Column(
                      children: [
                        MapFloatingActionButton(
                          onPressed: controller.moveToCurrentLocation,
                        ),
                        Divider(height: 1),
                        MapRamenFloatingActionButton(
                          onPressed: () {
                            if (isTapped.value) {
                              ref.read(mapViewModelProvider.notifier).setPin(
                                    onPinTap: (posts) {
                                      isTapPin.value = true;
                                      post.value = posts;
                                    },
                                    iconSize: _calculateIconSize(context),
                                  );
                            } else {
                              ref
                                  .read(mapViewModelProvider.notifier)
                                  .setRamenPin(
                                    onPinTap: (posts) {
                                      isTapPin.value = true;
                                      post.value = posts;
                                    },
                                    iconSize: _calculateIconSize(context),
                                  );
                            }
                            isTapped.value = !isTapped.value;

                            print(isTapped.value);
                          },
                          isTapped: isTapped.value,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          AppMapLoading(
            loading: state.isLoading,
            hasError: state.hasError,
          ),
        ],
      ),
    );
  }
}

double _calculateIconSize(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth <= 375) {
    return 0.4;
  } else if (screenWidth < 720) {
    return 0.6;
  } else {
    return 0.8;
  }
}
