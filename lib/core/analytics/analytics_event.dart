/// Firebase Analytics のカスタムイベント名
abstract final class AnalyticsEvent {
  static const String appOpen = 'app_open';
  static const String pushOpen = 'push_open';

  static const String mapOpen = 'map_open';
  static const String mapPinTap = 'map_pin_tap';
  static const String mapSearch = 'map_search';
  static const String mapSearchResultTap = 'map_search_result_tap';

  static const String postStart = 'post_start';
  static const String postSuccess = 'post_success';
  static const String postFailed = 'post_failed';

  static const String postDetailOpen = 'post_detail_open';
  static const String postSave = 'post_save';
  static const String postShare = 'post_share';

  static const String draftSave = 'draft_save';
  static const String draftPost = 'draft_post';

  static const String myMapOpen = 'mymap_open';
  static const String myMapPrefectureTap = 'mymap_prefecture_tap';
  static const String myMapCountryTap = 'mymap_country_tap';

  static const String recordOpen = 'record_open';
  static const String insightOpen = 'insight_open';

  static const String albumCreate = 'album_create';
  static const String albumAddPost = 'album_add_post';

  static const String translateTap = 'translate_tap';

  static const String paywallOpen = 'paywall_open';
  static const String purchaseStart = 'purchase_start';
  static const String purchaseSuccess = 'purchase_success';

  // 既存イベント（互換）
  static const String login = 'login';
  static const String tutorialComplete = 'tutorial_complete';
}

/// イベントパラメータ名（Firebase 予約語を避けたスネークケース）
abstract final class AnalyticsParam {
  static const String method = 'method';
  static const String postId = 'post_id';
  static const String source = 'source';
  static const String query = 'query';
  static const String pushType = 'push_type';
  static const String errorReason = 'error_reason';
  static const String regionName = 'region_name';
  static const String shareType = 'share_type';
}
