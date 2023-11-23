import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/screen/my_profile/my_profile_screen.dart';
import 'package:food_gram_app/screen/setting/setting_screen.dart';
import 'package:food_gram_app/screen/time_line/time_line_screen.dart';

class TabScreen extends StatelessWidget {
  const TabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        border: const Border(),
        iconSize: 40,
        height: 60,
        activeColor: Colors.black,
        inactiveColor: Colors.grey,
        backgroundColor: CupertinoColors.extraLightBackgroundGray,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            return pageList[index];
          },
        );
      },
    );
  }
}

List<Widget> pageList = [
  const TimeLineScreen(),
  const MyProfileScreen(),
  const SettingScreen(),
];
