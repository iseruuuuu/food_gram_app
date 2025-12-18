import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/ui/component/common/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/map/map_stats_card.dart';
import 'package:food_gram_app/ui/component/map/map_view_type_selector.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_map_restaurant_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/map/my_map/my_map_view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

// 日本の中心付近の座標
const defaultLocation = LatLng(36.2048, 137.9777);

class MyMapScreen extends HookConsumerWidget {
  const MyMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myMapViewModelProvider);
    final controller = ref.watch(myMapViewModelProvider.notifier);
    final location = ref.watch(locationProvider);
    final mapService = ref.watch(myMapRepositoryProvider);
    final isTapPin = useState(false);
    final post = useState<List<Posts?>>([]);
    final isEarthStyle = useState(false);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          AsyncValueSwitcher(
            asyncValue: AsyncValueGroup.group2(location, mapService),
            onErrorTap: () {
              ref
                ..invalidate(locationProvider)
                ..invalidate(myMapRepositoryProvider);
            },
            onData: (value) {
              final isLocationEnabled =
                  value.$1.latitude != 0 && value.$1.longitude != 0;
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
                    onStyleLoadedCallback: controller.onStyleLoaded,
                    annotationOrder: const [AnnotationType.symbol],
                    key: const ValueKey('myMapWidget'),
                    myLocationEnabled: isLocationEnabled,
                    initialCameraPosition: CameraPosition(
                      target: isLocationEnabled ? value.$1 : defaultLocation,
                      zoom: 7,
                    ),
                    trackCameraPosition: true,
                    tiltGesturesEnabled: false,
                    styleString:
                        _localizedStyleAsset(context, isEarthStyle.value),
                  ),
                  Visibility(
                    visible: isTapPin.value,
                    child: AppMapRestaurantModalSheet(post: post.value),
                  ),
                  Positioned(
                    top: _calculateTopPosition(context),
                    left: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        MapViewTypeSelector(
                          currentViewType: state.viewType,
                          onViewTypeChanged: controller.changeViewType,
                        ),
                        MapStatsCard(
                          visitedCitiesCount: state.visitedCitiesCount,
                          postsCount: state.postsCount,
                          completionPercentage: state.completionPercentage,
                          visitedPrefecturesCount:
                              state.visitedPrefecturesCount,
                          visitedCountriesCount: state.visitedCountriesCount,
                          visitedAreasCount: state.visitedAreasCount,
                          activityDays: state.activityDays,
                          viewType: state.viewType,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              if (isLocationEnabled)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 2, left: 8),
                                  child: SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        highlightColor: Colors.white,
                                      ),
                                      child: FloatingActionButton(
                                        heroTag: null,
                                        shape: const RoundedRectangleBorder(
                                          side: BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20),
                                          ),
                                        ),
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.white,
                                        focusColor: Colors.white,
                                        splashColor: Colors.white,
                                        hoverColor: Colors.white,
                                        elevation: 10,
                                        onPressed:
                                            controller.moveToCurrentLocation,
                                        child: const Icon(
                                          CupertinoIcons.location,
                                          color: Color(0xFF1A73E8),
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 12, left: 8),
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      highlightColor: Colors.white,
                                    ),
                                    child: FloatingActionButton(
                                      heroTag: 'compass',
                                      shape: const RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.white,
                                      focusColor: Colors.white,
                                      splashColor: Colors.white,
                                      hoverColor: Colors.white,
                                      elevation: 10,
                                      onPressed: controller.resetBearing,
                                      child: const Icon(
                                        CupertinoIcons.compass,
                                        color: Color.fromRGBO(26, 115, 232, 1),
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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

double _calculateTopPosition(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth <= 375) {
    return 25;
  } else if (screenWidth < 720) {
    return 50;
  } else {
    return 30;
  }
}

String _localizedStyleAsset(BuildContext context, bool isEarthStyle) {
  final lang = Localizations.localeOf(context).languageCode;

  if (isEarthStyle) {
    switch (lang) {
      case 'ja':
        return Assets.map.earthJa;
      default:
        return Assets.map.earthEn;
    }
  } else {
    switch (lang) {
      case 'ja':
        return Assets.map.localJa;
      default:
        return Assets.map.localEn;
    }
  }
}
