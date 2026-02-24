/// 投稿数に基づくユーザーレベル計算（Lv1〜Lv150）
///
/// しきい値の意味: 配列のインデックス L の要素 = そのLvに到達するための累計投稿数。
/// Lv1〜61 はドキュメント準拠。Lv62以降は同様の間隔（+31, +32, +33...）で Lv150 まで拡張。
class UserLevel {
  UserLevel._();

  /// Lv1〜Lv150 の累計投稿数（Lv1〜61 はドキュメント準拠、Lv62〜は +31,+32,+33... で拡張）
  static final List<int> _thresholds = () {
    final list = [
      0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153,
      171, 190, 205, 220, 236, 252, 269, 286, 304, 322, 340, 359, 378, 398, 417,
      437, 457, 477, 498, 519, 540, 562, 584, 607, 630, 653, 677, 701, 726, 751,
      776, 802, 828, 855, 882, 909, 937, 965, 994, 1024, 1054, 1085, 1116,
    ];
    for (var inc = 31; list.length < 150; inc++) {
      list.add(list.last + inc);
    }
    return list;
  }();

  /// 最大レベル（このレベル以上は同じ扱い）
  static const int maxLevel = 150;

  /// 累計投稿数から現在のレベルを算出（1始まり）
  static int levelFromPostCount(int postCount) {
    if (postCount < 0) {
      return 1;
    }
    for (var l = _thresholds.length - 1; l >= 1; l--) {
      if (postCount >= _thresholds[l - 1]) {
        return l;
      }
    }
    return 1;
  }

  /// 次のレベルまでにあと何投稿必要か。既に最大レベルなら null
  static int? postsNeededForNextLevel(int postCount) {
    final level = levelFromPostCount(postCount);
    if (level >= maxLevel) {
      return null;
    }
    final nextThreshold =
        _thresholds[level]; // 0-indexed: level の次 = index level
    return nextThreshold - postCount;
  }

  /// 現在のレベル内で、次のレベルに向かって何投稿済みか（このレベルで「あと何で次」の分母用）
  static int postsInCurrentLevelTowardsNext(int postCount) {
    final level = levelFromPostCount(postCount);
    if (level >= maxLevel) {
      return 0;
    }
    final currentThreshold = _thresholds[level - 1];
    return postCount - currentThreshold;
  }

  /// 次のレベルまでに必要な総投稿数（このレベル内で）
  static int postsRequiredInCurrentLevel(int postCount) {
    final level = levelFromPostCount(postCount);
    if (level >= maxLevel) {
      return 0;
    }
    final currentThreshold = _thresholds[level - 1];
    final nextThreshold = _thresholds[level];
    return nextThreshold - currentThreshold;
  }

  /// 次のレベルまでの進捗 0.0 〜 1.0。最大レベルなら 1.0
  static double progressToNextLevel(int postCount) {
    final level = levelFromPostCount(postCount);
    if (level >= maxLevel) {
      return 1;
    }
    final currentThreshold = _thresholds[level - 1];
    final nextThreshold = _thresholds[level];
    final range = nextThreshold - currentThreshold;
    if (range <= 0) {
      return 1;
    }
    final progress = (postCount - currentThreshold).clamp(0, range);
    return progress / range;
  }

  /// 次のレベル番号。最大レベルなら null
  static int? nextLevelNumber(int postCount) {
    final level = levelFromPostCount(postCount);
    if (level >= maxLevel) {
      return null;
    }
    return level + 1;
  }
}
