/// FoodGram Analytics v1.0 イベント名
/// 命名規則: snake_case / `{object}_{action}` （open / create / success / failed など）
abstract final class AnalyticsEvent {
  // --- アプリ起動 ---
  static const appOpen = 'app_open';
  static const appBackground = 'app_background';
  static const appForeground = 'app_foreground';

  // --- プッシュ通知 ---
  static const pushOpen = 'push_open';
  static const pushReceive = 'push_receive';

  // --- チュートリアル ---
  static const tutorialStart = 'tutorial_start';
  static const tutorialComplete = 'tutorial_complete';
  static const firstPostGuideShow = 'first_post_guide_show';
  static const firstPostGuideTap = 'first_post_guide_tap';
  static const firstPostGuideDismiss = 'first_post_guide_dismiss';
  static const firstPostSuccessGuideShow =
      'first_post_success_guide_show';
  static const firstPostSuccessGuideMap = 'first_post_success_guide_map';
  static const firstPostSuccessGuideAlbum =
      'first_post_success_guide_album';
  static const firstPostSuccessGuideLater =
      'first_post_success_guide_later';

  // --- タイムライン (Food) ---
  static const timelineOpen = 'timeline_open';
  static const timelinePostImpression = 'timeline_post_impression';
  static const timelinePostOpen = 'timeline_post_open';
  static const timelinePostLike = 'timeline_post_like';
  static const timelinePostSave = 'timeline_post_save';
  static const timelinePostShare = 'timeline_post_share';
  static const timelineRefresh = 'timeline_refresh';
  static const timelineFriendTab = 'timeline_friend_tab';
  static const friendAddOpen = 'friend_add_open';
  static const friendAddSuccess = 'friend_add_success';
  static const friendAddFailed = 'friend_add_failed';

  // --- 投稿 ---
  static const postStart = 'post_start';
  static const postPhotoSelected = 'post_photo_selected';
  static const postMultiplePhotoSelected =
      'post_multiple_photo_selected';
  static const postRestaurantAutoDetectSuccess =
      'post_restaurant_auto_detect_success';
  static const postRestaurantAutoDetectFail =
      'post_restaurant_auto_detect_fail';
  static const postRestaurantAutoDetectSelected =
      'post_restaurant_auto_detect_selected';
  static const postRestaurantAutoDetectChanged =
      'post_restaurant_auto_detect_changed';
  static const postRestaurantManualSearch =
      'post_restaurant_manual_search';
  static const postRestaurantManualSelected =
      'post_restaurant_manual_selected';
  static const postTagSelected = 'post_tag_selected';
  static const postPriceInput = 'post_price_input';
  static const postRatingInput = 'post_rating_input';
  static const postCommentInput = 'post_comment_input';
  static const postCompleteWithComment = 'post_complete_with_comment';
  static const postCompleteWithoutComment =
      'post_complete_without_comment';
  static const postSuccess = 'post_success';
  static const postFailed = 'post_failed';
  static const postEdit = 'post_edit';
  static const postEditComplete = 'post_edit_complete';
  static const postDelete = 'post_delete';
  static const postDetailOpen = 'post_detail_open';
  static const postLike = 'post_like';
  static const postSave = 'post_save';
  static const postShare = 'post_share';
  static const postShareImage = 'post_share_image';
  static const postShareLink = 'post_share_link';
  static const postTranslate = 'post_translate';

  // --- 下書き ---
  static const draftSave = 'draft_save';
  static const draftOpen = 'draft_open';
  static const draftDelete = 'draft_delete';
  static const draftPost = 'draft_post';

  // --- マップ ---
  static const mapOpen = 'map_open';
  static const mapPinTap = 'map_pin_tap';
  static const mapSearch = 'map_search';
  static const mapSearchResultTap = 'map_search_result_tap';
  static const mapPostOpen = 'map_post_open';
  static const mapClusterTap = 'map_cluster_tap';
  static const mapFilterOpen = 'map_filter_open';
  static const mapFilterApply = 'map_filter_apply';
  static const mapShare = 'map_share';
  static const mapStatsShare = 'map_stats_share';

  // --- マイマップ / Record ---
  static const myMapOpen = 'mymap_open';
  static const japanMapOpen = 'japan_map_open';
  static const worldMapOpen = 'world_map_open';
  static const myMapPrefectureTap = 'mymap_prefecture_tap';
  static const myMapCountryTap = 'mymap_country_tap';
  static const prefectureComplete = 'prefecture_complete';
  static const countryComplete = 'country_complete';
  static const prefectureProgressView = 'prefecture_progress_view';
  static const countryProgressView = 'country_progress_view';
  static const recordOpen = 'record_open';
  static const recordSummaryOpen = 'record_summary_open';
  static const recordYearOpen = 'record_year_open';
  static const recordRecentPostOpen = 'record_recent_post_open';
  static const recordStatisticsOpen = 'record_statistics_open';
  static const recordPostOpen = 'record_post_open';
  static const recordShare = 'record_share';

