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
      switch (currentRouteName) {
        case RouterPath.timeLineDetail:
          return RouterPath.timeLineDetailPost;
        case RouterPath.myProfileDetail:
          return RouterPath.myProfileDetailPost;
        case RouterPath.mapDetail:
          return RouterPath.mapDetailPost;
        default:
          continue;
      }
    }

    return null;
  }
}
