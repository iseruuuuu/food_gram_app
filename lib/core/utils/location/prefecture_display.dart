import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/utils/location/prefecture_detector.dart';

/// 記録タブ日本ビュー用の都道府県ごとの投稿集計
class RecordPrefectureVisit {
  const RecordPrefectureVisit({
    required this.name,
    required this.postCount,
    required this.firstVisitedAt,
    required this.lastVisitedAt,
    required this.firstPost,
    required this.latestPost,
  });

  final String name;
  final int postCount;
  final DateTime firstVisitedAt;
  final DateTime lastVisitedAt;
  final Posts firstPost;
  final Posts latestPost;
}

/// ロケールに合わせた都道府県名。日本語以外は英語名を返す
String localizedPrefectureName({
  required String name,
  required String languageCode,
}) {
  if (languageCode == 'ja') {
    return name;
  }
  return _englishPrefectureNames[name] ?? name;
}

/// 投稿から訪れた都道府県を新しい順に集計する
List<RecordPrefectureVisit> recordVisitedPrefectureStats(List<Posts> posts) {
  final byName = <String, _PrefectureVisitAcc>{};
  for (final post in posts) {
    if (post.lat == 0 && post.lng == 0) {
      continue;
    }
    final prefecture = PrefectureDetector.detectPrefecture(post.lat, post.lng);
    if (prefecture == null) {
      continue;
    }
    final current = byName[prefecture];
    if (current == null) {
      byName[prefecture] = _PrefectureVisitAcc(
        name: prefecture,
        postCount: 1,
        firstVisitedAt: post.createdAt,
        lastVisitedAt: post.createdAt,
        firstPost: post,
        latestPost: post,
      );
    } else {
      current.postCount += 1;
      if (post.createdAt.isAfter(current.lastVisitedAt)) {
        current.lastVisitedAt = post.createdAt;
        current.latestPost = post;
      }
      if (post.createdAt.isBefore(current.firstVisitedAt)) {
        current.firstVisitedAt = post.createdAt;
        current.firstPost = post;
      }
    }
  }
  final visits = byName.values
      .map(
        (acc) => RecordPrefectureVisit(
          name: acc.name,
          postCount: acc.postCount,
          firstVisitedAt: acc.firstVisitedAt,
          lastVisitedAt: acc.lastVisitedAt,
          firstPost: acc.firstPost,
          latestPost: acc.latestPost,
        ),
      )
      .toList()
    ..sort((a, b) {
      final dateCompare = b.lastVisitedAt.compareTo(a.lastVisitedAt);
      if (dateCompare != 0) {
        return dateCompare;
      }
      return b.postCount.compareTo(a.postCount);
    });
  return visits;
}

/// 投稿数が多い都道府県ランキング
List<RecordPrefectureVisit> recordPrefectureRanking(
  List<Posts> posts, {
  int limit = 3,
}) {
  final ranking = [...recordVisitedPrefectureStats(posts)]..sort((a, b) {
      final countCompare = b.postCount.compareTo(a.postCount);
      if (countCompare != 0) {
        return countCompare;
      }
      return b.lastVisitedAt.compareTo(a.lastVisitedAt);
    });
  if (ranking.length <= limit) {
    return ranking;
  }
  return ranking.sublist(0, limit);
}

/// 初めて訪れた都道府県（最初の投稿が最も古い県）
RecordPrefectureVisit? recordFirstVisitedPrefecture(List<Posts> posts) {
  final visits = recordVisitedPrefectureStats(posts);
  if (visits.isEmpty) {
    return null;
  }
  return visits.reduce(
    (current, next) =>
        next.firstVisitedAt.isBefore(current.firstVisitedAt) ? next : current,
  );
}

/// 都道府県名ごとの投稿数（地図の塗りつぶし用）
Map<String, int> recordPrefecturePostCounts(List<Posts> posts) {
  final counts = <String, int>{};
  for (final visit in recordVisitedPrefectureStats(posts)) {
    counts[visit.name] = visit.postCount;
  }
  return counts;
}

class _PrefectureVisitAcc {
  _PrefectureVisitAcc({
    required this.name,
    required this.postCount,
    required this.firstVisitedAt,
    required this.lastVisitedAt,
    required this.firstPost,
    required this.latestPost,
  });

  final String name;
  int postCount;
  DateTime firstVisitedAt;
  DateTime lastVisitedAt;
  Posts firstPost;
  Posts latestPost;
}

const _englishPrefectureNames = <String, String>{
  '北海道': 'Hokkaido',
  '青森県': 'Aomori',
  '岩手県': 'Iwate',
  '宮城県': 'Miyagi',
  '秋田県': 'Akita',
  '山形県': 'Yamagata',
  '福島県': 'Fukushima',
  '茨城県': 'Ibaraki',
  '栃木県': 'Tochigi',
  '群馬県': 'Gunma',
  '埼玉県': 'Saitama',
  '千葉県': 'Chiba',
  '東京都': 'Tokyo',
  '神奈川県': 'Kanagawa',
  '新潟県': 'Niigata',
  '富山県': 'Toyama',
  '石川県': 'Ishikawa',
  '福井県': 'Fukui',
  '山梨県': 'Yamanashi',
  '長野県': 'Nagano',
  '岐阜県': 'Gifu',
  '静岡県': 'Shizuoka',
  '愛知県': 'Aichi',
  '三重県': 'Mie',
  '滋賀県': 'Shiga',
  '京都府': 'Kyoto',
  '大阪府': 'Osaka',
  '兵庫県': 'Hyogo',
  '奈良県': 'Nara',
  '和歌山県': 'Wakayama',
  '鳥取県': 'Tottori',
  '島根県': 'Shimane',
  '岡山県': 'Okayama',
  '広島県': 'Hiroshima',
  '山口県': 'Yamaguchi',
  '徳島県': 'Tokushima',
  '香川県': 'Kagawa',
  '愛媛県': 'Ehime',
  '高知県': 'Kochi',
  '福岡県': 'Fukuoka',
  '佐賀県': 'Saga',
  '長崎県': 'Nagasaki',
  '熊本県': 'Kumamoto',
  '大分県': 'Oita',
  '宮崎県': 'Miyazaki',
  '鹿児島県': 'Kagoshima',
  '沖縄県': 'Okinawa',
};
