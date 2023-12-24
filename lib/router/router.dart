import 'package:flutter/material.dart';
import 'package:food_gram_app/config/supabase/auth_state.dart';
import 'package:food_gram_app/model/model.dart';
import 'package:food_gram_app/ui/screen/detail/detail_post_screen.dart';
import 'package:food_gram_app/ui/screen/post/restaurant_screen.dart';
import 'package:food_gram_app/ui/screen/screen.dart';
import 'package:food_gram_app/utils/amination.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/${RouterPath.splash}',
    redirect: (context, state) async {
      final login = authState.value?.session?.user != null;
      if (!login) {
        return '/${RouterPath.authentication}';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/${RouterPath.splash}',
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
        pageBuilder: (context, state) {
          return blackOut(NewAccountScreen());
        },
      ),
      GoRoute(
        path: '/${RouterPath.tab}',
        name: RouterPath.tab,
        pageBuilder: (context, state) {
          return blackOut(TabScreen());
        },
        routes: <RouteBase>[
          timeLineRouter,
          myProfileRouter,
          settingRouter,
        ],
      ),
    ],
  );
}

final timeLineRouter = GoRoute(
  path: RouterPath.timeLine,
  name: RouterPath.timeLine,
  builder: (context, state) {
    return TimeLineScreen();
  },
  routes: <RouteBase>[
    GoRoute(
      path: '${RouterPath.timeLine}/${RouterPath.timeLinepost}',
      name: RouterPath.timeLinepost,
      pageBuilder: (context, state) {
        return whiteOut(PostScreen(routerPath: RouterPath.timeLineRestaurant));
      },
    ),
    GoRoute(
      path: '${RouterPath.timeLine}/${RouterPath.timeLineRestaurant}',
      name: RouterPath.timeLineRestaurant,
      pageBuilder: (context, state) {
        return slideIn(RestaurantScreen());
      },
    ),
    GoRoute(
      path: '${RouterPath.timeLine}/${RouterPath.timeLineDeitailPost}',
      name: RouterPath.timeLineDeitailPost,
      pageBuilder: (context, state) {
        final model = state.extra! as Model;
        return elasticTransition(
          DetailPostScreen(posts: model.posts, users: model.users),
        );
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
      pageBuilder: (context, state) {
        return slideIn(EditScreen());
      },
    ),
    GoRoute(
      path: '${RouterPath.myProfile}/${RouterPath.myProfilePost}',
      name: RouterPath.myProfilePost,
      pageBuilder: (context, state) {
        return whiteOut(PostScreen(routerPath: RouterPath.myProfileRestaurant));
      },
    ),
    GoRoute(
      path: '${RouterPath.myProfile}/${RouterPath.myProfileRestaurant}',
      name: RouterPath.myProfileRestaurant,
      builder: (context, state) {
        return const RestaurantScreen();
      },
    ),
    GoRoute(
      path: '${RouterPath.myProfile}/${RouterPath.myProfileDeitailPost}',
      name: RouterPath.myProfileDeitailPost,
      pageBuilder: (context, state) {
        final model = state.extra! as Model;
        return elasticTransition(
          DetailPostScreen(posts: model.posts, users: model.users),
        );
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
      pageBuilder: (context, state) {
        return scaleUpTransition(LicensePage());
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
  static const String myProfileRestaurant = 'my_profile_restaurant';
  static const String timeLinepost = 'time_line_post';
  static const String timeLineDeitailPost = 'time_line_detail_post';
  static const String timeLineRestaurant = 'time_line_restaurant';
  static const String setting = 'setting';
  static const String timeLine = 'time_line';
  static const String splash = 'splash';
}
