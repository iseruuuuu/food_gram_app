import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/model/model.dart';
import 'package:food_gram_app/screen/detail/detail_post_screen.dart';
import 'package:food_gram_app/screen/screen.dart';
import 'package:go_router/go_router.dart';

final router = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          name: RouterPath.splash,
          builder: (context, state) {
            return const SplashScreen();
          },
        ),
        GoRoute(
          path: '/${RouterPath.authentication}',
          name: RouterPath.authentication,
          pageBuilder: (context, state) {
            return MaterialPage(
              key: state.pageKey,
              child: const AuthenticationScreen(),
            );
          },
        ),
        GoRoute(
          path: '/${RouterPath.newAccount}',
          name: RouterPath.newAccount,
          builder: (context, state) {
            return const NewAccountScreen();
          },
        ),
        GoRoute(
          path: '/${RouterPath.tab}',
          name: RouterPath.tab,
          builder: (context, state) {
            return const TabScreen();
          },
          routes: <RouteBase>[
            timeLineRouter,
            myProfileRouter,
            settingRouter,
          ],
        ),
      ],
    );
  },
);

final timeLineRouter = GoRoute(
  path: RouterPath.timeLine,
  name: RouterPath.timeLine,
  builder: (context, state) {
    return const TimeLineScreen();
  },
  routes: <RouteBase>[
    GoRoute(
      path: '${RouterPath.timeLine}/${RouterPath.timeLinepost}',
      name: RouterPath.timeLinepost,
      builder: (context, state) {
        return const PostScreen();
      },
    ),
    GoRoute(
      path: '${RouterPath.timeLine}/${RouterPath.timeLineDeitailPost}',
      name: RouterPath.timeLineDeitailPost,
      builder: (context, state) {
        final model = state.extra! as Model;
        return DetailPostScreen(posts: model.posts, users: model.users);
      },
    ),
  ],
);

final myProfileRouter = GoRoute(
  path: RouterPath.myProfile,
  name: RouterPath.myProfile,
  builder: (context, state) {
    return const MyProfileScreen();
  },
  routes: <RouteBase>[
    GoRoute(
      path: RouterPath.edit,
      name: RouterPath.edit,
      builder: (context, state) {
        return const EditScreen();
      },
    ),
    GoRoute(
      path: '${RouterPath.myProfile}/${RouterPath.myProfilePost}',
      name: RouterPath.myProfilePost,
      builder: (context, state) {
        return const PostScreen();
      },
    ),
    GoRoute(
      path: '${RouterPath.myProfile}/${RouterPath.myProfileDeitailPost}',
      name: RouterPath.myProfileDeitailPost,
      builder: (context, state) {
        final model = state.extra! as Model;
        return DetailPostScreen(posts: model.posts, users: model.users);
      },
    ),
  ],
);

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
      builder: (context, state) {
        return const LicensePage();
      },
    ),
  ],
);

final class RouterPath {
  static const String tab = 'tab';
  static const String authentication = 'authentication';
  static const String newAccount = 'new_account';
  static const String license = 'license';
  static const String edit = 'edit';
  static const String myProfile = 'my_profile';
  static const String myProfilePost = 'my_profile_post';
  static const String myProfileDeitailPost = 'my_profile_detail_post';
  static const String timeLinepost = 'time_line_post';
  static const String timeLineDeitailPost = 'time_line_detail_post';
  static const String setting = 'setting';
  static const String timeLine = 'time_line';
  static const String splash = 'splash';
}
