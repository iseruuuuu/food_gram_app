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

  /// 短時間に何度も同期が走ると UserDefaults / Widget 更新が重なり不安定になるため、
  /// 最後の呼び出しから少し待ってから1回だけ実行する。
  static const _syncDebounceDuration = Duration(milliseconds: 500);
  static Timer? _debounceTimer;
  static _WidgetSyncArgs? _pendingArgs;
  static Future<void>? _syncChain;

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
    try {
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
    } catch (e, st) {
      _log.w(
        'MapStatsHomeWidgetSync.syncAllModes failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// [syncAllModes] を非同期で走らせる。短時間の連続呼び出しはデバウンスして1回にまとめる。
  static void scheduleSyncAllModes({
    required int postsCount,
    required int visitedPrefecturesCount,
    required int visitedCountriesCount,
    required int visitedAreasCount,
    required int activityDays,
    required int postingStreakWeeks,
  }) {
    _pendingArgs = _WidgetSyncArgs(
      postsCount: postsCount,
      visitedPrefecturesCount: visitedPrefecturesCount,
      visitedCountriesCount: visitedCountriesCount,
      visitedAreasCount: visitedAreasCount,
      activityDays: activityDays,
      postingStreakWeeks: postingStreakWeeks,
    );
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_syncDebounceDuration, () {
      _debounceTimer = null;
      final args = _pendingArgs;
      _pendingArgs = null;
      if (args == null) {
        return;
      }
      // 前の同期が残っているときは直列に続ける（ネイティブ側の同時書き込みを避ける）
      _syncChain = (_syncChain ?? Future<void>.value()).then(
        (_) => syncAllModes(
          postsCount: args.postsCount,
          visitedPrefecturesCount: args.visitedPrefecturesCount,
          visitedCountriesCount: args.visitedCountriesCount,
          visitedAreasCount: args.visitedAreasCount,
          activityDays: args.activityDays,
          postingStreakWeeks: args.postingStreakWeeks,
        ),
      );
      unawaited(_syncChain!);
    });
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

class _WidgetSyncArgs {
  const _WidgetSyncArgs({
    required this.postsCount,
    required this.visitedPrefecturesCount,
    required this.visitedCountriesCount,
    required this.visitedAreasCount,
    required this.activityDays,
    required this.postingStreakWeeks,
  });

  final int postsCount;
  final int visitedPrefecturesCount;
  final int visitedCountriesCount;
  final int visitedAreasCount;
  final int activityDays;
  final int postingStreakWeeks;
}
