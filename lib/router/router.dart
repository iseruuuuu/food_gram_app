import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/analytics/analytics_screen.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/timeline_detail_extra.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/auth/providers/auth_state_provider.dart';
import 'package:food_gram_app/router/amination.dart';
import 'package:food_gram_app/ui/component/common/router_error_widget.dart';
import 'package:food_gram_app/ui/screen/screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';
part 'routes/time_line_routes.dart';
part 'routes/my_profile_routes.dart';
part 'routes/map_routes.dart';

bool? _finishedTutorialCache;

Future<bool> _isFinishedTutorial() async {
  if (_finishedTutorialCache ?? false) {
    return true;
  }
  final value = await Preference().getBool(PreferenceKey.isFinishedTutorial);
  if (value) {
    _finishedTutorialCache = true;
  }
  return value;
}

@riverpod
GoRouter router(Ref ref) {
  final authState = ref.watch(authStateProvider);
  final analyticsObserver =
      ref.read(firebaseAnalyticsServiceProvider).navigatorObserver;
  return GoRouter(
    initialLocation: '/${RouterPath.splash}',
    observers: [analyticsObserver],
    redirect: (context, state) async {
      final location = state.matchedLocation;
      final isFinishedTutorial = await _isFinishedTutorial();

      // スプラッシュは認証状態に関わらず表示し、遷移は SplashScreen 側で行う
      if (location == '/${RouterPath.splash}') {
        if (!isFinishedTutorial) {
          return '/${RouterPath.tutorial}';
        }
        return null;
      }

      if (location == '/${RouterPath.tutorial}' ||
          location == '/${RouterPath.authentication}' ||
          location == '/${RouterPath.registrationWelcome}') {
        return null;
      }

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
            name: AnalyticsScreen.authentication,
            child: const AuthenticationScreen(),
          );
        },
      ),
      GoRoute(
        path: '/${RouterPath.registrationWelcome}',
        name: RouterPath.registrationWelcome,
        pageBuilder: (context, state) {
          return blackOut(
            const RegistrationWelcomeScreen(),
            key: state.pageKey,
            name: AnalyticsScreen.registrationWelcome,
          );
        },
      ),
      GoRoute(
        path: '/${RouterPath.tab}',
        name: RouterPath.tab,
        pageBuilder: (context, state) {
          // Tab 本体の ScreenView は Widget 切替時に手動送信する
          return blackOut(
            const TabScreen(),
            key: state.pageKey,
          );
        },
        routes: <RouteBase>[
          imageEditorRoute,
          monthlySummaryRoute,
          weeklySummaryRoute,
          friendAddRoute,
          postRankingRoute,
          timeLineRouter,
          mapRouter,
          myProfileRouter,
        ],
      ),
    ],
  );
}

final weeklySummaryRoute = GoRoute(
  path: RouterPath.weeklySummary,
  name: RouterPath.weeklySummary,
  pageBuilder: (context, state) {
    return slideUpTransition(
      const WeeklySummaryScreen(),
      key: state.pageKey,
      name: AnalyticsScreen.weeklySummary,
    );
  },
);

final monthlySummaryRoute = GoRoute(
  path: RouterPath.monthlySummary,
  name: RouterPath.monthlySummary,
  pageBuilder: (context, state) {
    return slideUpTransition(
      const MonthlySummaryScreen(),
      key: state.pageKey,
      name: AnalyticsScreen.monthlySummary,
    );
  },
);

final imageEditorRoute = GoRoute(
  path: RouterPath.imageEditor,
  name: RouterPath.imageEditor,
  pageBuilder: (context, state) {
    final imagePath = state.extra as String? ?? '';
    return MaterialPage(
      key: state.pageKey,
      name: AnalyticsScreen.imageEditor,
      child: ImageEditorScreen(imagePath: imagePath),
    );
  },
);

final friendAddRoute = GoRoute(
  path: RouterPath.friendAdd,
  name: RouterPath.friendAdd,
  pageBuilder: (context, state) {
    return whiteOut(
      const FriendAddScreen(),
      key: state.pageKey,
      name: AnalyticsScreen.friendAdd,
    );
  },
);

final postRankingRoute = GoRoute(
  path: RouterPath.postRanking,
  name: RouterPath.postRanking,
  pageBuilder: (context, state) {
    return MaterialPage(
      key: state.pageKey,
      name: AnalyticsScreen.ranking,
      child: const PostRankingScreen(),
    );
  },
);

final class RouterPath {
  //　root（先頭 `/`）
  static const splash = 'splash';
  static const tutorial = 'introduction';
  static const authentication = 'authentication';
  static const registrationWelcome = 'registration_welcome';
  static const tab = 'tab';
  // /tab（main tabs & 共通）
  static const imageEditor = 'image_editor';
  static const timeLine = 'time_line';
  static const map = 'map';
  static const myProfile = 'my_profile';
  // /tab/my_profile
  static const setting = 'setting';
  static const license = 'license';
  static const settingTutorial = 'setting_tutorial';
  static const notifications = 'notifications';
  static const storedPost = 'stored_post';
  static const wantToGoList = 'want_to_go_list';
  static const tagDex = 'tag_dex';
  static const storedPostDetail = 'stored_post_detail';
  static const memoryAlbumList = 'memory_album_list';
  static const memoryAlbumCreate = 'memory_album_create';
  static const memoryAlbumDetail = 'memory_album_detail';
  static const memoryAlbumEdit = 'memory_album_edit';
  static const myProfilePost = 'my_profile_post';
  static const edit = 'edit';
  static const myProfileDetail = 'my_profile_detail';
  static const myProfileEditPost = 'my_profile_edit_post';
  static const myProfileDetailPost = 'my_profile_detail_post';
  static const myProfileRestaurant = 'my_profile_restaurant';
  static const myProfileRestaurantReview =
      'my_profile_restaurant_review';
  static const restaurantMapMyProfile = 'restaurant_map_myProfile';
  // /tab/time_line
  static const timeLinePost = 'time_line_post';
  static const timeLineDetail = 'time_line_detail';
  static const timeLineDetailPost = 'time_line_detail_post';
  static const timeLineEditPost = 'time_line_edit_post';
  static const timeLineRestaurant = 'time_line_restaurant';
  static const timeLineRestaurantReview = 'time_line_restaurant_review';
  static const searchDetailPost = 'search_detail_post';
  static const timeLineProfile = 'time_line_profile';
  static const timeLineProfileDetail = 'time_line_profile_detail';
  static const restaurantMap = 'restaurant_map';
  // /tab /map
  static const mapDetail = 'map_detail';
  static const mapEditPost = 'map_edit_post';
  static const mapProfile = 'map_profile';
  static const mapProfileDetail = 'map_profile_detail';
  static const mapDetailPost = 'map_detail_post';
  static const mapRestaurant = 'map_restaurant';
  static const mapRestaurantReview = 'map_restaurant_review';
  static const restaurantMapFromMap = 'restaurant_map_map';
  // /tab
  static const weeklySummary = 'weekly_summary';
  static const monthlySummary = 'monthly_summary';
  static const friendAdd = 'friend_add';
  static const postRanking = 'post_ranking';
}
