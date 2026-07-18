import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/summary/summary_launch_gate.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/theme/style/tab_style.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/screen/tab/tab_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TabScreen extends HookConsumerWidget {
  const TabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tabViewModelProvider());
    final controller = ref.watch(tabViewModelProvider().notifier);
    final t = Translations.of(context);

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
            await markSummaryLaunchShown(type: launchType, now: now);
            if (!context.mounted) {
              return;
            }
            await context.pushNamed(_routeNameForSummary(launchType));
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

    return MediaQuery.removePadding(
      context: context,
      removeBottom: Platform.isIOS,
      child: Scaffold(
        body: Platform.isIOS
            ? controller.pageList[state.selectedIndex]
            : SafeArea(child: controller.pageList[state.selectedIndex]),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: state.selectedIndex,
            onTap: controller.onTap,
            items: [
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    const Gap(12),
                    Icon(
                      state.selectedIndex == 0
                          ? CupertinoIcons.map_fill
                          : CupertinoIcons.map,
                      color: TabStyle.tabColor(
                        context,
                        selected: state.selectedIndex == 0,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      t.tab.map,
                      style: TabStyle.tab(
                        context,
                        value: state.selectedIndex == 0,
                      ),
                    ),
                    const Gap(10),
                  ],
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    const Gap(12),
                    Icon(
                      state.selectedIndex == 1
                          ? Icons.fastfood
                          : Icons.fastfood_outlined,
                      color: TabStyle.tabColor(
                        context,
                        selected: state.selectedIndex == 1,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      t.tab.home,
                      style: TabStyle.tab(
                        context,
                        value: state.selectedIndex == 1,
                      ),
                    ),
                    const Gap(10),
                  ],
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    const Gap(12),
                    Icon(
                      state.selectedIndex == 2
                          ? CupertinoIcons.map_pin_ellipse
                          : CupertinoIcons.map_pin,
                      size: 30,
                      color: TabStyle.tabColor(
                        context,
                        selected: state.selectedIndex == 2,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      t.tab.myMap,
                      style: TabStyle.tab(
                        context,
                        value: state.selectedIndex == 2,
                      ),
                    ),
                    const Gap(10),
                  ],
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    const Gap(12),
                    Icon(
                      state.selectedIndex == 3
                          ? CupertinoIcons.person_circle_fill
                          : CupertinoIcons.person_circle,
                      size: 30,
                      color: TabStyle.tabColor(
                        context,
                        selected: state.selectedIndex == 3,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      t.tab.myPage,
                      style: TabStyle.tab(
                        context,
                        value: state.selectedIndex == 3,
                      ),
                    ),
                    const Gap(10),
                  ],
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    const Gap(12),
                    Icon(
                      state.selectedIndex == 4
                          ? Icons.settings
                          : Icons.settings_outlined,
                      color: TabStyle.tabColor(
                        context,
                        selected: state.selectedIndex == 4,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      t.tab.setting,
                      style: TabStyle.tab(
                        context,
                        value: state.selectedIndex == 4,
                      ),
                    ),
                    const Gap(10),
                  ],
                ),
                label: '',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedItemColor: Theme.of(context).colorScheme.onSurface,
            unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
            iconSize: 26,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            enableFeedback: false,
          ),
        ),
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
