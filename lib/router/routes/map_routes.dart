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
        final extra = state.extra;
        final model = extra is Model ? extra : null;
        if (model == null) {
          return slideUpTransition(
            const Scaffold(
              body: Center(child: Text('Error: No map detail data')),
            ),
          );
        }
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
        final extra = state.extra;
        final posts = extra is Posts ? extra : null;
        if (posts == null) {
          return slideUpTransition(
            const Scaffold(
              body: Center(child: Text('Error: No edit post data')),
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
          '${RouterPath.map}/${RouterPath.mapDetail}/${RouterPath.mapProfile}',
      name: RouterPath.mapProfile,
      pageBuilder: (context, state) {
        final extra = state.extra;
        final users = extra is Users ? extra : null;
        if (users == null) {
          return slideUpTransition(
            const Scaffold(
              body: Center(child: Text('Error: No user data')),
            ),
          );
        }
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
        final extra = state.extra;
        final model = extra is Model ? extra : null;
        if (model == null) {
          return slideUpTransition(
            const Scaffold(
              body: Center(child: Text('Error: No profile detail data')),
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
          '${RouterPath.map}/${RouterPath.mapDetail}/${RouterPath.mapDetailPost}',
      name: RouterPath.mapDetailPost,
      pageBuilder: (context, state) {
        final extra = state.extra;
        final model = extra is Restaurant ? extra : null;
        if (model == null) {
          return whiteOut(
            const Scaffold(
              body: Center(child: Text('Error: No restaurant data')),
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
          '${RouterPath.map}/${RouterPath.mapDetail}/${RouterPath.mapDetailPost}/${RouterPath.mapRestaurantReview}',
      name: RouterPath.mapRestaurantReview,
      pageBuilder: (context, state) {
        final extra = state.extra;
        final posts = extra is Posts ? extra : null;
        if (posts == null) {
          return slideUpTransition(
            const Scaffold(
              body: Center(child: Text('Error: No review data')),
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
