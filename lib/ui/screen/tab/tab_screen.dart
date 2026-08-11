import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/guide/first_post_guide_gate.dart';
import 'package:food_gram_app/core/model/posts.dart';
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
import 'package:food_gram_app/ui/component/common/keep_alive_page_view.dart';
import 'package:food_gram_app/ui/component/dialog/app_level_up_dialog.dart';
import 'package:food_gram_app/ui/component/guide/first_post_guide_overlay.dart';
import 'package:food_gram_app/ui/component/guide/first_post_success_dialog.dart';
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
  /// `viewPadding` を使う。inset の扱いをレイアウトと揃える。
  static double bottomNavOccupiedHeight(BuildContext context) {
    return _barHeight +
        _postButtonOverlap +
        _bottomMargin +
        _bottomSafeInset(context);
  }

  /// ボトムナビに加算するセーフエリア（iOS のみ。Android は Scaffold 側で処理）
  static double _bottomSafeInset(BuildContext context) {
    if (!Platform.isIOS) {
      return 0;
    }
    return MediaQuery.viewPaddingOf(context).bottom;
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
    final postButtonKey = useMemoized(GlobalKey.new);
    final showFirstPostGuide = useState(false);
    final pageController =
        useMemoized(() => PageController(initialPage: state.selectedIndex));

    // PageControllerをViewModelに設定し、適切にクリーンアップ
    useEffect(
      () {
        controller.setPageController(pageController);
        return () {
          // TabScreenがアンマウントされる時にPageControllerの参照をクリア
          controller.clearPageController(pageController);
        };
      },
      [], // pageControllerをキーに含めない（memoizedなので）
    );
    // PageControllerの破棄処理
    useEffect(() => pageController.dispose, []);
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
            if (launchType != null) {
              if (cancelled || !context.mounted) {
                return;
              }
              await context.pushNamed(_routeNameForSummary(launchType));
              // 表示（プッシュ→ポップ）に成功したときだけ「表示済み」を記録する。
              // pushNamed が失敗した場合は例外で下の catch に飛ぶため、
              // 未表示のまま既読扱いになることを防げる。
              await markSummaryLaunchShown(type: launchType, now: now);
            }

            // まとめ表示のあとに、初回投稿ガイドを判定する
            if (cancelled || !context.mounted) {
              return;
            }
            final shouldShow = await shouldShowFirstPostGuide(
              postCount: posts.length,
            );
            if (cancelled || !context.mounted || !shouldShow) {
              return;
            }
            showFirstPostGuide.value = true;
            ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
                  name: AnalyticsEvent.firstPostGuideShow,
                );
          } on Object {
            // 起動時のまとめ・ガイド表示失敗は無視
          }
        });
        return () {
          cancelled = true;
        };
      },
      const [],
    );

    Future<void> dismissFirstPostGuide({required bool tappedPost}) async {
      showFirstPostGuide.value = false;
      try {
        await markFirstPostGuideShown();
      } on Object {
        // 既読保存失敗でも analytics / 投稿導線は続行する
      }
      final analytics = ref.read(firebaseAnalyticsServiceProvider);
      analytics.logEventUnawaited(
        name: tappedPost
            ? AnalyticsEvent.firstPostGuideTap
            : AnalyticsEvent.firstPostGuideDismiss,
      );
    }

    Future<void> onPostPressed() async {
      final selectedIndex = state.selectedIndex;
      if (selectedIndex == 2) {
        ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
              name: AnalyticsEvent.recordPostOpen,
            );
      }

      // valueOrNull ?? 0 だと loading 中に「初回投稿」と誤判定されるため、
      // future で確定件数を取る。失敗時は初回扱いしない。
      int? previousPostCount;
      try {
        previousPostCount =
            (await ref.read(myPostStreamProvider.future)).length;
      } on Object {
        previousPostCount = null;
      }
      final isFirstPost = previousPostCount == 0;
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
          // 初回投稿完了ガイドがある場合はレベルアップ演出と重ねない
          if (!isFirstPost && previousPostCount != null) {
            try {
              final refreshedPosts =
                  await ref.read(myPostStreamProvider.future);
              final newPostCount = refreshedPosts.length;
              if (UserLevel.levelFromPostCount(newPostCount) >
                      UserLevel.levelFromPostCount(previousPostCount) &&
                  context.mounted) {
                await showLevelUpDialog(
                  context: context,
                  level: UserLevel.levelFromPostCount(newPostCount),
                );
              }
            } on Object {
              // 再取得失敗時はレベルアップ判定をスキップ
            }
          }
      }

      // 初回投稿完了ガイド（ストリーク等のあとに Tab へ戻ってから表示）
      if (isFirstPost && context.mounted) {
        final shouldShow = await shouldShowFirstPostSuccessGuide(
          previousPostCount: 0,
        );
        if (!shouldShow || !context.mounted) {
          return;
        }
        // 最新投稿を取得してプレビューに使う
        ref.invalidate(myPostStreamProvider);
        Posts? latestPost;
        try {
          final posts = await ref.read(myPostStreamProvider.future);
          latestPost = posts.isEmpty ? null : posts.last;
        } on Object {
          // プレビューなしでもガイドは出す
        }
        if (!context.mounted) {
          return;
        }
        ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
              name: AnalyticsEvent.firstPostSuccessGuideShow,
            );
        final action = await showFirstPostSuccessGuide(
          context: context,
          post: latestPost,
        );
        try {
          await markFirstPostSuccessGuideShown();
        } on Object {
          // 既読保存失敗でも地図/アルバム導線は続行する
        }
        if (!context.mounted || action == null) {
          return;
        }
        final analytics = ref.read(firebaseAnalyticsServiceProvider);
        switch (action) {
          case FirstPostSuccessAction.viewMap:
            analytics.logEventUnawaited(
              name: AnalyticsEvent.firstPostSuccessGuideMap,
            );
            await controller.onTap(0);
          case FirstPostSuccessAction.viewAlbum:
            analytics.logEventUnawaited(
              name: AnalyticsEvent.firstPostSuccessGuideAlbum,
            );
            await controller.onTap(3);
          case FirstPostSuccessAction.later:
            analytics.logEventUnawaited(
              name: AnalyticsEvent.firstPostSuccessGuideLater,
            );
        }
      }
    }

    return Stack(
      children: [
        MediaQuery.removePadding(
          context: context,
          removeBottom: Platform.isIOS,
          child: Scaffold(
            extendBody: true,
            // KeepAlivePageView でスムーズなアニメーション + 状態保持を実装
            body: Platform.isIOS
                ? KeepAlivePageView(
                    controller: pageController,
                    physics: const NeverScrollableScrollPhysics(), // スワイプ無効
                    children: controller.pageList,
                  )
                : SafeArea(
                    child: KeepAlivePageView(
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(), // スワイプ無効
                      children: controller.pageList,
                    ),
                  ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.fromLTRB(
                _horizontalMargin,
                0,
                _horizontalMargin,
                _bottomMargin + _bottomSafeInset(context),
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
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
                      bottom: (_barHeight - _postButtonSize) / 2 +
                          _postButtonOverlap,
                      child: Semantics(
                        button: true,
                        label: t.post.title,
                        child: Material(
                          key: postButtonKey,
                          color: Colors.transparent,
                          child: InkWell(
                            onTap:
                                showFirstPostGuide.value ? null : onPostPressed,
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showFirstPostGuide.value)
          FirstPostGuideOverlay(
            buttonKey: postButtonKey,
            onTapPost: () async {
              await dismissFirstPostGuide(tappedPost: true);
              if (context.mounted) {
                await onPostPressed();
              }
            },
            onDismiss: () async {
              await dismissFirstPostGuide(tappedPost: false);
            },
          ),
      ],
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
