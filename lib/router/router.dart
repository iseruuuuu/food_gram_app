import 'package:flutter/material.dart';
import 'package:food_gram_app/core/config/shared_preference/shared_preference.dart';
import 'package:food_gram_app/core/data/supabase/auth_state.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/ui/screen/detail/detail_post_screen.dart';
import 'package:food_gram_app/ui/screen/map/map_screen.dart';
import 'package:food_gram_app/ui/screen/post/restaurant_screen.dart';
import 'package:food_gram_app/ui/screen/screen.dart';
import 'package:food_gram_app/ui/screen/splash/tutorial_screen.dart';
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
      final preference = Preference();
      final isFinishedTutorial =
          await preference.getBool(PreferenceKey.isFinishedTutorial);
      if (!isFinishedTutorial) {
        return '/${RouterPath.tutorial}';
      }
      final login = authState.value?.session?.user != null;
      if (!login) {
        return '/${RouterPath.authentication}';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/${RouterPath.tutorial}',
        name: RouterPath.tutorial,
        builder: (context, state) {
          return const TutorialScreen();
        },
      ),
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
          mapRouter,
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
    return const TimeLineScreen();
  },
  routes: <RouteBase>[
    GoRoute(
      path: '${RouterPath.timeLine}/${RouterPath.timeLinePost}',
      name: RouterPath.timeLinePost,
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
      path: '${RouterPath.timeLine}/${RouterPath.timeLineDetailPost}',
      name: RouterPath.timeLineDetailPost,
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
      path: '${RouterPath.myProfile}/${RouterPath.myProfileDetailPost}',
      name: RouterPath.myProfileDetailPost,
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
      pageBuilder: (context, state) {
        return scaleUpTransition(LicensePage());
      },
    ),
    GoRoute(
      path: '${RouterPath.setting}/${RouterPath.settingTutorial}',
      name: RouterPath.settingTutorial,
      builder: (context, state) {
        return const TutorialScreen();
      },
    ),
  ],
);

final mapRouter = GoRoute(
  path: RouterPath.map,
  name: RouterPath.map,
  builder: (context, state) {
    return const MapScreen();
  },
  routes: <RouteBase>[
    GoRoute(
      path: '${RouterPath.map}/${RouterPath.mapDetailPost}',
      name: RouterPath.mapDetailPost,
      builder: (context, state) {
        final model = state.extra! as Model;
        return DetailPostScreen(posts: model.posts, users: model.users);
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
  static const String myProfileDetailPost = 'my_profile_detail_post';
  static const String myProfileRestaurant = 'my_profile_restaurant';
  static const String timeLinePost = 'time_line_post';
  static const String timeLineDetailPost = 'time_line_detail_post';
  static const String timeLineRestaurant = 'time_line_restaurant';
  static const String setting = 'setting';
  static const String timeLine = 'time_line';
  static const String splash = 'splash';
  static const String tutorial = 'introduction';
  static const String settingTutorial = 'setting_tutorial';
  static const String map = 'map';
  static const String mapDetailPost = 'map_detail_post';
}