  // --- 食の特徴分析 ---
  static const insightOpen = 'insight_open';
  static const foodInsightAreaOpen = 'food_insight_area_open';
  static const foodInsightGenreOpen = 'food_insight_genre_open';
  static const foodInsightTimeOpen = 'food_insight_time_open';
  static const foodInsightRestaurantOpen =
      'food_insight_restaurant_open';
  static const foodInsightShare = 'food_insight_share';
  static const firstInsightOpen = 'first_insight_open';

  // --- アルバム ---
  static const albumOpen = 'album_open';
  static const albumDetailOpen = 'album_detail_open';
  static const albumCreate = 'album_create';
  static const albumEdit = 'album_edit';
  static const albumEditComplete = 'album_edit_complete';
  static const albumDelete = 'album_delete';
  static const albumAddPost = 'album_add_post';
  static const albumRemovePost = 'album_remove_post';
  static const savedPostOpen = 'saved_post_open';
  static const savedAlbumOpen = 'saved_album_open';
  static const foodMemoryOpen = 'food_memory_open';

  // --- 通知 ---
  static const notificationOpen = 'notification_open';
  static const notificationPostOpen = 'notification_post_open';
  static const notificationLikeOpen = 'notification_like_open';
  static const notificationFollowOpen = 'notification_follow_open';
  static const notificationCommentOpen = 'notification_comment_open';

  // --- レストラン ---
  static const restaurantOpen = 'restaurant_open';
  static const restaurantDetailOpen = 'restaurant_detail_open';
  static const restaurantReviewOpen = 'restaurant_review_open';
  static const restaurantReviewPostOpen = 'restaurant_review_post_open';
  static const restaurantRevisitOpen = 'restaurant_revisit_open';

  // --- プロフィール / 設定 / ランキング ---
  static const profileOpen = 'profile_open';
  static const profileEdit = 'profile_edit';
  static const profileShare = 'profile_share';
  static const profileLevelOpen = 'profile_level_open';
  static const settingOpen = 'setting_open';
  static const rankingOpen = 'ranking_open';

  // --- Premium ---
  static const paywallOpen = 'paywall_open';
  static const purchaseStart = 'purchase_start';
  static const purchaseSuccess = 'purchase_success';
  static const purchaseFailed = 'purchase_failed';
  static const premiumFeatureTap = 'premium_feature_tap';
  static const premiumAlbumTap = 'premium_album_tap';
  static const premiumSatelliteMapTap = 'premium_satellite_map_tap';
  static const premiumRankingTap = 'premium_ranking_tap';
  static const premiumProfileCustomizationTap =
      'premium_profile_customization_tap';
  static const premiumRemoveAdsTap = 'premium_remove_ads_tap';

  // --- マイルストーン / FoodGram ---
  static const firstRecordOpen = 'first_record_open';
  static const firstJapanMapOpen = 'first_japan_map_open';
  static const firstWorldMapOpen = 'first_world_map_open';
  static const firstPostWithComment = 'first_post_with_comment';
  static const firstPostWithRestaurant = 'first_post_with_restaurant';
  static const yearlySummaryOpen = 'yearly_summary_open';
  static const monthlySummaryOpen = 'monthly_summary_open';
  static const streakView = 'streak_view';
  static const streakContinue = 'streak_continue';
  static const streakBreak = 'streak_break';
  static const user10Posts = 'user_10_posts';
  static const user50Posts = 'user_50_posts';
  static const user100Posts = 'user_100_posts';
  static const user500Posts = 'user_500_posts';
  static const userFirstCountryComplete = 'user_first_country_complete';
  static const userFirstPrefectureComplete =
      'user_first_prefecture_complete';

  // --- 認証 ---
  static const login = 'login';

  @Deprecated('Use postTranslate instead')
  static const translateTap = 'post_translate';
}

/// イベントパラメータ名（Firebase 予約語を避けた snake_case）
abstract final class AnalyticsParam {
  static const method = 'method';
  static const postId = 'post_id';
  static const source = 'source';
  static const query = 'query';
  static const pushType = 'push_type';
  static const errorReason = 'error_reason';
  static const regionName = 'region_name';
  static const shareType = 'share_type';
  static const category = 'category';
  static const tag = 'tag';
  static const albumId = 'album_id';
  static const premiumFeature = 'premium_feature';
  static const photoCount = 'photo_count';
  static const rating = 'rating';
  static const hasComment = 'has_comment';
  static const streakWeeks = 'streak_weeks';
}
