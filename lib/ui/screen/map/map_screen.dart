import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/admob/services/admob_open.dart';
import 'package:food_gram_app/core/admob/tracking/ad_tracking_permission.dart';
import 'package:food_gram_app/core/config/constants/map_overlay_constants.dart';
import 'package:food_gram_app/core/local/force_update_checker.dart';
import 'package:food_gram_app/core/model/restaurant_group.dart';
import 'package:food_gram_app/core/notification/notification_initializer.dart';
import 'package:food_gram_app/core/purchase/services/revenue_cat_service.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/helpers/dialog_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/component/common/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/modal_sheet/map_restaurant_detail_sheet.dart';
import 'package:food_gram_app/ui/component/modal_sheet/map_restaurant_overview_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/map/components/map_category_chip_bar.dart';
import 'package:food_gram_app/ui/screen/map/map_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

// 日本の中心付近の座標
const defaultLocation = LatLng(36.2048, 137.9777);

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
    final adLoadAttempted = useRef(false);
    final isSubscribed = isSubscribeAsync.valueOrNull ?? false;
    final loading = ref.watch(loadingProvider);
    useEffect(
      () {
        // トラッキング許可を取得
        AdTrackingPermission().requestTracking();
        // 強制更新チェック
        ref.read(forceUpdateCheckerProvider.notifier).checkForceUpdate(
          openDialog: () {
            DialogHelper().forceUpdateDialog(context);
          },
        );
        // 通知の初期化
        initializeNotifications();
        return null;
      },
      [],
    );
    useEffect(
      () {
        if (adLoadAttempted.value) {
          return null;
        }
        adLoadAttempted.value = true;
        final value = math.Random().nextInt(8);
        if (value == 0) {
          ref.read(admobOpenNotifierProvider).loadAd();
        }
        return null;
      },
      [],
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fabBg = isDark ? Colors.black : Colors.white;
    const fabFg = AppTheme.primaryBlue;
    final fabBorder = isDark ? Colors.white54 : Colors.grey.shade300;
    ref.listen<MapModalSelection?>(mapModalSelectionProvider, (_, next) {
      if (next == null || next.placeSearchRestaurant == null) {
        unawaited(controller.clearSearchResultPin());
      }
    });
    return Scaffold(
      body: Stack(
        children: [
          AsyncValueSwitcher(
            asyncValue: AsyncValueGroup.group2(location, mapService),
            onErrorTap: () {
              ref
                ..invalidate(locationProvider)
                ..invalidate(mapPostRepositoryProvider);
            },
            onData: (value) {
              final isLocationEnabled =
                  value.$1.latitude != 0 && value.$1.longitude != 0;
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  MapLibreMap(
                    onMapCreated: (mapLibre) async {
                      final initialCenter =
                          isLocationEnabled ? value.$1 : defaultLocation;
                      await controller.setMapController(
                        mapLibre,
                        onPinTap: (posts) async {
                          if (posts.isEmpty) {
                            return;
                          }
                          final first = posts.first;
                          ref.read(mapModalSelectionProvider.notifier).state =
                              MapModalSelection(
                            name: first.restaurant,
                            lat: first.lat,
                            lng: first.lng,
                          );
                        },
                        iconSize: _calculateIconSize(context),
                        initialCenter: initialCenter,
                      );
                      if (isLocationEnabled) {
                        await controller.applyInitialCameraZoom(initialCenter);
                      }
                    },
                    onStyleLoadedCallback: controller.onStyleLoaded,
                    onCameraIdle: controller.scheduleUpdateAfterCameraIdle,
                    annotationOrder: const [AnnotationType.symbol],
                    key: const ValueKey('mapWidget'),
                    myLocationEnabled: isLocationEnabled,
                    initialCameraPosition: CameraPosition(
                      target: isLocationEnabled ? value.$1 : defaultLocation,
                      zoom: isLocationEnabled
                          ? MapOverlayConstants.initial
                          : MapOverlayConstants.countryOverview,
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
                                              revenueCatServiceProvider
                                                  .notifier,
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
              );
            },
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
      floatingActionButton: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return SizedBox(
            width: 60,
            height: 60,
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 10,
              shape: CircleBorder(
                side: BorderSide(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              onPressed: () async {
                await context
                    .pushNamed(RouterPath.timeLinePost)
                    .then((value) async {
                  if (value != null) {
                    ref.invalidate(mapPostRepositoryProvider);
                  }
                });
              },
              child: const Icon(Icons.add, size: 35),
            ),
          );
        },
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
      width: 50,
      height: 50,
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
