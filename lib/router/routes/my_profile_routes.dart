part of '../router.dart';

final myProfileRouter = GoRoute(
  path: RouterPath.myProfile,
  name: RouterPath.myProfile,
  builder: (context, state) {
    return const MyProfileScreen();
  },
  routes: <RouteBase>[
    GoRoute(
      path: RouterPath.notifications,
      name: RouterPath.notifications,
      pageBuilder: (context, state) {
        return whiteOut(const NotificationsScreen());
      },
    ),
    GoRoute(
      path: RouterPath.edit,
      name: RouterPath.edit,
      pageBuilder: (context, state) {
        return slideIn(const EditScreen());
      },
    ),
    GoRoute(
      path: RouterPath.storedPost,
      name: RouterPath.storedPost,
      pageBuilder: (context, state) {
        return whiteOut(const StoredPostScreen());
      },
    ),
    GoRoute(
      path:
          '${RouterPath.storedPost}/${RouterPath.storedPostDetail}',
      name: RouterPath.storedPostDetail,
      pageBuilder: (context, state) {
        final extra = state.extra;
        final model = extra is Model ? extra : null;
        if (model == null) {
          return slideUpTransition(
            const Scaffold(
              body: RouterErrorWidget(),
            ),
          );
        }
        return slideUpTransition(
          PostDetailScreen(
            posts: model.posts,
            users: model.users,
            type: PostDetailScreenType.stored,
          ),
        );
      },
    ),
    GoRoute(
      path: RouterPath.myProfilePost,
      name: RouterPath.myProfilePost,
      pageBuilder: (context, state) {
        return whiteOut(
          const PostScreen(routerPath: RouterPath.myProfileRestaurant),
        );
      },
    ),
    GoRoute(
      path: RouterPath.myProfileRestaurant,
      name: RouterPath.myProfileRestaurant,
      builder: (context, state) {
        return const RestaurantScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: RouterPath.restaurantMap,
          name: RouterPath.restaurantMapMyProfile,
          pageBuilder: (context, state) {
            final extra = state.extra;
            final restaurant = extra is Restaurant ? extra : null;
            if (restaurant == null) {
              return slideIn(
                const Scaffold(
                  body: RouterErrorWidget(),
                ),
              );
            }
            return slideIn(
              RestaurantMapScreen(restaurant: restaurant),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: RouterPath.myProfileDetail,
      name: RouterPath.myProfileDetail,
      pageBuilder: (context, state) {
        final extra = state.extra;
        final model = extra is Model ? extra : null;
        if (model == null) {
          return slideUpTransition(
            const Scaffold(
              body: RouterErrorWidget(),
            ),
          );
        }
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
          '${RouterPath.myProfileDetail}/${RouterPath.myProfileEditPost}',
      name: RouterPath.myProfileEditPost,
      pageBuilder: (context, state) {
        final extra = state.extra;
        final posts = extra is Posts ? extra : null;
        if (posts == null) {
          return slideUpTransition(
            const Scaffold(
              body: RouterErrorWidget(),
            ),
          );
        }
        return slideUpTransition(
          EditPostScreen(
            posts: posts,
          ),
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.myProfileDetail}/${RouterPath.myProfileDetailPost}',
      name: RouterPath.myProfileDetailPost,
      pageBuilder: (context, state) {
        final extra = state.extra;
        final model = extra is Restaurant ? extra : null;
        if (model == null) {
          return whiteOut(
            const Scaffold(
              body: RouterErrorWidget(),
            ),
          );
        }
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
          '${RouterPath.myProfileDetail}/${RouterPath.myProfileRestaurantReview}',
      name: RouterPath.myProfileRestaurantReview,
      pageBuilder: (context, state) {
        final extra = state.extra;
        final posts = extra is Posts ? extra : null;
        if (posts == null) {
          return slideUpTransition(
            const Scaffold(
              body: RouterErrorWidget(),
            ),
          );
        }
        return slideUpTransition(
          RestaurantReviewScreen(
            posts: posts,
          ),
        );
      },
    ),
  ],
);
