import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/screen/tab/tab_view_model.dart';

class TabScreen extends ConsumerWidget {
  const TabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tabViewModelProvider());
    final controller = ref.watch(tabViewModelProvider().notifier);
    final l10n = L10n.of(context);
    return Scaffold(
      body: controller.pageList[state.selectedIndex],
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
              icon: Icon(
                Icons.fastfood_outlined,
                semanticLabel: 'timelineIcon',
              ),
              label: l10n.tabHome,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                CupertinoIcons.map,
                semanticLabel: 'mapIcon',
              ),
              label: l10n.tabMap,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                CupertinoIcons.profile_circled,
                semanticLabel: 'profileIcon',
              ),
              label: l10n.tabMyPage,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
                semanticLabel: 'settingIcon',
              ),
              label: l10n.tabSetting,
            ),
          ],
          type: BottomNavigationBarType.fixed,
          iconSize: 28,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 8,
          unselectedFontSize: 8,
        ),
      ),
    );
  }
}
