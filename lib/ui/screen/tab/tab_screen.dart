import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/summary/summary_launch_gate.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/providers/post_count_rank_provider.dart';
import 'package:food_gram_app/core/supabase/user/services/user_service.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/theme/style/tab_style.dart';
import 'package:food_gram_app/core/utils/user_level.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/dialog/app_level_up_dialog.dart';
import 'package:food_gram_app/ui/screen/tab/tab_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TabScreen extends HookConsumerWidget {
  const TabScreen({super.key});

  static const double _barHeight = 64;
  static const double _postButtonSize = 64;

  /// バー上端からはみ出す量（小さいほどボタンが下に寄る）
  static const double _postButtonOverlap = 12;
  static const double _horizontalMargin = 16;
  static const double _bottomMargin = 8;

  /// フローティングボトムナビが占める高さ（シート等をその上に載せる用）
  ///
  /// [MediaQuery.removePadding] 配下でもセーフエリアを拾えるよう
  /// `viewPadding` を使う。
  static double bottomNavOccupiedHeight(BuildContext context) {
    return _barHeight +
        _postButtonOverlap +
        _bottomMargin +
        MediaQuery.viewPaddingOf(context).bottom;
  }

  /// 画面高さに対するボトムナビの占有比率
  static double bottomNavHeightFraction(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    if (screenHeight <= 0) {
      return 0;
    }
    return bottomNavOccupiedHeight(context) / screenHeight;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tabViewModelProvider());
    final controller = ref.watch(tabViewModelProvider().notifier);
    final t = Translations.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    useEffect(
      () {
        var cancelled = false;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (cancelled || !context.mounted) {
            return;
          }
          try {
            final now = DateTime.now();
            final posts = await ref.read(myPostStreamProvider.future);
            if (cancelled || !context.mounted) {
              return;
            }
            final launchType = await resolveSummaryLaunch(
              now: now,
              posts: posts,
            );
            if (launchType == null || cancelled || !context.mounted) {
              return;
            }
            await context.pushNamed(_routeNameForSummary(launchType));
            // 表示（プッシュ→ポップ）に成功したときだけ「表示済み」を記録する。
            // pushNamed が失敗した場合は例外で下の catch に飛ぶため、
            // 未表示のまま既読扱いになることを防げる。
            await markSummaryLaunchShown(type: launchType, now: now);
          } on Object {
            // 起動時のまとめ表示失敗は無視
          }
        });
        return () {
          cancelled = true;
        };
      },
      const [],
    );

    Future<void> onPostPressed() async {
      final selectedIndex = state.selectedIndex;
      if (selectedIndex == 2) {
        ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
              name: AnalyticsEvent.recordPostOpen,
            );
      }

      final oldPostCount =
          ref.read(myPostStreamProvider).valueOrNull?.length ?? 0;
      final result = await context.pushNamed(RouterPath.timeLinePost);
      if (result == null || !context.mounted) {
        return;
      }

      switch (selectedIndex) {
        case 0:
          ref.invalidate(mapPostRepositoryProvider);
        case 1:
          ref
            ..invalidate(postsStreamProvider)
            ..invalidate(blockListProvider);
        case 2:
          ref.invalidate(myMapRepositoryProvider);
          final uid = ref.read(currentUserProvider);
          if (uid != null) {
            ref.read(userServiceProvider.notifier).invalidateUserCache(uid);
          }
        case 3:
          ref.invalidate(myPostStreamProvider);
          final uid = ref.read(currentUserProvider);
          if (uid != null) {
            ref.invalidate(postCountRankProvider(uid));
          }
          await ref.read(myPostStreamProvider.future);
          final newPostCount =
              ref.read(myPostStreamProvider).valueOrNull?.length ?? 0;
          if (UserLevel.levelFromPostCount(newPostCount) >
                  UserLevel.levelFromPostCount(oldPostCount) &&
              context.mounted) {
            await showLevelUpDialog(
              context: context,
              level: UserLevel.levelFromPostCount(newPostCount),
            );
          }
      }
    }

    return MediaQuery.removePadding(
      context: context,
      removeBottom: Platform.isIOS,
      child: Scaffold(
        extendBody: true,
        body: Platform.isIOS
            ? controller.pageList[state.selectedIndex]
            : SafeArea(child: controller.pageList[state.selectedIndex]),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(
            _horizontalMargin,
            0,
            _horizontalMargin,
            _bottomMargin + (Platform.isIOS ? bottomInset : 0),
          ),
          child: SizedBox(
            height: _barHeight + _postButtonOverlap,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: _barHeight,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(_barHeight / 2),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white24
                            : Colors.grey.shade300,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TabItem(
                            selected: state.selectedIndex == 0,
                            icon: state.selectedIndex == 0
                                ? CupertinoIcons.map_fill
                                : CupertinoIcons.map,
                            label: t.tab.map,
                            onTap: () => controller.onTap(0),
                          ),
                        ),
                        Expanded(
                          child: _TabItem(
                            selected: state.selectedIndex == 1,
                            icon: state.selectedIndex == 1
                                ? Icons.fastfood
                                : Icons.fastfood_outlined,
                            label: t.tab.home,
                            onTap: () => controller.onTap(1),
                          ),
                        ),
                        const SizedBox(width: _postButtonSize),
                        Expanded(
                          child: _TabItem(
                            selected: state.selectedIndex == 2,
                            icon: state.selectedIndex == 2
                                ? CupertinoIcons.map_pin_ellipse
                                : CupertinoIcons.map_pin,
                            iconSize: 28,
                            label: t.tab.myMap,
                            onTap: () => controller.onTap(2),
                          ),
                        ),
                        Expanded(
                          child: _TabItem(
                            selected: state.selectedIndex == 3,
                            icon: state.selectedIndex == 3
                                ? CupertinoIcons.person_circle_fill
                                : CupertinoIcons.person_circle,
                            iconSize: 28,
                            label: t.tab.myPage,
                            onTap: () => controller.onTap(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom:
                      (_barHeight - _postButtonSize) / 2 + _postButtonOverlap,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onPostPressed,
                      customBorder: const CircleBorder(),
                      child: Ink(
                        width: _postButtonSize,
                        height: _postButtonSize,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconSize = 24,
  });

  final bool selected;
  final IconData icon;
  final double iconSize;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = TabStyle.tabColor(context, selected: selected);
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: color),
          const Gap(4),
          Text(
            label,
            style: TabStyle.tab(context, value: selected),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

String _routeNameForSummary(SummaryLaunchType type) {
  return switch (type) {
    SummaryLaunchType.monthly => RouterPath.monthlySummary,
    SummaryLaunchType.weekly => RouterPath.weeklySummary,
  };
}
