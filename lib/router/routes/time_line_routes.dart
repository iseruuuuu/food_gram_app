part of '../router.dart';

final timeLineRouter = GoRoute(
  path: RouterPath.timeLine,
  name: RouterPath.timeLine,
  builder: (context, state) {
    return const TimeLineScreen();
  },
  routes: <RouteBase>[
    GoRoute(
      path: RouterPath.timeLinePost,
      name: RouterPath.timeLinePost,
      pageBuilder: (context, state) {
        return whiteOut(
          const PostScreen(routerPath: RouterPath.timeLineRestaurant),
          key: state.pageKey,
          name: AnalyticsScreen.post,
        );
      },
    ),
    GoRoute(
      path: RouterPath.timeLineRestaurant,
      name: RouterPath.timeLineRestaurant,
      pageBuilder: (context, state) {
        return slideIn(
          const RestaurantScreen(),
          key: state.pageKey,
          name: AnalyticsScreen.restaurant,
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: RouterPath.restaurantMap,
          name: RouterPath.restaurantMap,
          pageBuilder: (context, state) {
            final extra = state.extra;
            final restaurant = extra is Restaurant ? extra : null;
            if (restaurant == null) {
              return slideIn(
                const Scaffold(body: RouterErrorWidget()),
                key: state.pageKey,
              );
            }
            return slideIn(
              RestaurantMapScreen(restaurant: restaurant),
              key: state.pageKey,
              name: AnalyticsScreen.restaurantMap,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: RouterPath.timeLineDetail,
      name: RouterPath.timeLineDetail,
      pageBuilder: (context, state) {
        final extra = state.extra;
        if (extra == null) {
          return slideUpTransition(
            const Scaffold(body: RouterErrorWidget()),
            key: state.pageKey,
          );
        }
        final Model model;
        final String? categoryName;
        if (extra is TimelineDetailExtra) {
          model = extra.model;
          categoryName = extra.categoryName;
        } else if (extra is Model) {
          model = extra;
          categoryName = null;
        } else {
          return slideUpTransition(
            const Scaffold(body: RouterErrorWidget()),
            key: state.pageKey,
          );
        }
        return slideUpTransition(
          PostDetailScreen(
            posts: model.posts,
            users: model.users,
            type: PostDetailScreenType.timeline,
            categoryName: categoryName,
          ),
          key: state.pageKey,
          name: AnalyticsScreen.postDetail,
        );
      },
    ),
    GoRoute(
      path: RouterPath.timeLineEditPost,
      name: RouterPath.timeLineEditPost,
      pageBuilder: (context, state) {
        final extra = state.extra;
        final posts = extra is Posts ? extra : null;
        if (posts == null) {
          return slideUpTransition(
            const Scaffold(body: RouterErrorWidget()),
            key: state.pageKey,
          );
        }
        return slideUpTransition(
          EditPostScreen(posts: posts),
          key: state.pageKey,
          name: AnalyticsScreen.editPost,
        );
      },
    ),
    GoRoute(
      path: RouterPath.timeLineProfile,
      name: RouterPath.timeLineProfile,
      pageBuilder: (context, state) {
        final extra = state.extra;
        final users = extra is Users ? extra : null;
        if (users == null) {
          return slideUpTransition(
            const Scaffold(body: RouterErrorWidget()),
            key: state.pageKey,
          );
        }
        return slideUpTransition(
          UserProfileScreen(
            users: users,
            routerPathForDetail: RouterPath.timeLineProfileDetail,
          ),
          key: state.pageKey,
          name: AnalyticsScreen.userProfile,
        );
      },
    ),
    GoRoute(
      path: RouterPath.timeLineProfileDetail,
      name: RouterPath.timeLineProfileDetail,
      pageBuilder: (context, state) {
        final extra = state.extra;
        final model = extra is Model ? extra : null;
        if (model == null) {
          return slideUpTransition(
            const Scaffold(body: RouterErrorWidget()),
            key: state.pageKey,
          );
        }
        return slideUpTransition(
          PostDetailScreen(
            posts: model.posts,
            users: model.users,
            type: PostDetailScreenType.profile,
          ),
          key: state.pageKey,
          name: AnalyticsScreen.postDetail,
        );
      },
    ),
    GoRoute(
      path: RouterPath.timeLineDetailPost,
      name: RouterPath.timeLineDetailPost,
      pageBuilder: (context, state) {
        final extra = state.extra;
        final model = extra is Restaurant ? extra : null;
        if (model == null) {
          return whiteOut(
            const Scaffold(body: RouterErrorWidget()),
            key: state.pageKey,
          );
        }
        return whiteOut(
          PostScreen(
            routerPath: RouterPath.timeLineRestaurant,
            restaurant: model,
          ),
          key: state.pageKey,
          name: AnalyticsScreen.post,
        );
      },
    ),
    GoRoute(
      path: RouterPath.timeLineRestaurantReview,
      name: RouterPath.timeLineRestaurantReview,
      pageBuilder: (context, state) {
        final extra = state.extra;
        final posts = extra is Posts ? extra : null;
        if (posts == null) {
          return slideUpTransition(
            const Scaffold(body: RouterErrorWidget()),
            key: state.pageKey,
          );
        }
        return slideUpTransition(
          RestaurantReviewScreen(posts: posts),
          key: state.pageKey,
          name: AnalyticsScreen.restaurantDetail,
        );
      },
    ),
    GoRoute(
      path: RouterPath.searchDetailPost,
      name: RouterPath.searchDetailPost,
      pageBuilder: (context, state) {
        final extra = state.extra;
        final model = extra is Model ? extra : null;
        if (model == null) {
          return slideUpTransition(
            const Scaffold(body: RouterErrorWidget()),
            key: state.pageKey,
          );
        }
        return slideUpTransition(
          PostDetailScreen(
            posts: model.posts,
            users: model.users,
            type: PostDetailScreenType.search,
          ),
          key: state.pageKey,
          name: AnalyticsScreen.postDetail,
        );
      },
    ),
  ],
);
