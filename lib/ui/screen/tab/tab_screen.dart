import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/theme/style/tab_style.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/screen/tab/tab_view_model.dart';
import 'package:gap/gap.dart';

class TabScreen extends ConsumerWidget {
  const TabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tabViewModelProvider());
    final controller = ref.watch(tabViewModelProvider().notifier);
    final l10n = L10n.of(context);
    return MediaQuery.removePadding(
      context: context,
      removeBottom: Platform.isIOS,
      child: Scaffold(
        backgroundColor: Colors.white,
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
                    ),
                    const Gap(6),
                    Text(
                      l10n.tabMap,
                      style: TabStyle.tab(value: state.selectedIndex == 0),
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
                    ),
                    const Gap(6),
                    Text(
                      l10n.tabHome,
                      style: TabStyle.tab(value: state.selectedIndex == 1),
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
                          ? CupertinoIcons.search_circle_fill
                          : CupertinoIcons.search_circle,
                      size: 30,
                    ),
                    const Gap(6),
                    Text(
                      l10n.tabSearch,
                      style: TabStyle.tab(value: state.selectedIndex == 2),
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
                    ),
                    const Gap(6),
                    Text(
                      l10n.tabMyPage,
                      style: TabStyle.tab(value: state.selectedIndex == 3),
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
                    ),
                    const Gap(6),
                    Text(
                      l10n.tabSetting,
                      style: TabStyle.tab(value: state.selectedIndex == 4),
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
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
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
