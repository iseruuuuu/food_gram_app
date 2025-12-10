import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/admob/services/admob_open.dart';
import 'package:food_gram_app/core/admob/tracking/ad_tracking_permission.dart';
import 'package:food_gram_app/core/local/force_update_checker.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/utils/helpers/dialog_helper.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/ui/component/app_premium_membership_card.dart';
import 'package:food_gram_app/ui/component/common/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_map_restaurant_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/map/map_view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

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
    final isTapPin = useState(false);
    final post = useState<List<Posts?>>([]);
    final isEarthStyle = useState(false);
    final isSubscribeAsync = ref.watch(isSubscribeProvider);
    final adLoadAttempted = useRef(false);
    final isSubscribeState = useState<bool?>(null);
    useEffect(
      () {
        isSubscribeAsync.whenData((value) {
          isSubscribeState.value = value;
        });
        return null;
      },
      [isSubscribeAsync],
    );
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

    return Scaffold(
      backgroundColor: Colors.white,
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
                    key: const ValueKey('mapWidget'),
                    myLocationEnabled: isLocationEnabled,
                    initialCameraPosition: CameraPosition(
                      target: isLocationEnabled ? value.$1 : defaultLocation,
                      zoom: isLocationEnabled ? 16 : 3.8,
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
                        if (!isSubscribeState.value!)
                          const AppPremiumMembershipCard(),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, bottom: 8),
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Theme(
                                    data: Theme.of(context)
                                        .copyWith(highlightColor: Colors.white),
                                    child: FloatingActionButton(
                                      heroTag: 'style_toggle',
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
                                      onPressed: () async {
                                        if (!isSubscribeState.value!) {
                                          try {
                                            await RevenueCatUI.presentPaywall();
                                            ref.invalidate(
                                              isSubscribeProvider,
                                            );
                                          } on Exception catch (_) {
                                            return;
                                          }
                                        } else {
                                          isEarthStyle.value =
                                              !isEarthStyle.value;
                                          // スタイル切り替え時にピンを再表示
                                          controller.handleStyleChange();
                                        }
                                      },
                                      child: Icon(
                                        isEarthStyle.value
                                            ? CupertinoIcons.globe
                                            : CupertinoIcons.map,
                                        color: const Color(0xFF1A73E8),
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
                              // 方位調整ボタン
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
