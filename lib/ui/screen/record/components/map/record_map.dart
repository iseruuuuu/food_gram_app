import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/ui/component/map/record_map_layout.dart';
import 'package:food_gram_app/ui/screen/record/components/map/record_map_button.dart';
import 'package:food_gram_app/ui/screen/record/components/map/record_map_stats_card.dart';
import 'package:food_gram_app/ui/screen/record/components/record_tab.dart';

/// 記録タブ：日本／世界マップ時の上部オーバーレイ（切替・統計・FAB）
class RecordMap extends StatelessWidget {
  const RecordMap({
    required this.viewType,
    required this.onViewTypeChanged,
    required this.postsCount,
    required this.visitedPrefecturesCount,
    required this.visitedCountriesCount,
    required this.visitedAreasCount,
    required this.activityDays,
    required this.postingStreakWeeks,
    required this.onResetBearing,
    super.key,
  });

  final MapViewType viewType;
  final void Function(MapViewType) onViewTypeChanged;
  final int postsCount;
  final int visitedPrefecturesCount;
  final int visitedCountriesCount;
  final int visitedAreasCount;
  final int activityDays;
  final int postingStreakWeeks;
  final VoidCallback onResetBearing;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: recordMapOverlayTopForContext(context),
      left: 0,
      right: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          RecordTab(
            currentViewType: viewType,
            onViewTypeChanged: onViewTypeChanged,
          ),
          RecordMapStatsCard(
            postsCount: postsCount,
            visitedPrefecturesCount: visitedPrefecturesCount,
            visitedCountriesCount: visitedCountriesCount,
            visitedAreasCount: visitedAreasCount,
            activityDays: activityDays,
            postingStreakWeeks: postingStreakWeeks,
            viewType: viewType,
          ),
          RecordMapButton(
            onResetBearing: onResetBearing,
            postsCount: postsCount,
            visitedPrefecturesCount: visitedPrefecturesCount,
            visitedCountriesCount: visitedCountriesCount,
          ),
        ],
      ),
    );
  }
}
