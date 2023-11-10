import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/component/app_bottom_navigation_bar.dart';
import 'package:food_gram_app/screen/tab/tab_view_model.dart';

class TabScreen extends ConsumerWidget {
  const TabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tabViewModelProvider());
    final controller = ref.watch(tabViewModelProvider().notifier);
    return Scaffold(
      body: controller.pageList[state.selectedIndex],
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: state.selectedIndex,
        onTap: controller.onTap,
      ),
    );
  }
}
