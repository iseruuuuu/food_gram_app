import 'package:flutter/widgets.dart';

/// FoodGram Analytics v1.0 の screen_name（PascalCase）
abstract final class AnalyticsScreen {
  static const splash = 'Splash';
  static const introduction = 'Introduction';
  static const map = 'Map';
  static const food = 'Food';
  static const record = 'Record';
  static const profile = 'Profile';
  static const setting = 'Setting';
  static const search = 'Search';
  static const restaurant = 'Restaurant';
  static const restaurantDetail = 'RestaurantDetail';
  static const album = 'Album';
  static const albumDetail = 'AlbumDetail';
  static const albumForm = 'AlbumForm';
  static const notification = 'Notification';
  static const ranking = 'Ranking';
  static const paywall = 'Paywall';
  static const post = 'Post';
  static const editPost = 'EditPost';
  static const draft = 'Draft';
  static const savedPosts = 'SavedPosts';
  static const postDetail = 'PostDetail';
  static const authentication = 'Authentication';
  static const newAccount = 'NewAccount';
  static const editProfile = 'EditProfile';
  static const license = 'License';
  static const imageEditor = 'ImageEditor';
  static const userProfile = 'UserProfile';
  static const restaurantMap = 'RestaurantMap';

  static const Set<String> all = {
    splash,
    introduction,
    map,
    food,
    record,
    profile,
    setting,
    search,
    restaurant,
    restaurantDetail,
    album,
    albumDetail,
    albumForm,
    notification,
    ranking,
    paywall,
    post,
    editPost,
    draft,
    savedPosts,
    postDetail,
    authentication,
    newAccount,
    editProfile,
    license,
    imageEditor,
    userProfile,
    restaurantMap,
  };

  /// GoRouter の RouterPath（snake_case）→ Analytics screen_name
  static const Map<String, String> _routerPathToScreen = {
    'splash': splash,
    'introduction': introduction,
    'authentication': authentication,
    'new_account': newAccount,
    'time_line': food,
    'map': map,
    'my_profile': profile,
    'setting': setting,
    'license': license,
    'setting_tutorial': introduction,
    'notifications': notification,
    'stored_post': savedPosts,
    'stored_post_detail': postDetail,
    'memory_album_list': album,
    'memory_album_create': albumForm,
    'memory_album_detail': albumDetail,
    'memory_album_edit': albumForm,
    'my_profile_post': post,
    'edit': editProfile,
    'my_profile_detail': postDetail,
    'my_profile_edit_post': editPost,
    'my_profile_detail_post': post,
    'my_profile_restaurant': restaurant,
    'my_profile_restaurant_review': restaurantDetail,
    'restaurant_map_myProfile': restaurantMap,
    'time_line_post': post,
    'time_line_detail': postDetail,
    'time_line_detail_post': post,
    'time_line_edit_post': editPost,
    'time_line_restaurant': restaurant,
    'time_line_restaurant_review': restaurantDetail,
    'search_detail_post': postDetail,
    'time_line_profile': userProfile,
    'time_line_profile_detail': postDetail,
    'restaurant_map': restaurantMap,
    'map_detail': postDetail,
    'map_edit_post': editPost,
    'map_profile': userProfile,
    'map_profile_detail': postDetail,
    'map_detail_post': post,
    'map_restaurant_review': restaurantDetail,
    'image_editor': imageEditor,
  };

  /// Tab index → screen_name
  static String forTabIndex(int index) {
    return switch (index) {
      0 => map,
      1 => food,
      2 => record,
      3 => profile,
      4 => setting,
      _ => map,
    };
  }

  /// FirebaseAnalyticsObserver 用
  static String? nameExtractor(RouteSettings settings) {
    return resolve(settings.name);
  }

  /// RouterPath または既に PascalCase の名前を正規化
  static String? resolve(String? name) {
    if (name == null || name.isEmpty) {
      return null;
    }
    if (all.contains(name)) {
      return name;
    }
    return _routerPathToScreen[name];
  }
}
