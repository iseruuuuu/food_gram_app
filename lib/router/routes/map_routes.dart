part of '../router.dart';

final mapRouter = GoRoute(
  path: RouterPath.map,
  name: RouterPath.map,
  builder: (context, state) {
    return const MapScreen();
  },
  routes: <RouteBase>[
    GoRoute(
      path: RouterPath.mapDetail,
      name: RouterPath.mapDetail,
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
            type: PostDetailScreenType.map,
          ),
          key: state.pageKey,
          name: AnalyticsScreen.postDetail,
        );
      },
    ),
    GoRoute(
      path: '${RouterPath.mapDetail}/${RouterPath.mapEditPost}',
      name: RouterPath.mapEditPost,
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
      path: '${RouterPath.mapDetail}/${RouterPath.mapProfile}',
      name: RouterPath.mapProfile,
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
            routerPathForDetail: RouterPath.mapProfileDetail,
          ),
          key: state.pageKey,
          name: AnalyticsScreen.userProfile,
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.mapDetail}/${RouterPath.mapProfile}/${RouterPath.mapProfileDetail}',
      name: RouterPath.mapProfileDetail,
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
      path: '${RouterPath.mapDetail}/${RouterPath.mapDetailPost}',
      name: RouterPath.mapDetailPost,
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
            routerPath: RouterPath.mapRestaurant,
            restaurant: model,
          ),
          key: state.pageKey,
          name: AnalyticsScreen.post,
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: RouterPath.mapRestaurant,
          name: RouterPath.mapRestaurant,
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
              name: RouterPath.restaurantMapFromMap,
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
          path: RouterPath.mapRestaurantReview,
          name: RouterPath.mapRestaurantReview,
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
      ],
    ),
  ],
);
