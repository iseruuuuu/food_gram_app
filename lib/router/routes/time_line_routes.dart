part of '../router.dart';

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
      routes: <RouteBase>[
        GoRoute(
          path: RouterPath.restaurantMap,
          name: RouterPath.restaurantMap,
          pageBuilder: (context, state) {
            final extra = state.extra;
            final restaurant = extra is Restaurant ? extra : null;
            if (restaurant == null) {
              return slideIn(
                const Scaffold(
                  body: RouterErrorWidget(
                  ),
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
      path: '${RouterPath.timeLine}/${RouterPath.timeLineDetail}',
      name: RouterPath.timeLineDetail,
      pageBuilder: (context, state) {
        final extra = state.extra;
        if (extra == null) {
          return slideUpTransition(
            const Scaffold(
              body: RouterErrorWidget(),
            ),
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
            const Scaffold(
              body: RouterErrorWidget(),
            ),
          );
        }

        return slideUpTransition(
          PostDetailScreen(
            posts: model.posts,
            users: model.users,
            type: PostDetailScreenType.timeline,
            categoryName: categoryName,
          ),
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.timeLine}/${RouterPath.timeLineDetail}/${RouterPath.timeLineEditPost}',
      name: RouterPath.timeLineEditPost,
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
          '${RouterPath.timeLine}/${RouterPath.timeLineDetail}/${RouterPath.timeLineProfile}',
      name: RouterPath.timeLineProfile,
      pageBuilder: (context, state) {
        final extra = state.extra;
        final users = extra is Users ? extra : null;
        if (users == null) {
          return slideUpTransition(
            const Scaffold(
              body: RouterErrorWidget(),
            ),
          );
        }
        return slideUpTransition(
          UserProfileScreen(
            users: users,
            routerPathForDetail: RouterPath.timeLineProfileDetail,
          ),
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.timeLine}/${RouterPath.timeLineDetail}/${RouterPath.timeLineProfile}/${RouterPath.timeLineProfileDetail}',
      name: RouterPath.timeLineProfileDetail,
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
            type: PostDetailScreenType.profile,
          ),
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.timeLine}/${RouterPath.timeLineDetail}/${RouterPath.timeLineDetailPost}',
      name: RouterPath.timeLineDetailPost,
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
            routerPath: RouterPath.timeLineRestaurant,
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
    GoRoute(
      path:
          '${RouterPath.timeLine}/${RouterPath.timeLineDetail}/${RouterPath.searchDetailPost}',
      name: RouterPath.searchDetailPost,
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
            type: PostDetailScreenType.search,
          ),
        );
      },
    ),
  ],
);
