import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/admob/services/admob_open.dart';
import 'package:food_gram_app/core/admob/tracking/ad_tracking_permission.dart';
import 'package:food_gram_app/core/local/force_update_checker.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/purchase/services/revenue_cat_service.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/core/utils/helpers/dialog_helper.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/env.dart';
import 'package:food_gram_app/ui/component/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_map_restaurant_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/map/map_view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

final String apiKey = Env.mapLibre;

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
    final appOpenAd = ref.watch(admobOpenNotifierProvider);
    useEffect(
      () {
        AdTrackingPermission().requestTracking();
        ref
            .read(revenueCatServiceProvider.notifier)
            .initInAppPurchase()
            .then((isSubscribed) {
          final value = math.Random().nextInt(10);
          if (value == 0) {
            appOpenAd.loadAd();
          }
        });
        ref.read(forceUpdateCheckerProvider.notifier).checkForceUpdate(
          openDialog: () {
            DialogHelper().forceUpdateDialog(context);
          },
        );
        return null;
      },
      [],
    );
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
                    key: const ValueKey('mapWidget'),
                    myLocationEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        value.$1.latitude,
                        value.$1.longitude,
                      ),
                      zoom: 16,
                    ),
                    trackCameraPosition: true,
                    tiltGesturesEnabled: false,
                    styleString:
                        'https://tile.openstreetmap.jp/styles/maptiler-basic-ja/style.json',
                  ),
                  Visibility(
                    visible: isTapPin.value,
                    child: AppMapRestaurantModalSheet(post: post.value),
                  ),
                  Positioned(
                    bottom: 40,
                    right: 10,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 8),
                          child: SizedBox(
                            width: 63,
                            height: 63,
                            child: Theme(
                              data: Theme.of(context)
                                  .copyWith(highlightColor: Colors.white),
                              child: FloatingActionButton(
                                heroTag: null,
                                shape: const RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.white),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                ),
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.white,
                                focusColor: Colors.white,
                                splashColor: Colors.white,
                                hoverColor: Colors.white,
                                elevation: 10,
                                onPressed: controller.moveToCurrentLocation,
                                child: const Icon(
                                  CupertinoIcons.location_fill,
                                  color: Color(0xFF1A73E8),
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
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
    return 0.6;
  } else if (screenWidth < 720) {
    return 0.6;
  } else {
    return 0.8;
  }
}
