import 'package:food_gram_app/core/local/shared_preference.dart';

/// デバッグ用の強制表示。
/// 確認したいときは `true` にする（本番では必ず `false` のまま）。
const bool debugForceFirstPostGuide = false;

/// 投稿ボタンへの初回誘導ガイドを表示すべきか。
Future<bool> shouldShowFirstPostGuide({
  required int postCount,
  Preference? preference,
}) async {
  if (debugForceFirstPostGuide) {
    return true;
  }
  if (postCount > 0) {
    return false;
  }
  final prefs = preference ?? Preference();
  final hasSeen = await prefs.getBool(PreferenceKey.hasSeenFirstPostGuide);
  return !hasSeen;
}

Future<void> markFirstPostGuideShown({Preference? preference}) async {
  if (debugForceFirstPostGuide) {
    return;
  }
  final prefs = preference ?? Preference();
  await prefs.setBool(PreferenceKey.hasSeenFirstPostGuide);
}

/// 初回投稿完了後のガイドを表示すべきか。
Future<bool> shouldShowFirstPostSuccessGuide({
  Preference? preference,
}) async {
  if (debugForceFirstPostGuide) {
    return true;
  }
  final prefs = preference ?? Preference();
  final hasSeen =
      await prefs.getBool(PreferenceKey.hasSeenFirstPostSuccessGuide);
  return !hasSeen;
}

Future<void> markFirstPostSuccessGuideShown({Preference? preference}) async {
  if (debugForceFirstPostGuide) {
    return;
  }
  final prefs = preference ?? Preference();
  await prefs.setBool(PreferenceKey.hasSeenFirstPostSuccessGuide);
}
