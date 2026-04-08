import 'dart:convert';
import 'dart:io';

import 'package:food_gram_app/core/map/map_stats_presentation.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:home_widget/home_widget.dart';

/// マイマップ統計を iOS ホームウィジェット（HomeWidgetSample）へ同期する。
///
/// Runner / 拡張の entitlements に `group.com.FoodGram.ios` がある。Developer で同じ App Group を
/// `com.FoodGram.ios` と `com.FoodGram.ios.HomeWidgetSample` の Identifier に紐づけないと署名に失敗する。
/// データ反映は [syncAllModes]（マイマップでピン更新成功時など）。
class MapStatsHomeWidgetSync {
  MapStatsHomeWidgetSync._();

  static const appGroupId = 'group.com.FoodGram.ios';
  static const iosWidgetKind = 'HomeWidgetSample';

  static Future<void> configure() async {
    if (Platform.isIOS) {
      await HomeWidget.setAppGroupId(appGroupId);
    }
  }

  /// マイマップの統計と同じ入力で、3モード分を書き込みウィジェットを更新する。
  static Future<void> syncAllModes({
    required int postsCount,
    required int visitedPrefecturesCount,
    required int visitedCountriesCount,
    required int visitedAreasCount,
    required int activityDays,
    required int postingStreakWeeks,
  }) async {
    if (!Platform.isIOS) {
      return;
    }
    final t = LocaleSettings.instance.currentTranslations;
    for (final viewType in MapViewType.values) {
      final pres = MapStatsPresentation.build(
        t: t,
        viewType: viewType,
        postsCount: postsCount,
        visitedPrefecturesCount: visitedPrefecturesCount,
        visitedCountriesCount: visitedCountriesCount,
        visitedAreasCount: visitedAreasCount,
        activityDays: activityDays,
        postingStreakWeeks: postingStreakWeeks,
      );
      await HomeWidget.saveWidgetData<String>(
        'map_stats_${viewType.name}',
        jsonEncode(pres.toJson()),
      );
    }
    await HomeWidget.updateWidget(
      name: iosWidgetKind,
      iOSName: iosWidgetKind,
    );
  }
}
