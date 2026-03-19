import 'package:food_gram_app/router/router.dart';
import 'package:go_router/go_router.dart';

extension GoRouterExtension on GoRouter {
  String? isCurrentLocation() {
    final lastMatch = routerDelegate.currentConfiguration.last;
    final matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    final leafMatch = matchList.last;
    final route = leafMatch.route;
    final currentRouteName = route is GoRoute ? route.name : null;
    switch (currentRouteName) {
      case RouterPath.timeLineDetail:
        return RouterPath.timeLineDetailPost;
      case RouterPath.myProfileDetail:
        return RouterPath.myProfileDetailPost;
      case RouterPath.mapDetail:
        return RouterPath.mapDetailPost;
      default:
        return null;
    }
  }
}
