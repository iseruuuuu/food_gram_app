import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      removeBottom: true,
      child: Scaffold(
        body: controller.pageList[state.selectedIndex],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: state.selectedIndex,
            onTap: controller.onTap,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    Gap(12),
                    Icon(
                      (state.selectedIndex == 0)
                          ? CupertinoIcons.map_fill
                          : CupertinoIcons.map,
                      semanticLabel: 'mapIcon',
                    ),
                    Gap(6),
                    Text(
                      l10n.tabMap,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: (state.selectedIndex == 0)
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                    Gap(10),
                  ],
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    Gap(12),
                    Icon(
                      (state.selectedIndex == 1)
                          ? Icons.fastfood
                          : Icons.fastfood_outlined,
                      semanticLabel: 'timelineIcon',
                    ),
                    Gap(6),
                    Text(
                      l10n.tabHome,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: (state.selectedIndex == 1)
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                    Gap(10),
                  ],
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    Gap(12),
                    Icon(
                      (state.selectedIndex == 2)
                          ? CupertinoIcons.person_circle_fill
                          : CupertinoIcons.person_circle,
                      size: 30,
                      semanticLabel: 'profileIcon',
                    ),
                    Gap(6),
                    Text(
                      l10n.tabMyPage,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: (state.selectedIndex == 2)
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                    Gap(10),
                  ],
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    Gap(12),
                    Icon(
                      (state.selectedIndex == 3)
                          ? Icons.settings
                          : Icons.settings_outlined,
                      semanticLabel: 'settingIcon',
                    ),
                    Gap(6),
                    Text(
                      l10n.tabSetting,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: (state.selectedIndex == 2)
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                    Gap(10),
                  ],
                ),
                label: '',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
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
