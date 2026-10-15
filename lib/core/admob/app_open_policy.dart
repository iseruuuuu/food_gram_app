import 'package:food_gram_app/core/admob/config/admob_config.dart';
import 'package:food_gram_app/ui/screen/tab/tab_state.dart';

/// 投稿作成・編集中のパス断片。`RouterPath` と同じ文字列。
const _postingSegments = <String>{
  'time_line_post',
  'time_line_detail_post',
  'time_line_edit_post',
  'my_profile_post',
  'my_profile_detail_post',
  'my_profile_edit_post',
  'map_detail_post',
  'map_edit_post',
  'image_editor',
};

/// 前面復帰でアプリオープンを出してよいか。
///
/// 起動直後（バックグラウンド記録がない）は出さない。
/// バックグラウンドが短い、前回表示から4時間未満、投稿中・地図表示中も出さない。
bool shouldShowAppOpenOnResume({
  required DateTime? backgroundedAt,
  required DateTime now,
  required DateTime? lastShownAt,
  required bool screenBlocksAd,
}) {
  if (screenBlocksAd || backgroundedAt == null) {
    return false;
  }
  if (now.difference(backgroundedAt) < minBackgroundForAppOpen) {
    return false;
  }
  if (lastShownAt != null &&
      now.difference(lastShownAt) < minAppOpenDuration) {
    return false;
  }
  return true;
}

/// 投稿の作成・編集中、または地図そのものを見ているときは true。
bool appOpenBlockedByScreen({
  required String location,
  required int? selectedTab,
}) {
  final segments = location.split('/').where((segment) => segment.isNotEmpty);
  if (segments.any(_postingSegments.contains)) {
    return true;
  }
  final normalized = _stripTrailingSlash(location);
  if (normalized == '/tab/map') {
    return true;
  }
  return normalized == '/tab' && selectedTab == TabIndex.map;
}

String _stripTrailingSlash(String location) {
  if (location.length > 1 && location.endsWith('/')) {
    return location.substring(0, location.length - 1);
  }
  return location;
}
