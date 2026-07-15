/// FoodGram Analytics v1.0 イベント名
/// 命名規則: snake_case / `{object}_{action}` （open / create / success / failed など）
abstract final class AnalyticsEvent {
  // --- アプリ起動 ---
  static const String appOpen = 'app_open';
  static const String appBackground = 'app_background';
  static const String appForeground = 'app_foreground';

  // --- プッシュ通知 ---
  static const String pushOpen = 'push_open';
  static const String pushReceive = 'push_receive';

  // --- チュートリアル ---
  static const String tutorialStart = 'tutorial_start';
  static const String tutorialComplete = 'tutorial_complete';

  // --- タイムライン (Food) ---
  static const String timelineOpen = 'timeline_open';
  static const String timelinePostImpression = 'timeline_post_impression';
  static const String timelinePostOpen = 'timeline_post_open';
  static const String timelinePostLike = 'timeline_post_like';
  static const String timelinePostSave = 'timeline_post_save';
  static const String timelinePostShare = 'timeline_post_share';
  static const String timelineRefresh = 'timeline_refresh';

  // --- 投稿 ---
  static const String postStart = 'post_start';
  static const String postPhotoSelected = 'post_photo_selected';
  static const String postMultiplePhotoSelected =
      'post_multiple_photo_selected';
  static const String postRestaurantAutoDetectSuccess =
      'post_restaurant_auto_detect_success';
  static const String postRestaurantAutoDetectFail =
      'post_restaurant_auto_detect_fail';
  static const String postRestaurantAutoDetectSelected =
      'post_restaurant_auto_detect_selected';
  static const String postRestaurantAutoDetectChanged =
      'post_restaurant_auto_detect_changed';
  static const String postRestaurantManualSearch =
      'post_restaurant_manual_search';
  static const String postRestaurantManualSelected =
      'post_restaurant_manual_selected';
  static const String postTagSelected = 'post_tag_selected';
  static const String postPriceInput = 'post_price_input';
  static const String postRatingInput = 'post_rating_input';
  static const String postCommentInput = 'post_comment_input';
  static const String postCompleteWithComment = 'post_complete_with_comment';
  static const String postCompleteWithoutComment =
      'post_complete_without_comment';
  static const String postSuccess = 'post_success';
  static const String postFailed = 'post_failed';
  static const String postEdit = 'post_edit';
  static const String postEditComplete = 'post_edit_complete';
  static const String postDelete = 'post_delete';
  static const String postDetailOpen = 'post_detail_open';
  static const String postLike = 'post_like';
  static const String postSave = 'post_save';
  static const String postShare = 'post_share';
  static const String postShareImage = 'post_share_image';
  static const String postShareLink = 'post_share_link';
  static const String postTranslate = 'post_translate';

  // --- 下書き ---
  static const String draftSave = 'draft_save';
  static const String draftOpen = 'draft_open';
  static const String draftDelete = 'draft_delete';
  static const String draftPost = 'draft_post';

  // --- マップ ---
  static const String mapOpen = 'map_open';
  static const String mapPinTap = 'map_pin_tap';
  static const String mapSearch = 'map_search';
  static const String mapSearchResultTap = 'map_search_result_tap';
  static const String mapPostOpen = 'map_post_open';
  static const String mapClusterTap = 'map_cluster_tap';
  static const String mapFilterOpen = 'map_filter_open';
  static const String mapFilterApply = 'map_filter_apply';
  static const String mapShare = 'map_share';
  static const String mapStatsShare = 'map_stats_share';

  // --- マイマップ / Record ---
  static const String myMapOpen = 'mymap_open';
  static const String japanMapOpen = 'japan_map_open';
  static const String worldMapOpen = 'world_map_open';
  static const String myMapPrefectureTap = 'mymap_prefecture_tap';
  static const String myMapCountryTap = 'mymap_country_tap';
  static const String prefectureComplete = 'prefecture_complete';
  static const String countryComplete = 'country_complete';
  static const String prefectureProgressView = 'prefecture_progress_view';
  static const String countryProgressView = 'country_progress_view';
  static const String recordOpen = 'record_open';
  static const String recordSummaryOpen = 'record_summary_open';
  static const String recordYearOpen = 'record_year_open';
  static const String recordRecentPostOpen = 'record_recent_post_open';
  static const String recordStatisticsOpen = 'record_statistics_open';
  static const String recordPostOpen = 'record_post_open';
  static const String recordShare = 'record_share';

