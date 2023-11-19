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
      backgroundColor: Colors.white,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.black,
      selectedLabelStyle: TextStyle(
        color: Colors.black,
      ),
      iconSize: 30,
      selectedFontSize: 0,
      unselectedFontSize: 0,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            size: 35,
          ),
          label: 'home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.account_circle,
            size: 35,
          ),
          label: 'profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.settings,
            size: 35,
          ),
          label: 'setting',
        ),
      ],
    );
  }
}
