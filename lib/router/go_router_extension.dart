import 'package:food_gram_app/router/router.dart';
import 'package:go_router/go_router.dart';

extension GoRouterExtension on GoRouter {
  String isCurrentLocation() {
    final lastMatch = routerDelegate.currentConfiguration.last;
    final matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    final location = matchList.uri.toString();
    return currentRoute(location);
  }
}

String currentRoute(String path) {
  switch (path) {
    case '/tab/time_line/time_line/time_line_detail':
      return RouterPath.timeLineDetailPost;
    case '/tab/my_profile/my_profile/my_profile_detail':
      return RouterPath.myProfileDetailPost;
    case '/tab/map/map/map_detail':
      return RouterPath.mapDetailPost;
  }
  return '';
}
