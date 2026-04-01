/// ローカル保存用アルバム（メタデータのみ。投稿 ID は SharedPreferences の別キー）
class SaveAlbum {
  const SaveAlbum({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

/// 無料は上限あり、サブスクは実質無制限
abstract final class SaveAlbumLimits {
  static const int freeMaxAlbums = 5;
  static const int freeMaxPostsPerAlbum = 100;

  static const int premiumMaxAlbums = 10000;
  static const int premiumMaxPostsPerAlbum = 100000;
}

enum SaveAlbumIssue {
  emptyName,
  albumLimitFree,
  postLimitFree,
  postNotInSavedList,
}
