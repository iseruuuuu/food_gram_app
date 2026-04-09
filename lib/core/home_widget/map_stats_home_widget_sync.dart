import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/utils/map_stats_presentation.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:home_widget/home_widget.dart';
import 'package:logger/logger.dart';

/// マイマップ統計を iOS ホームウィジェット（HomeWidgetSample）へ同期する。
///
/// Runner / 拡張の entitlements に `group.com.FoodGram.ios` がある。Developer で同じ App Group を
/// `com.FoodGram.ios` と `com.FoodGram.ios.HomeWidgetSample`の 
///  Identifier に紐づけないと署名に失敗する。
/// データ反映は [syncAllModes]（マイマップでピン更新成功時など）。
class MapStatsHomeWidgetSync {
  MapStatsHomeWidgetSync._();

  static final _log = Logger();

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

  /// [syncAllModes] を非同期で走らせ、失敗時のみログする（未処理例外を避ける）。
  static void scheduleSyncAllModes({
    required int postsCount,
    required int visitedPrefecturesCount,
    required int visitedCountriesCount,
    required int visitedAreasCount,
    required int activityDays,
    required int postingStreakWeeks,
  }) {
    unawaited(
      syncAllModes(
        postsCount: postsCount,
        visitedPrefecturesCount: visitedPrefecturesCount,
        visitedCountriesCount: visitedCountriesCount,
        visitedAreasCount: visitedAreasCount,
        activityDays: activityDays,
        postingStreakWeeks: postingStreakWeeks,
      ).catchError((Object e, StackTrace st) {
        _log.w(
          'MapStatsHomeWidgetSync.syncAllModes failed',
          error: e,
          stackTrace: st,
        );
      }),
    );
  }
}
