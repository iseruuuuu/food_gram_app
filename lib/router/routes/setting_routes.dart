part of '../router.dart';

final settingRouter = GoRoute(
  path: RouterPath.setting,
  name: RouterPath.setting,
  builder: (context, state) {
    return const SettingScreen();
  },
  routes: <RouteBase>[
    GoRoute(
      path: RouterPath.license,
      name: RouterPath.license,
      pageBuilder: (context, state) {
        return scaleUpTransition(const LicensePage());
      },
    ),
    GoRoute(
      path: RouterPath.settingTutorial,
      name: RouterPath.settingTutorial,
      builder: (context, state) {
        return const TutorialScreen();
      },
    ),
  ],
);
