import 'package:food_gram_app/router/router.dart';
import 'package:go_router/go_router.dart';

extension GoRouterExtension on GoRouter {
  String? isCurrentLocation() {
    final lastMatch = routerDelegate.currentConfiguration.last;
    final matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    final matches = matchList.matches;
    for (var i = matches.length - 1; i >= 0; i--) {
      final route = matches[i].route;
      final currentRouteName = route is GoRoute ? route.name : null;
      final restaurantPost = restaurantPostRouteName(currentRouteName);
      if (restaurantPost != null) {
        return restaurantPost;
      }
    }

    return null;
  }
}

/// 投稿詳細から「この店に投稿」へ進むルート名。
String? restaurantPostRouteName(String? currentRouteName) {
  return switch (currentRouteName) {
    RouterPath.timeLineDetail => RouterPath.timeLineDetailPost,
    RouterPath.myProfileDetail => RouterPath.myProfileDetailPost,
    RouterPath.mapDetail => RouterPath.mapDetailPost,
    RouterPath.likedPostDetail => RouterPath.likedPostDetailPost,
    _ => null,
  };
}
