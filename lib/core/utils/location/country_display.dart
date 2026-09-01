import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/utils/location/country_detector.dart';

/// 記録タブ世界ビュー用の国ごとの投稿集計
class RecordCountryVisit {
  const RecordCountryVisit({
    required this.code,
    required this.name,
    required this.postCount,
    required this.lastVisitedAt,
  });

  final String code;
  final String name;
  final int postCount;
  final DateTime lastVisitedAt;
}

/// ISO 3166-1 alpha-2 から旗絵文字を作る
String countryFlagEmoji(String countryCode) {
  final code = countryCode.toUpperCase();
  if (code.length != 2) {
    return '🌍';
  }
  return String.fromCharCodes(
    code.codeUnits.map((unit) => 0x1F1E6 - 0x41 + unit),
  );
}

/// ロケールに合わせた国名。日本語以外は英語名を返す
String localizedCountryName({
  required String code,
  required String japaneseName,
  required String languageCode,
}) {
  if (languageCode == 'ja') {
    return japaneseName;
  }
  return _englishCountryNames[code] ?? japaneseName;
}

/// 投稿から訪れた国を新しい順に集計する
List<RecordCountryVisit> recordVisitedCountryStats(List<Posts> posts) {
  final byCode = <String, _CountryVisitAcc>{};
  for (final post in posts) {
    if (post.lat == 0 && post.lng == 0) {
      continue;
    }
    final country = CountryDetector.find(post.lat, post.lng);
    if (country == null) {
      continue;
    }
    final current = byCode[country.code];
    if (current == null) {
      byCode[country.code] = _CountryVisitAcc(
        code: country.code,
        name: country.name,
        postCount: 1,
        lastVisitedAt: post.createdAt,
      );
    } else {
      current.postCount += 1;
      if (post.createdAt.isAfter(current.lastVisitedAt)) {
        current.lastVisitedAt = post.createdAt;
      }
    }
  }
  final visits = byCode.values
      .map(
        (acc) => RecordCountryVisit(
          code: acc.code,
          name: acc.name,
          postCount: acc.postCount,
          lastVisitedAt: acc.lastVisitedAt,
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

/// 国コードごとの投稿数（地図の塗りつぶし用）
Map<String, int> recordCountryPostCounts(List<Posts> posts) {
  final counts = <String, int>{};
  for (final visit in recordVisitedCountryStats(posts)) {
    counts[visit.code] = visit.postCount;
  }
  return counts;
}

class _CountryVisitAcc {
  _CountryVisitAcc({
    required this.code,
    required this.name,
    required this.postCount,
    required this.lastVisitedAt,
  });

  final String code;
  final String name;
  int postCount;
  DateTime lastVisitedAt;
}

const _englishCountryNames = <String, String>{
  'JP': 'Japan',
  'KR': 'South Korea',
  'HK': 'Hong Kong',
  'TW': 'Taiwan',
  'MO': 'Macau',
  'CN': 'China',
  'TH': 'Thailand',
  'VN': 'Vietnam',
  'SG': 'Singapore',
  'MY': 'Malaysia',
  'ID': 'Indonesia',
  'PH': 'Philippines',
  'IN': 'India',
  'KH': 'Cambodia',
  'LA': 'Laos',
  'MM': 'Myanmar',
  'LK': 'Sri Lanka',
  'BD': 'Bangladesh',
  'PK': 'Pakistan',
  'NP': 'Nepal',
  'MN': 'Mongolia',
  'TR': 'Turkey',
  'AE': 'UAE',
  'IL': 'Israel',
  'SA': 'Saudi Arabia',
  'EG': 'Egypt',
  'MA': 'Morocco',
  'US': 'USA',
  'CA': 'Canada',
  'MX': 'Mexico',
  'GB': 'United Kingdom',
  'FR': 'France',
  'DE': 'Germany',
  'IT': 'Italy',
  'ES': 'Spain',
  'CH': 'Switzerland',
  'NL': 'Netherlands',
  'BE': 'Belgium',
  'AT': 'Austria',
  'PL': 'Poland',
  'SE': 'Sweden',
  'NO': 'Norway',
  'DK': 'Denmark',
  'FI': 'Finland',
  'PT': 'Portugal',
  'GR': 'Greece',
  'CZ': 'Czechia',
  'HU': 'Hungary',
  'RU': 'Russia',
  'BR': 'Brazil',
  'AR': 'Argentina',
  'CL': 'Chile',
  'PE': 'Peru',
  'CO': 'Colombia',
  'AU': 'Australia',
  'NZ': 'New Zealand',
  'ZA': 'South Africa',
  'KE': 'Kenya',
  'TZ': 'Tanzania',
};