  // --- 食の特徴分析 ---
  static const String insightOpen = 'insight_open';
  static const String foodInsightAreaOpen = 'food_insight_area_open';
  static const String foodInsightGenreOpen = 'food_insight_genre_open';
  static const String foodInsightTimeOpen = 'food_insight_time_open';
  static const String foodInsightRestaurantOpen =
      'food_insight_restaurant_open';
  static const String foodInsightShare = 'food_insight_share';
  static const String firstInsightOpen = 'first_insight_open';

  // --- アルバム ---
  static const String albumOpen = 'album_open';
  static const String albumDetailOpen = 'album_detail_open';
  static const String albumCreate = 'album_create';
  static const String albumEdit = 'album_edit';
  static const String albumEditComplete = 'album_edit_complete';
  static const String albumDelete = 'album_delete';
  static const String albumAddPost = 'album_add_post';
  static const String albumRemovePost = 'album_remove_post';
  static const String savedPostOpen = 'saved_post_open';
  static const String savedAlbumOpen = 'saved_album_open';
  static const String foodMemoryOpen = 'food_memory_open';

  // --- 通知 ---
  static const String notificationOpen = 'notification_open';
  static const String notificationPostOpen = 'notification_post_open';
  static const String notificationLikeOpen = 'notification_like_open';
  static const String notificationFollowOpen = 'notification_follow_open';
  static const String notificationCommentOpen = 'notification_comment_open';

  // --- レストラン ---
  static const String restaurantOpen = 'restaurant_open';
  static const String restaurantDetailOpen = 'restaurant_detail_open';
  static const String restaurantReviewOpen = 'restaurant_review_open';
  static const String restaurantReviewPostOpen = 'restaurant_review_post_open';
  static const String restaurantRevisitOpen = 'restaurant_revisit_open';

  // --- プロフィール / 設定 / ランキング ---
  static const String profileOpen = 'profile_open';
  static const String profileEdit = 'profile_edit';
  static const String profileShare = 'profile_share';
  static const String profileLevelOpen = 'profile_level_open';
  static const String settingOpen = 'setting_open';
  static const String rankingOpen = 'ranking_open';

  // --- Premium ---
  static const String paywallOpen = 'paywall_open';
  static const String purchaseStart = 'purchase_start';
  static const String purchaseSuccess = 'purchase_success';
  static const String purchaseFailed = 'purchase_failed';
  static const String premiumFeatureTap = 'premium_feature_tap';
  static const String premiumAlbumTap = 'premium_album_tap';
  static const String premiumSatelliteMapTap = 'premium_satellite_map_tap';
  static const String premiumRankingTap = 'premium_ranking_tap';
  static const String premiumProfileCustomizationTap =
      'premium_profile_customization_tap';

  // --- マイルストーン / FoodGram ---
  static const String firstRecordOpen = 'first_record_open';
  static const String firstJapanMapOpen = 'first_japan_map_open';
  static const String firstWorldMapOpen = 'first_world_map_open';
  static const String firstPostWithComment = 'first_post_with_comment';
  static const String firstPostWithRestaurant = 'first_post_with_restaurant';
  static const String yearlySummaryOpen = 'yearly_summary_open';
  static const String monthlySummaryOpen = 'monthly_summary_open';
  static const String streakView = 'streak_view';
  static const String streakContinue = 'streak_continue';
  static const String streakBreak = 'streak_break';
  static const String user10Posts = 'user_10_posts';
  static const String user50Posts = 'user_50_posts';
  static const String user100Posts = 'user_100_posts';
  static const String user500Posts = 'user_500_posts';
  static const String userFirstCountryComplete = 'user_first_country_complete';
  static const String userFirstPrefectureComplete =
      'user_first_prefecture_complete';

  // --- 認証 ---
  static const String login = 'login';

  @Deprecated('Use postTranslate instead')
  static const String translateTap = 'post_translate';
}

/// イベントパラメータ名（Firebase 予約語を避けた snake_case）
abstract final class AnalyticsParam {
  static const String method = 'method';
  static const String postId = 'post_id';
  static const String source = 'source';
  static const String query = 'query';
  static const String pushType = 'push_type';
  static const String errorReason = 'error_reason';
  static const String regionName = 'region_name';
  static const String shareType = 'share_type';
  static const String category = 'category';
  static const String tag = 'tag';
  static const String albumId = 'album_id';
  static const String premiumFeature = 'premium_feature';
  static const String photoCount = 'photo_count';
  static const String rating = 'rating';
  static const String hasComment = 'has_comment';
  static const String streakWeeks = 'streak_weeks';
}
