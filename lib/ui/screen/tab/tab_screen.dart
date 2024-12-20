import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/ui/screen/tab/tab_view_model.dart';

class TabScreen extends ConsumerWidget {
  const TabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tabViewModelProvider());
    final controller = ref.watch(tabViewModelProvider().notifier);
    return Scaffold(
      body: IndexedStack(
        index: state.selectedIndex,
        children: controller.pageList,
      ),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: state.selectedIndex,
            onTap: controller.onTap,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Icon(
                    Icons.fastfood_outlined,
                    semanticLabel: 'timelineIcon',
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Icon(
                    CupertinoIcons.map,
                    semanticLabel: 'mapIcon',
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Icon(
                    CupertinoIcons.profile_circled,
                    semanticLabel: 'profileIcon',
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Icon(
                    Icons.settings,
                    semanticLabel: 'settingIcon',
                  ),
                ),
                label: '',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            iconSize: 28,
            elevation: 0,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 0,
            unselectedFontSize: 0,
          ),
        ),
      ),
    );
  }
}
