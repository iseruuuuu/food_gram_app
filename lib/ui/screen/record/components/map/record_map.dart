import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/ui/screen/record/components/map/record_map_button.dart';
import 'package:food_gram_app/ui/screen/record/components/map/record_map_post_sheet.dart';
import 'package:food_gram_app/ui/screen/record/components/map/record_map_stats_card.dart';
import 'package:food_gram_app/ui/screen/record/components/record_tab.dart';
import 'package:food_gram_app/ui/screen/record/record_state.dart';
import 'package:food_gram_app/ui/screen/record/record_view_model.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// 日本／世界マップ
class RecordMap extends HookWidget {
  const RecordMap({
    required this.state,
    required this.controller,
    required this.latitude,
    required this.longitude,
    super.key,
  });

  final RecordState state;
  final RecordViewModel controller;
  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    final isTapPin = useState(false);
    final post = useState<List<Posts?>>([]);
    final isEarthStyle = useState(false);
    final isLocationEnabled = latitude != 0 && longitude != 0;
    // 日本の中心付近の座標（位置情報オフ時の初期表示）
    const recordMapDefaultLocation = LatLng(36.2048, 137.9777);
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
              iconSize: recordMapIconSizeForContext(context),
            );
          },
          onMapClick: (_, __) => isTapPin.value = false,
          onStyleLoadedCallback: controller.onStyleLoaded,
          annotationOrder: const [AnnotationType.symbol],
          key: const ValueKey('recordMapLibre'),
          initialCameraPosition: CameraPosition(
            target: isLocationEnabled
                ? LatLng(latitude, longitude)
                : recordMapDefaultLocation,
            zoom: 7,
          ),
          trackCameraPosition: true,
          tiltGesturesEnabled: false,
          styleString: recordMapLocalizedStyleAsset(
            context,
            isEarthStyle: isEarthStyle.value,
          ),
        ),
        Visibility(
          visible: isTapPin.value,
          child: RecordMapPostSheet(post: post.value),
        ),
        Positioned(
          top: recordMapOverlayTopForContext(context),
          left: 0,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RecordTab(
                currentViewType: state.viewType,
                onViewTypeChanged: controller.changeViewType,
              ),
              RecordMapStatsCard(
                postsCount: state.postsCount,
                visitedPrefecturesCount: state.visitedPrefecturesCount,
                visitedCountriesCount: state.visitedCountriesCount,
                visitedAreasCount: state.visitedAreasCount,
                activityDays: state.activityDays,
                postingStreakWeeks: state.postingStreakWeeks,
                viewType: state.viewType,
              ),
              RecordMapButton(
                onResetBearing: controller.resetBearing,
                postsCount: state.postsCount,
                visitedPrefecturesCount: state.visitedPrefecturesCount,
                visitedCountriesCount: state.visitedCountriesCount,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

double recordMapOverlayTopForContext(BuildContext context) {
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

double recordMapIconSizeForContext(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth <= 375) {
    return 0.5;
  } else if (screenWidth < 720) {
    return 0.5;
  } else {
    return 0.5;
  }
}

/// ローカル（日本周辺）／地球スタイルの MapLibre スタイル URL
String recordMapLocalizedStyleAsset(
  BuildContext context, {
  required bool isEarthStyle,
}) {
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
