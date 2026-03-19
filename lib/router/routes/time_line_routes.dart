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
            final restaurant = state.extra as Restaurant?;
            if (restaurant == null) {
              return slideIn(
                const Scaffold(
                  body: Center(child: Text('Error: No restaurant data')),
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
        final extra = state.extra!;
        final model =
            extra is TimelineDetailExtra ? extra.model : extra as Model;
        final categoryName =
            extra is TimelineDetailExtra ? extra.categoryName : null;
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
        final model = state.extra! as Model;
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
        final model = state.extra! as Restaurant;
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
        final posts = state.extra! as Posts;
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
