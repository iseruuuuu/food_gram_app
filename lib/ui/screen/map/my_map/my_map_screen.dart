import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/services/user_service.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/dialog/app_map_stats_share_dialog.dart';
import 'package:food_gram_app/ui/component/map/app_map_stats_card.dart';
import 'package:food_gram_app/ui/component/map/app_map_view_type_selector.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_mymap_restaurant_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/map/my_map/my_map_view_model.dart';
import 'package:go_router/go_router.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fabBg = isDark ? Colors.black : Colors.white;
    const fabFg = AppTheme.primaryBlue;
    final fabBorder = isDark ? Colors.white54 : Colors.grey.shade300;
    return Scaffold(
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
                    child: AppMyMapRestaurantModalSheet(post: post.value),
                  ),
                  Positioned(
                    top: _calculateTopPosition(context),
                    left: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppMapViewTypeSelector(
                          currentViewType: state.viewType,
                          onViewTypeChanged: controller.changeViewType,
                        ),
                        AppMapStatsCard(
                          postsCount: state.postsCount,
                          visitedPrefecturesCount:
                              state.visitedPrefecturesCount,
                          visitedCountriesCount: state.visitedCountriesCount,
                          visitedAreasCount: state.visitedAreasCount,
                          activityDays: state.activityDays,
                          postingStreakWeeks: state.postingStreakWeeks,
                          viewType: state.viewType,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 12, left: 8),
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      highlightColor: fabBg,
                                    ),
                                    child: FloatingActionButton(
                                      heroTag: 'compass',
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color: fabBorder),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      foregroundColor: fabBg,
                                      backgroundColor: fabBg,
                                      focusColor: fabBg,
                                      splashColor: fabBg,
                                      hoverColor: fabBg,
                                      elevation: 10,
                                      onPressed: controller.resetBearing,
                                      child: const Icon(
                                        CupertinoIcons.compass,
                                        color: fabFg,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 12, left: 8),
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      highlightColor: fabBg,
                                    ),
                                    child: FloatingActionButton(
                                      heroTag: 'shareMapStats',
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color: fabBorder),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      foregroundColor: fabBg,
                                      backgroundColor: fabBg,
                                      focusColor: fabBg,
                                      splashColor: fabBg,
                                      hoverColor: fabBg,
                                      elevation: 10,
                                      onPressed: () {
                                        showGeneralDialog<void>(
                                          context: context,
                                          pageBuilder: (_, __, ___) {
                                            return AppMapStatsShareDialog(
                                              postsCount: state.postsCount,
                                              visitedPrefecturesCount:
                                                  state.visitedPrefecturesCount,
                                              visitedCountriesCount:
                                                  state.visitedCountriesCount,
                                            );
                                          },
                                        );
                                      },
                                      child: const Icon(
                                        Icons.ios_share,
                                        color: fabFg,
                                        size: 24,
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
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
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
                ref.invalidate(myMapRepositoryProvider);
                final uid = ref.read(currentUserProvider);
                if (uid != null) {
                  ref
                      .read(userServiceProvider.notifier)
                      .invalidateUserCache(uid);
                }
              }
            });
          },
          child: const Icon(Icons.add, size: 35),
        ),
      ),
    );
  }
}

double _calculateIconSize(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth <= 375) {
    return 0.5;
  } else if (screenWidth < 720) {
    return 0.5;
  } else {
    return 0.5;
  }
}

double _calculateTopPosition(BuildContext context) {
  final topInset = MediaQuery.of(context).padding.top;
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth <= 375) {
    return topInset + 8;
  } else if (screenWidth < 720) {
    return topInset + 16;
  } else {
    return topInset + 12;
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
