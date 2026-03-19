import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/timeline_detail_extra.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/auth/providers/auth_state_provider.dart';
import 'package:food_gram_app/router/amination.dart';
import 'package:food_gram_app/ui/screen/screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';
part 'routes/image_editor_route.dart';
part 'routes/time_line_routes.dart';
part 'routes/my_profile_routes.dart';
part 'routes/setting_routes.dart';
part 'routes/map_routes.dart';

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
      // ルートパス「/」をスプラッシュ画面にリダイレクト（ディープリンク対応）
      GoRoute(
        path: '/',
        redirect: (context, state) => '/${RouterPath.splash}',
      ),
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
          imageEditorRoute,
          timeLineRouter,
          mapRouter,
          myProfileRouter,
          settingRouter,
        ],
      ),
    ],
  );
}

final class RouterPath {
  static const String tab = 'tab';
  static const String authentication = 'authentication';
  static const String newAccount = 'new_account';
  static const String license = 'license';
  static const String notifications = 'notifications';
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
  static const String timeLineDetailPost = 'time_line_detail_post';
  static const String myProfileDetailPost = 'my_profile_detail_post';
  static const String mapDetailPost = 'map_detail_post';
  static const String mapProfile = 'map_profile';
  static const String mapProfileDetail = 'map_profile_detail';
  static const String timeLineProfile = 'time_line_profile';
  static const String timeLineProfileDetail = 'time_line_profile_detail';
  static const String timeLineRestaurantReview = 'time_line_restaurant_review';
  static const String mapRestaurantReview = 'map_restaurant_review';
  static const String myProfileRestaurantReview =
      'my_profile_restaurant_review';
  static const String timeLineEditPost = 'time_line_edit_post';
  static const String mapEditPost = 'map_edit_post';
  static const String myProfileEditPost = 'my_profile_edit_post';
  static const String storedPost = 'stored_post';
  static const String searchDetailPost = 'search_detail_post';
  static const String storedPostDetail = 'stored_post_detail';
  static const String restaurantMap = 'restaurant_map';
  static const String restaurantMapMyProfile = 'restaurant_map_myProfile';
  static const String imageEditor = 'image_editor';
}
