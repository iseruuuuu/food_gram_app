import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    required this.onTap,
    required this.currentIndex,
    super.key,
  });

  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 0,
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.black,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      showUnselectedLabels: false,
      selectedFontSize: 0,
      unselectedFontSize: 0,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 35),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle, size: 35),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings, size: 35),
          label: '',
        ),
      ],
    );
  }
}
