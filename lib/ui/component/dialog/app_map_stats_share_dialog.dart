import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/utils/helpers/share_helper.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/loading/app_overlay_loading.dart';
import 'package:food_gram_app/ui/component/share/map/map_stats_share.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// マイマップの達成率・投稿数を世界 or 日本で選んでシェアするダイアログ
class AppMapStatsShareDialog extends HookConsumerWidget {
  const AppMapStatsShareDialog({
    required this.postsCount,
    required this.visitedPrefecturesCount,
    required this.visitedCountriesCount,
    super.key,
  });

  final int postsCount;
  final int visitedPrefecturesCount;
  final int visitedCountriesCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final loading = useState(false);
    final selectedType = useState<MapViewType>(MapViewType.japan);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayFg = isDark ? colorScheme.onSurface : Colors.white;
    final overlayBtnBg = colorScheme.surface;
    final overlayBtnFg = colorScheme.onSurface;

    MapStatsShare buildShareWidget(MapViewType viewType) {
      return MapStatsShare(
        viewType: viewType,
        visitedPrefecturesCount: visitedPrefecturesCount,
        visitedCountriesCount: visitedCountriesCount,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  leading: IconButton(
                    onPressed: context.pop,
                    icon: Icon(
                      Icons.close,
                      color: overlayFg,
                      size: 30,
                    ),
                  ),
                  title: Text(
                    t.myMapShare.title,
                    style: TextStyle(
                      color: overlayFg,
                      fontSize: 20,
                    ),
                  ),
                ),
                Center(
                  child: FittedBox(
                    child: buildShareWidget(selectedType.value),
                  ),
                ),
                const Gap(16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SegmentedButton<MapViewType>(
                        segments: [
                          ButtonSegment<MapViewType>(
                            value: MapViewType.japan,
                            label: Text(t.mapViewType.japan),
                          ),
                          ButtonSegment<MapViewType>(
                            value: MapViewType.world,
                            label: Text(t.mapViewType.world),
                          ),
                        ],
                        selected: {selectedType.value},
                        onSelectionChanged: (selected) {
                          selectedType.value = selected.first;
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith((states) {
                            return states.contains(WidgetState.selected)
                                ? overlayBtnFg
                                : overlayBtnBg;
                          }),
                          foregroundColor:
                              WidgetStateProperty.resolveWith((states) {
                            return states.contains(WidgetState.selected)
                                ? overlayBtnBg
                                : overlayBtnFg;
                          }),
                        ),
                      ),
                      const Gap(20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: overlayBtnBg,
                            foregroundColor: overlayBtnFg,
                          ),
                          onPressed: () async {
                            final vt = selectedType.value;
                            ref
                                .read(firebaseAnalyticsServiceProvider)
                                .logEventUnawaited(
                              name: AnalyticsEvent.mapStatsShare,
                              parameters: {
                                AnalyticsParam.source: vt.name,
                                AnalyticsParam.shareType: 'text_and_image',
                              },
                            );
                            ref
                                .read(firebaseAnalyticsServiceProvider)
                                .logEventUnawaited(
                              name: AnalyticsEvent.mapShare,
                              parameters: {AnalyticsParam.source: vt.name},
                            );
                            final widget = buildShareWidget(vt);
                            await ShareHelpers().captureAndShare(
                              context: context,
                              widget: widget,
                              shareText: widget.shareMessage(t),
                              loading: loading,
                              hasText: true,
                              targetSize: MapStatsShare.size,
                              errorMessage: t.error.message,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.ios_share,
                                size: 25,
                                color: overlayBtnFg,
                              ),
                              const Gap(15),
                              Text(
                                t.share.textAndImage,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: overlayBtnFg,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: overlayBtnBg,
                            foregroundColor: overlayBtnFg,
                          ),
                          onPressed: () async {
                            final vt = selectedType.value;
                            ref
                                .read(firebaseAnalyticsServiceProvider)
                                .logEventUnawaited(
                              name: AnalyticsEvent.mapStatsShare,
                              parameters: {
                                AnalyticsParam.source: vt.name,
                                AnalyticsParam.shareType: 'image_only',
                              },
                            );
                            ref
                                .read(firebaseAnalyticsServiceProvider)
                                .logEventUnawaited(
                              name: AnalyticsEvent.mapShare,
                              parameters: {AnalyticsParam.source: vt.name},
                            );
                            final widget = buildShareWidget(vt);
                            await ShareHelpers().captureAndShare(
                              context: context,
                              widget: widget,
                              loading: loading,
                              hasText: false,
                              targetSize: MapStatsShare.size,
                              errorMessage: t.error.message,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_outlined,
                                size: 25,
                                color: overlayBtnFg,
                              ),
                              const Gap(15),
                              Text(
                                t.share.imageOnly,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: overlayBtnFg,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppProcessLoading(loading: loading.value, status: 'Loading...'),
        ],
      ),
    );
  }
}
