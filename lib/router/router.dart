import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/auth/providers/auth_state_provider.dart';
import 'package:food_gram_app/router/amination.dart';
import 'package:food_gram_app/ui/screen/screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
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
          return blackOut(const NewAccountScreen());
        },
      ),
      GoRoute(
        path: '/${RouterPath.tab}',
        name: RouterPath.tab,
        pageBuilder: (context, state) {
          return blackOut(const TabScreen());
        },
        routes: <RouteBase>[
          timeLineRouter,
          mapRouter,
          myProfileRouter,
          settingRouter,
          searchRouter,
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
        return whiteOut(
          const PostScreen(routerPath: RouterPath.timeLineRestaurant),
        );
      },
    ),
    GoRoute(
      path: '${RouterPath.timeLine}/${RouterPath.timeLineRestaurant}',
      name: RouterPath.timeLineRestaurant,
      pageBuilder: (context, state) {
        return slideIn(const RestaurantScreen());
      },
    ),
    GoRoute(
      path: '${RouterPath.timeLine}/${RouterPath.timeLineDetail}',
      name: RouterPath.timeLineDetail,
      pageBuilder: (context, state) {
        final model = state.extra! as Model;
        return slideUpTransition(
          PostDetailScreen(
            posts: model.posts,
            users: model.users,
            type: PostDetailScreenType.timeline,
          ),
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.timeLine}/${RouterPath.timeLineDetail}/${RouterPath.timeLineEditPost}',
      name: RouterPath.timeLineEditPost,
      pageBuilder: (context, state) {
        final posts = state.extra! as Posts;
        return slideUpTransition(
          EditPostScreen(
            posts: posts,
          ),
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.timeLine}/${RouterPath.timeLineDetail}/${RouterPath.timeLineProfile}',
      name: RouterPath.timeLineProfile,
      pageBuilder: (context, state) {
        final users = state.extra! as Users;
        return slideUpTransition(
          UserProfileScreen(users: users),
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.timeLine}/${RouterPath.timeLineDetail}/${RouterPath.timeLineDetailPost}',
      name: RouterPath.timeLineDetailPost,
      pageBuilder: (context, state) {
        final model = state.extra! as Restaurant;
        return whiteOut(
          PostScreen(
            routerPath: RouterPath.timeLineDetailPost,
            restaurant: model,
          ),
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.timeLine}/${RouterPath.timeLineDetail}/${RouterPath.timeLineRestaurantReview}',
      name: RouterPath.timeLineRestaurantReview,
      pageBuilder: (context, state) {
        final posts = state.extra! as Posts;
        return slideUpTransition(
          RestaurantReviewScreen(
            posts: posts,
          ),
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
        return slideIn(const EditScreen());
      },
    ),
    GoRoute(
      path: '${RouterPath.myProfile}/${RouterPath.storedPost}',
      name: RouterPath.storedPost,
      pageBuilder: (context, state) {
        return whiteOut(const StoredPostScreen());
      },
    ),
    GoRoute(
      path: '${RouterPath.myProfile}/${RouterPath.myProfilePost}',
      name: RouterPath.myProfilePost,
      pageBuilder: (context, state) {
        return whiteOut(
          const PostScreen(routerPath: RouterPath.myProfileRestaurant),
        );
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
      path: '${RouterPath.myProfile}/${RouterPath.myProfileDetail}',
      name: RouterPath.myProfileDetail,
      pageBuilder: (context, state) {
        final model = state.extra! as Model;
        return slideUpTransition(
          PostDetailScreen(
            posts: model.posts,
            users: model.users,
            type: PostDetailScreenType.myprofile,
          ),
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.myProfile}/${RouterPath.myProfileDetail}/${RouterPath.myProfileEditPost}',
      name: RouterPath.myProfileEditPost,
      pageBuilder: (context, state) {
        final posts = state.extra! as Posts;
        return slideUpTransition(
          EditPostScreen(
            posts: posts,
          ),
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.myProfile}/${RouterPath.myProfileDetail}/${RouterPath.myProfileDetailPost}',
      name: RouterPath.myProfileDetailPost,
      pageBuilder: (context, state) {
        final model = state.extra! as Restaurant;
        return whiteOut(
          PostScreen(
            routerPath: RouterPath.myProfileRestaurant,
            restaurant: model,
          ),
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.myProfile}/${RouterPath.myProfileDetail}/${RouterPath.myProfileRestaurantReview}',
      name: RouterPath.myProfileRestaurantReview,
      pageBuilder: (context, state) {
        final posts = state.extra! as Posts;
        return slideUpTransition(
          RestaurantReviewScreen(
            posts: posts,
          ),
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
        return scaleUpTransition(const LicensePage());
      },
    ),
    GoRoute(
      path: '${RouterPath.setting}/${RouterPath.settingTutorial}',
      name: RouterPath.settingTutorial,
      builder: (context, state) {
        return const TutorialScreen();
      },
    ),
    GoRoute(
      path: '${RouterPath.setting}/${RouterPath.paywallPage}',
      name: RouterPath.paywallPage,
      pageBuilder: (context, state) {
        return slideIn(const PaywallScreen());
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
      path: '${RouterPath.map}/${RouterPath.mapDetail}',
      name: RouterPath.mapDetail,
      pageBuilder: (context, state) {
        final model = state.extra! as Model;
        return slideUpTransition(
          PostDetailScreen(
            posts: model.posts,
            users: model.users,
            type: PostDetailScreenType.map,
          ),
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.map}/${RouterPath.mapDetail}/${RouterPath.mapEditPost}',
      name: RouterPath.mapEditPost,
      pageBuilder: (context, state) {
        final posts = state.extra! as Posts;
        return slideUpTransition(
          EditPostScreen(
            posts: posts,
          ),
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.map}/${RouterPath.mapDetail}/${RouterPath.mapProfile}',
      name: RouterPath.mapProfile,
      pageBuilder: (context, state) {
        final users = state.extra! as Users;
        return slideUpTransition(
          UserProfileScreen(users: users),
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.map}/${RouterPath.mapDetail}/${RouterPath.mapDetailPost}',
      name: RouterPath.mapDetailPost,
      pageBuilder: (context, state) {
        final model = state.extra! as Restaurant;
        return whiteOut(
          PostScreen(
            routerPath: RouterPath.myProfileRestaurant,
            restaurant: model,
          ),
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.map}/${RouterPath.mapDetail}/${RouterPath.mapDetailPost}/${RouterPath.mapRestaurantReview}',
      name: RouterPath.mapRestaurantReview,
      pageBuilder: (context, state) {
        final posts = state.extra! as Posts;
        return slideUpTransition(
          RestaurantReviewScreen(
            posts: posts,
          ),
        );
      },
    ),
  ],
);

final searchRouter = GoRoute(
  path: RouterPath.search,
  name: RouterPath.search,
  builder: (context, state) {
    return const SearchScreen();
  },
  routes: <RouteBase>[
    GoRoute(
      path: '${RouterPath.search}/${RouterPath.searchRestaurantReview}',
      name: RouterPath.searchRestaurantReview,
      pageBuilder: (context, state) {
        final posts = state.extra! as Posts;
        return slideUpTransition(
          RestaurantReviewScreen(
            posts: posts,
          ),
        );
      },
    ),
    GoRoute(
      path: '${RouterPath.search}/${RouterPath.searchDetail}',
      name: RouterPath.searchDetail,
      pageBuilder: (context, state) {
        final posts = state.extra! as List<Posts>;
        return slideUpTransition(
          SearchDetailScreen(posts: posts),
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.search}/${RouterPath.searchDetail}/${RouterPath.searchDetailPost}',
      name: RouterPath.searchDetailPost,
      pageBuilder: (context, state) {
        final model = state.extra! as Model;
        return slideUpTransition(
          PostDetailScreen(
            posts: model.posts,
            users: model.users,
            type: PostDetailScreenType.search,
          ),
        );
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
  static const String myProfileDetail = 'my_profile_detail';
  static const String myProfileRestaurant = 'my_profile_restaurant';
  static const String timeLinePost = 'time_line_post';
  static const String timeLineDetail = 'time_line_detail';
  static const String timeLineRestaurant = 'time_line_restaurant';
  static const String setting = 'setting';
  static const String timeLine = 'time_line';
  static const String splash = 'splash';
  static const String tutorial = 'introduction';
  static const String settingTutorial = 'setting_tutorial';
  static const String map = 'map';
  static const String mapDetail = 'map_detail';
  static const String storyPage = 'story';
  static const String paywallPage = 'paywall';
  static const String timeLineDetailPost = 'time_line_detail_post';
  static const String myProfileDetailPost = 'my_profile_detail_post';
  static const String mapDetailPost = 'map_detail_post';
  static const String mapProfile = 'map_profile';
  static const String timeLineProfile = 'time_line_profile';
  static const String timeLineRestaurantReview = 'time_line_restaurant_review';
  static const String mapRestaurantReview = 'map_restaurant_review';
  static const String myProfileRestaurantReview =
      'my_profile_restaurant_review';
  static const String timeLineEditPost = 'time_line_edit_post';
  static const String mapEditPost = 'map_edit_post';
  static const String myProfileEditPost = 'my_profile_edit_post';
  static const String search = 'search';
  static const String searchRestaurantReview = 'search_restaurant_review';
  static const String searchDetail = 'search_detail';
  static const String storedPost = 'stored_post';
  static const String searchDetailPost = 'search_detail_post';
}
