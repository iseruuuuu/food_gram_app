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
    // ループ全体で同一ロケール・同一翻訳を使う（途中でロケールが変わると
    // currentTranslations と _widgetPayloadJson の判定が食い違うのを防ぐ）
    final settings = LocaleSettings.instance;
    final syncLocale = settings.currentLocale;
    // translationMap に無い currentLocale は起動直後などであり得るため ! は使わない
    final t =
        settings.translationMap[syncLocale] ?? settings.currentTranslations;
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
      final payload = _widgetPayloadJson(
        pres,
        activityDays: activityDays,
        syncLocale: syncLocale,
      );
      await HomeWidget.saveWidgetData<String>(
        'map_stats_${viewType.name}',
        jsonEncode(payload),
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

  /// ホームウィジェット幅向けに、日本語だけサマリーを短くする（アプリ内カードの文言は変えない）。
  ///
  /// [syncLocale] は [syncAllModes] 開始時点のロケールを渡すこと（ループ中の
  /// `LocaleSettings.instance.currentLocale` 参照は使わない）。
  static Map<String, dynamic> _widgetPayloadJson(
    MapStatsPresentation pres, {
    required int activityDays,
    required AppLocale syncLocale,
  }) {
    final json = pres.toJson();
    if (syncLocale != AppLocale.ja) {
      return json;
    }
    final days = activityDays < 0 ? 0 : activityDays;
    final compactSummary = switch (pres.viewType) {
      MapViewType.detail => '$days日の食事が、記録に残っています✨', // 「分」「として」を省略（ウィジェット幅向け）
      MapViewType.japan => pres.summary,
      MapViewType.world => pres.summary,
    };
    json['summary'] = compactSummary;
    return json;
  }
}
