import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/services/user_service.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/dialog/app_map_stats_share_dialog.dart';
import 'package:food_gram_app/ui/component/map/app_map_stats_card.dart';
import 'package:food_gram_app/ui/component/map/app_map_view_type_selector.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_mymap_restaurant_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/map/my_map/my_map_view_model.dart';
import 'package:gap/gap.dart';
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
              if (state.viewType == MapViewType.detail) {
                return _MyMapRecordView(posts: value.$2);
              }
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
                        AppMyMapStatsCard(
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

class _MyMapRecordView extends ConsumerWidget {
  const _MyMapRecordView({required this.posts});

  final List<Posts> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF161616) : Colors.white;
    final mutedColor = isDark ? Colors.white70 : Colors.black54;
    final recentPosts = [...posts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final latest3 = recentPosts.take(3).toList();
    final yearlyCounts = <int, int>{};
    for (final post in posts) {
      final year = post.createdAt.year;
      yearlyCounts[year] = (yearlyCounts[year] ?? 0) + 1;
    }
    final sortedYears = yearlyCounts.keys.toList()..sort();

    final uniqueVisitedPlaces = posts
        .where((p) => p.lat != 0 && p.lng != 0)
        .map((p) => '${p.lat.toStringAsFixed(2)}_${p.lng.toStringAsFixed(2)}')
        .toSet()
        .length;
    final activityDays = _calculateActivityDays(posts);
    final selectorTop = _calculateTopPosition(context);
    const selectorHeightOffset = 68.0;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            selectorTop + selectorHeightOffset,
            16,
            16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.mapStats.recordSummary.replaceAll(
                            '{days}',
                            activityDays.toString(),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                        const Gap(6),
                        Text(
                          t.myMapRecord.subtitle,
                          style: TextStyle(
                            color: mutedColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Transform.translate(
                      offset: const Offset(8, 0),
                      child: Assets.image.record.image(
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              Row(
                children: [
                  _RecordStatItem(
                    emoji: '📍',
                    value: '$uniqueVisitedPlaces',
                    label: t.mapStats.visitedArea,
                    valueColor: const Color(0xFF2563EB),
                  ),
                  const Gap(8),
                  _RecordStatItem(
                    emoji: '🍜',
                    value: '${posts.length}',
                    label: t.myMapRecord.postedMealsLabel,
                    valueColor: const Color(0xFFEA4335),
                  ),
                  const Gap(8),
                  _RecordStatItem(
                    emoji: '📅',
                    value: '$activityDays',
                    label: t.myMapRecord.streakDaysLabel,
                    valueColor: const Color(0xFF16A34A),
                  ),
                ],
              ),
              const Gap(16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.myMapRecord.yearlyTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(12),
                    if (sortedYears.isEmpty)
                      Text(
                        t.myMapRecord.noPostsYet,
                        style: TextStyle(color: mutedColor),
                      )
                    else
                      SizedBox(
                        height: 105,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: sortedYears.length,
                          separatorBuilder: (_, __) => const Gap(10),
                          itemBuilder: (context, index) {
                            final year = sortedYears[index];
                            final postCount = yearlyCounts[year] ?? 0;
                            final firstPostOfYear = recentPosts.firstWhere(
                              (p) => p.createdAt.year == year,
                              orElse: () => recentPosts.first,
                            );
                            return _YearRecordItem(
                              year: year,
                              count: postCount,
                              post: firstPostOfYear,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const Gap(16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.myMapRecord.recentTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(12),
                    if (latest3.isEmpty)
                      Text(
                        t.myMapRecord.noPostsYet,
                        style: TextStyle(color: mutedColor),
                      )
                    else
                      Column(
                        children: latest3
                            .map((post) => _RecentRecordItem(post: post))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: selectorTop,
          left: 0,
          right: 0,
          child: AppMapViewTypeSelector(
            currentViewType: MapViewType.detail,
            onViewTypeChanged:
                ref.read(myMapViewModelProvider.notifier).changeViewType,
          ),
        ),
      ],
    );
  }

  int _calculateActivityDays(List<Posts> source) {
    if (source.isEmpty) {
      return 0;
    }
    final sorted = [...source]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return sorted.last.createdAt.difference(sorted.first.createdAt).inDays;
  }
}

class _RecordStatItem extends StatelessWidget {
  const _RecordStatItem({
    required this.emoji,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String emoji;
  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161616) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const Gap(4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _YearRecordItem extends ConsumerWidget {
  const _YearRecordItem({
    required this.year,
    required this.count,
    required this.post,
  });

  final int year;
  final int count;
  final Posts post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storageKey = post.firstFoodImage;
    final imageUrl = storageKey.isEmpty
        ? null
        : ref
            .read(supabaseProvider)
            .storage
            .from('food')
            .getPublicUrl(storageKey);

    return SizedBox(
      width: 84,
      child: Column(
        children: [
          Text(
            '$year',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(6),
          CircleAvatar(
            radius: 24,
            backgroundColor:
                isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            backgroundImage: imageUrl == null ? null : NetworkImage(imageUrl),
            child: imageUrl == null
                ? Icon(
                    Icons.restaurant,
                    size: 20,
                    color: isDark ? Colors.white54 : Colors.black45,
                  )
                : null,
          ),
          const Gap(6),
          Text(
            '$count ${t.myMapRecord.countUnit}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _RecentRecordItem extends ConsumerWidget {
  const _RecentRecordItem({required this.post});

  final Posts post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storageKey = post.firstFoodImage;
    final imageUrl = storageKey.isEmpty
        ? null
        : ref
            .read(supabaseProvider)
            .storage
            .from('food')
            .getPublicUrl(storageKey);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 74,
              height: 74,
              child: imageUrl == null
                  ? ColoredBox(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      child: Icon(
                        Icons.fastfood,
                        color: isDark ? Colors.white54 : Colors.black38,
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => ColoredBox(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: isDark ? Colors.white54 : Colors.black38,
                        ),
                      ),
                    ),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.foodName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const Gap(2),
                Text(
                  post.restaurant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.favorite, size: 18, color: Color(0xFFEF4444)),
              const Gap(2),
              Text(
                '${post.heart}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ],
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
