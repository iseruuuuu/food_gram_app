import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/admob/admob_gate.dart';
import 'package:food_gram_app/core/admob/services/admob_interstitial.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/config/constants/map_overlay_constants.dart';
import 'package:food_gram_app/core/model/restaurant_group.dart';
import 'package:food_gram_app/core/purchase/services/revenue_cat_service.dart';
import 'package:food_gram_app/core/supabase/post/providers/map_category_filter_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/location/locale_default_location.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/common/app_tab_error.dart';
import 'package:food_gram_app/ui/component/common/app_tab_loading.dart';
import 'package:food_gram_app/ui/component/modal_sheet/map_restaurant_detail_sheet.dart';
import 'package:food_gram_app/ui/component/modal_sheet/map_restaurant_overview_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/map/components/map_category_chip_bar.dart';
import 'package:food_gram_app/ui/screen/map/map_view_model.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

const mapPinTapAdInterval = 5;

class MapScreen extends HookConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapViewModelProvider);
    final controller = ref.watch(mapViewModelProvider.notifier);
    final location = ref.watch(locationProvider);
    final mapService = ref.watch(mapRepositoryProvider);
    final isEarthStyle = useState(false);
    final isSubscribeAsync = ref.watch(isSubscribeProvider);
    final pinTapCount = useRef(0);
    final isHandlingPinTap = useRef(false);
    final didApplyGpsCamera = useRef(false);
    final adInterstitial = ref.watch(admobInterstitialNotifierProvider);
    final isSubscribed = isSubscribeAsync.valueOrNull ?? false;
    final loading = ref.watch(loadingProvider);
    final fallbackLocation = useMemoized(defaultLocationFromDeviceLocale);
    final loc = location.valueOrNull;
    final isLocationEnabled =
        loc != null && (loc.latitude != 0 || loc.longitude != 0);
    final postsFailed = mapService.hasError && mapService.valueOrNull == null;
    final dataReady = location.hasValue && mapService.hasValue;
    final showMapLoading = !postsFailed && !dataReady;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fabBg = isDark ? Colors.black : Colors.white;
    const fabFg = AppTheme.primaryBlue;
    final fabBorder = AppTheme.fabBorderColor(context);
    ref.listen<MapModalSelection?>(mapModalSelectionProvider, (_, next) {
      if (next == null || next.placeSearchRestaurant == null) {
        unawaited(controller.clearSearchResultPin());
      }
    });
    ref.listen(locationProvider, (_, next) {
      final gps = next.valueOrNull;
      if (didApplyGpsCamera.value || gps == null) {
        return;
      }
      if (gps.latitude == 0 && gps.longitude == 0) {
        return;
      }
      if (ref.read(mapViewModelProvider).mapController == null) {
        return;
      }
      didApplyGpsCamera.value = true;
      unawaited(controller.applyInitialCameraZoom(gps));
    });
    ref.listen(filteredMapPostsProvider, (previous, next) {
      if (!next.hasValue || previous?.valueOrNull == next.valueOrNull) {
        return;
      }
      unawaited(controller.setPin());
    });
    return Scaffold(
      body: Stack(
        children: [
          if (postsFailed)
            AppTabError.map(
              onRetry: () {
                ref
                  ..invalidate(locationProvider)
                  ..invalidate(mapRepositoryProvider);
              },
            )
          else if (showMapLoading)
            const AppTabLoading.map()
          else
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                MapLibreMap(
                  onMapCreated: (mapLibre) async {
                    await controller.setMapController(
                      mapLibre,
                      onPinTap: (posts) async {
                        if (posts.isEmpty || isHandlingPinTap.value) {
                          return;
                        }
                        isHandlingPinTap.value = true;
                        try {
                          await ref
                              .read(firebaseAnalyticsServiceProvider)
                              .logMapPinTap(source: 'map');
                          final first = posts.first;
                          void openStoreSheet() {
                            ref.read(mapModalSelectionProvider.notifier).state =
                                MapModalSelection(
                              name: first.restaurant,
                              lat: first.lat,
                              lng: first.lng,
                            );
                          }

                          if (!canRequestAds(ref.read(isSubscribeProvider))) {
                            openStoreSheet();
                            return;
                          }
                          adInterstitial.createAd();
                          pinTapCount.value++;
                          if (pinTapCount.value >= mapPinTapAdInterval) {
                            pinTapCount.value = 0;
                            await adInterstitial.showAd(
                              onAdClosed: openStoreSheet,
                            );
                          } else {
                            openStoreSheet();
                          }
                        } finally {
                          isHandlingPinTap.value = false;
                        }
                      },
                      iconSize: _calculateIconSize(context),
                      initialCenter: isLocationEnabled ? loc : fallbackLocation,
                    );
                    final gps = ref.read(locationProvider).valueOrNull;
                    if (gps != null &&
                        (gps.latitude != 0 || gps.longitude != 0)) {
                      didApplyGpsCamera.value = true;
                      await controller.applyInitialCameraZoom(gps);
                    }
                  },
                  onStyleLoadedCallback: controller.onStyleLoaded,
                  onCameraIdle: controller.scheduleUpdateAfterCameraIdle,
                  onCameraMove: controller.onCameraMove,
                  annotationOrder: const [AnnotationType.symbol],
                  key: const ValueKey('mapWidget'),
                  myLocationEnabled: isLocationEnabled,
                  initialCameraPosition: CameraPosition(
                    target: isLocationEnabled ? loc : fallbackLocation,
                    zoom: isLocationEnabled
                        ? MapOverlayConstants.initial
                        : MapOverlayConstants.localeFallback,
                  ),
                  trackCameraPosition: true,
                  tiltGesturesEnabled: false,
                  styleString:
                      _localizedStyleAsset(context, isEarthStyle.value),
                ),
                // selection の状態に応じて Overview / Detail を内部で切り替える
                const MapRestaurantDetailSheet(),
                Positioned(
                  top: _calculateTopPosition(context),
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1) 一番上：検索バー（横幅いっぱい）
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: AppMapPlaceSearchTextField(
                          mapController: controller,
                        ),
                      ),
                      const Gap(8),
                      MapCategoryChipBar(
                        onCategoryChanged:
                            controller.refreshPinsForCategoryFilter,
                      ),
                      const Gap(8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _MapSideFab(
                                heroTag: 'style_toggle',
                                fabBg: fabBg,
                                fabFg: fabFg,
                                fabBorder: fabBorder,
                                icon: isEarthStyle.value
                                    ? CupertinoIcons.globe
                                    : CupertinoIcons.map,
                                onPressed: () async {
                                  if (!isSubscribed) {
                                    try {
                                      await ref
                                          .read(
                                            revenueCatServiceProvider.notifier,
                                          )
                                          .presentPaywallGuarded();
                                    } on Exception catch (_) {
                                      return;
                                    }
                                  } else {
                                    isEarthStyle.value = !isEarthStyle.value;
                                    controller.handleStyleChange();
                                  }
                                },
                              ),
                              if (isLocationEnabled) ...[
                                const Gap(8),
                                _MapSideFab(
                                  heroTag: 'map_current_location',
                                  fabBg: fabBg,
                                  fabFg: fabFg,
                                  fabBorder: fabBorder,
                                  icon: CupertinoIcons.location,
                                  onPressed: controller.moveToCurrentLocation,
                                ),
                              ],
                              const Gap(8),
                              _MapSideFab(
                                heroTag: 'compass',
                                fabBg: fabBg,
                                fabFg: fabFg,
                                fabBorder: fabBorder,
                                icon: CupertinoIcons.compass,
                                iconSize: 28,
                                onPressed: controller.resetBearing,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          AppMapLoading(
            loading: state.isLoading,
            hasError: state.hasError,
          ),
          AppProcessLoading(
            loading: loading,
            status: 'Loading...',
          ),
        ],
      ),
    );
  }
}

class _MapSideFab extends StatelessWidget {
  const _MapSideFab({
    required this.heroTag,
    required this.fabBg,
    required this.fabFg,
    required this.fabBorder,
    required this.icon,
    required this.onPressed,
    this.iconSize = 24,
  });

  final String heroTag;
  final Color fabBg;
  final Color fabFg;
  final Color fabBorder;
  final IconData icon;
  final double iconSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 55,
      height: 55,
      child: Theme(
        data: Theme.of(context).copyWith(highlightColor: fabBg),
        child: FloatingActionButton(
          heroTag: heroTag,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: fabBorder),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          foregroundColor: fabBg,
          backgroundColor: fabBg,
          focusColor: fabBg,
          splashColor: fabBg,
          hoverColor: fabBg,
          elevation: 10,
          onPressed: onPressed,
          child: Icon(icon, color: fabFg, size: iconSize),
        ),
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
    return 30;
  } else if (screenWidth < 720) {
    return 55;
  } else {
    return 35;
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
