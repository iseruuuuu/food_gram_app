import 'package:flutter/material.dart';
import 'package:food_gram_app/ui/screen/screen.dart';
import 'package:food_gram_app/widgetbook/ui/fake_data/fake_data.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// AuthenticationScreen
@widgetbook.UseCase(
  name: 'AuthenticationScreen',
  type: AuthenticationScreen,
)
AuthenticationScreen authenticationScreen(BuildContext context) {
  return const AuthenticationScreen();
}

/// NewAccountScreen
@widgetbook.UseCase(
  name: 'NewAccountScreen',
  type: NewAccountScreen,
)
NewAccountScreen newAccountScreen(BuildContext context) {
  return const NewAccountScreen();
}

/// DetailPostScreen
@widgetbook.UseCase(
  name: 'DetailPostScreen',
  type: DetailPostScreen,
)
DetailPostScreen detailPostScreen(BuildContext context) {
  return DetailPostScreen(posts: fakePosts, users: fakeUsers);
}

/// EditScreen
@widgetbook.UseCase(
  name: 'EditScreen',
  type: EditScreen,
)
EditScreen editScreen(BuildContext context) {
  return const EditScreen();
}

/// MapScreen
@widgetbook.UseCase(
  name: 'MapScreen',
  type: MapScreen,
)
MapScreen mapScreen(BuildContext context) {
  return const MapScreen();
}

/// MyProfileScreen
@widgetbook.UseCase(
  name: 'MyProfileScreen',
  type: MyProfileScreen,
)
MyProfileScreen myProfileScreen(BuildContext context) {
  return const MyProfileScreen();
}

/// PostScreen
@widgetbook.UseCase(
  name: 'PostScreen',
  type: PostScreen,
)
PostScreen postScreen(BuildContext context) {
  return const PostScreen(routerPath: '');
}

/// RestaurantScreen
@widgetbook.UseCase(
  name: 'RestaurantScreen',
  type: RestaurantScreen,
)
RestaurantScreen restaurantScreen(BuildContext context) {
  return const RestaurantScreen();
}

/// SettingScreen
@widgetbook.UseCase(
  name: 'SettingScreen',
  type: SettingScreen,
)
SettingScreen settingScreen(BuildContext context) {
  return const SettingScreen();
}

/// SplashScreen
@widgetbook.UseCase(
  name: 'SplashScreen',
  type: SplashScreen,
)
SplashScreen splashScreen(BuildContext context) {
  return const SplashScreen();
}

/// TutorialScreen
@widgetbook.UseCase(
  name: 'TutorialScreen',
  type: TutorialScreen,
)
TutorialScreen tutorialScreen(BuildContext context) {
  return const TutorialScreen();
}

/// TabScreen
@widgetbook.UseCase(
  name: 'TabScreen',
  type: TabScreen,
)
TabScreen tabScreen(BuildContext context) {
  return const TabScreen();
}

/// TimeLineScreen
@widgetbook.UseCase(
  name: 'TimeLineScreen',
  type: TimeLineScreen,
)
TimeLineScreen timeLineScreen(BuildContext context) {
  return const TimeLineScreen();
}
