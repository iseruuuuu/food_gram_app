part of '../router.dart';

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
          UserProfileScreen(
            users: users,
            routerPathForDetail: RouterPath.mapProfileDetail,
          ),
        );
      },
    ),
    GoRoute(
      path:
          '${RouterPath.map}/${RouterPath.mapDetail}/${RouterPath.mapProfile}/${RouterPath.mapProfileDetail}',
      name: RouterPath.mapProfileDetail,
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
