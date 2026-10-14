/// 投稿の合計数。非公開も含む。順位はまだ付けない。
class PublicPostCount {
  const PublicPostCount({
    required this.userId,
    required this.name,
    required this.image,
    required this.postCount,
  });

  final String userId;
  final String name;
  final String image;
  final int postCount;
}

/// 投稿の合計数での全体順位。
class PostCountRankingEntry {
  const PostCountRankingEntry({
    required this.userId,
    required this.name,
    required this.image,
    required this.postCount,
    required this.rank,
  });

  final String userId;
  final String name;
  final String image;
  final int postCount;
  final int rank;
}

/// 投稿数の多い順。同数は同じ順位にし、次の順位は飛ばす。
List<PostCountRankingEntry> rankPublicPostCounts(
  Iterable<PublicPostCount> counts, {
  Set<String> excludedUserIds = const {},
}) {
  final visible = counts
      .where(
        (count) =>
            count.postCount > 0 &&
            count.userId.isNotEmpty &&
            !excludedUserIds.contains(count.userId),
      )
      .toList()
    ..sort((a, b) {
      final byCount = b.postCount.compareTo(a.postCount);
      if (byCount != 0) {
        return byCount;
      }
      final byName = a.name.compareTo(b.name);
      if (byName != 0) {
        return byName;
      }
      return a.userId.compareTo(b.userId);
    });

  final ranked = <PostCountRankingEntry>[];
  var rank = 0;
  var previousCount = -1;
  for (var i = 0; i < visible.length; i++) {
    final count = visible[i];
    if (count.postCount != previousCount) {
      rank = i + 1;
      previousCount = count.postCount;
    }
    ranked.add(
      PostCountRankingEntry(
        userId: count.userId,
        name: count.name,
        image: count.image,
        postCount: count.postCount,
        rank: rank,
      ),
    );
  }
  return ranked;
}
