import 'package:food_gram_app/core/utils/map_stats_presentation.dart';

/// シェア画像の一文を選ぶための進捗。
enum MapShareStoryKind {
  empty,
  japanHereNeighbor,
  japanSpreadNeighbor,
  japanHereBlank,
  japanSpreadBlank,
  japanComplete,
  worldOneContinent,
  worldSpread,
  worldAllContinents,
  worldComplete,
  worldProgress,
}

/// シェアカードに載せる、訪れた場所。
class MapSharePlace {
  const MapSharePlace({
    required this.id,
    required this.name,
    required this.visitedAt,
    this.countryCode,
  });

  final String id;
  final String name;
  final DateTime visitedAt;
  final String? countryCode;
}

/// 数字ではなく、どこまで広がって、次の白はどこかを表す。
class MapShareJourney {
  const MapShareJourney({
    required this.kind,
    required this.count,
    required this.total,
    required this.spreadCount,
    required this.stamps,
    this.focusKey,
    this.nextPlaceName,
    this.milestoneTarget,
  });

  final MapShareStoryKind kind;
  final int count;
  final int total;

  /// 到達した地方、または大陸の数。
  final int spreadCount;

  /// 地方キー（kanto など）または大陸キー（asia など）。
  final String? focusKey;

  /// まだ白い都道府県名。
  final String? nextPlaceName;
  final int? milestoneTarget;
  final List<MapSharePlace> stamps;

  int? get milestoneRemaining {
    final target = milestoneTarget;
    if (target == null) {
      return null;
    }
    final remaining = target - count;
    if (remaining <= 0) {
      return null;
    }
    return remaining;
  }
}

const japanRegionCap = 8;
const worldContinentCap = 6;

MapShareJourney buildJapanShareJourney(List<MapSharePlace> places) {
  final unique = _latestById(places);
  final count = unique.length.clamp(0, japanPrefectureCap);
  final stamps = unique.take(3).toList();
  if (count == 0) {
    return MapShareJourney(
      kind: MapShareStoryKind.empty,
      count: 0,
      total: japanPrefectureCap,
      spreadCount: 0,
      stamps: stamps,
    );
  }
  if (count >= japanPrefectureCap) {
    return MapShareJourney(
      kind: MapShareStoryKind.japanComplete,
      count: count,
      total: japanPrefectureCap,
      spreadCount: japanRegionCap,
      stamps: stamps,
    );
  }

  final visited = unique.map((place) => place.id).toSet();
  final regions = <String>{
    for (final place in unique)
      if (_regionOf(place.id) case final region?) region,
  };
  final latest = unique.first;
  final focus = _regionOf(latest.id);
  final next = _nextBlankPrefecture(latest.id, visited);
  final spread = regions.isEmpty ? 1 : regions.length;
  final kind = _japanKind(next: next, spread: spread);
  return MapShareJourney(
    kind: kind,
    count: count,
    total: japanPrefectureCap,
    spreadCount: spread,
    focusKey: focus,
    nextPlaceName: next?.name,
    milestoneTarget: nextJapanPrefectureMilestone(count),
    stamps: stamps,
  );
}

MapShareJourney buildWorldShareJourney(
  List<MapSharePlace> places, {
  String? Function(String countryCode)? continentOf,
}) {
  final unique = _latestById(places);
  final count = unique.length.clamp(0, worldCountryCap);
  final stamps = unique.take(3).toList();
  if (count == 0) {
    return MapShareJourney(
      kind: MapShareStoryKind.empty,
      count: 0,
      total: worldCountryCap,
      spreadCount: 0,
      stamps: stamps,
    );
  }
  if (count >= worldCountryCap) {
    return MapShareJourney(
      kind: MapShareStoryKind.worldComplete,
      count: count,
      total: worldCountryCap,
      spreadCount: worldContinentCap,
      stamps: stamps,
    );
  }

  final continents = <String>{};
  for (final place in unique) {
    final code = place.countryCode ?? place.id;
    final continent = continentOf?.call(code);
    if (continent != null) {
      continents.add(continent);
    }
  }
  final latestCode = unique.first.countryCode ?? unique.first.id;
  final focus = continentOf?.call(latestCode);
  final kind = _worldKind(continents.length);
  return MapShareJourney(
    kind: kind,
    count: count,
    total: worldCountryCap,
    spreadCount: continents.length,
    focusKey: focus,
    milestoneTarget: _nextWorldMilestone(count),
    stamps: stamps,
  );
}

/// 緯度経度から、シェア文言用の大陸キーを返す。
String continentKeyFromLatLng(
  double lat,
  double lng, {
  String? countryCode,
}) {
  const overrides = <String, String>{
    'RU': 'europe',
    'TR': 'asia',
    'KZ': 'asia',
    'GE': 'asia',
    'AM': 'asia',
    'AZ': 'asia',
    'CY': 'asia',
  };
  final override = countryCode == null ? null : overrides[countryCode];
  if (override != null) {
    return override;
  }
  if (lng >= 110 && lat <= -10) {
    return 'oceania';
  }
  if (lng >= -90 && lng < -30 && lat < 13) {
    return 'southAmerica';
  }
  if (lng >= -170 && lng < -30) {
    return 'northAmerica';
  }
  if (lng >= -25 && lng < 40 && lat >= 36) {
    return 'europe';
  }
  if (lng >= -25 && lng < 52 && lat < 36) {
    return 'africa';
  }
  return 'asia';
}

List<MapSharePlace> _latestById(List<MapSharePlace> places) {
  final byId = <String, MapSharePlace>{};
  for (final place in places) {
    final current = byId[place.id];
    if (current == null || place.visitedAt.isAfter(current.visitedAt)) {
      byId[place.id] = place;
    }
  }
  final unique = byId.values.toList()
    ..sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
  return unique;
}

MapShareStoryKind _japanKind({
  required _NextBlank? next,
  required int spread,
}) {
  if (next == null) {
    return MapShareStoryKind.japanComplete;
  }
  final single = spread <= 1;
  if (next.isNeighbor) {
    return single
        ? MapShareStoryKind.japanHereNeighbor
        : MapShareStoryKind.japanSpreadNeighbor;
  }
  return single
      ? MapShareStoryKind.japanHereBlank
      : MapShareStoryKind.japanSpreadBlank;
}

MapShareStoryKind _worldKind(int continents) {
  if (continents <= 0) {
    return MapShareStoryKind.worldProgress;
  }
  if (continents == 1) {
    return MapShareStoryKind.worldOneContinent;
  }
  if (continents >= worldContinentCap) {
    return MapShareStoryKind.worldAllContinents;
  }
  return MapShareStoryKind.worldSpread;
}

int? _nextWorldMilestone(int visited) {
  for (final milestone in worldCountryMilestones) {
    if (visited < milestone) {
      return milestone;
    }
  }
  return null;
}

class _NextBlank {
  const _NextBlank({required this.name, required this.isNeighbor});

  final String name;
  final bool isNeighbor;
}

_NextBlank? _nextBlankPrefecture(String latest, Set<String> visited) {
  for (final name in _neighbors[latest] ?? const <String>[]) {
    if (!visited.contains(name)) {
      return _NextBlank(name: name, isNeighbor: true);
    }
  }
  final region = _regionOf(latest);
  if (region != null) {
    for (final name in _prefecturesByRegion[region] ?? const <String>[]) {
      if (!visited.contains(name)) {
        return _NextBlank(name: name, isNeighbor: false);
      }
    }
    final start = _regionOrder.indexOf(region);
    if (start >= 0) {
      for (var step = 1; step < _regionOrder.length; step++) {
        final nextRegion = _regionOrder[(start + step) % _regionOrder.length];
        for (final name
            in _prefecturesByRegion[nextRegion] ?? const <String>[]) {
          if (!visited.contains(name)) {
            return _NextBlank(name: name, isNeighbor: false);
          }
        }
      }
    }
  }
  for (final names in _prefecturesByRegion.values) {
    for (final name in names) {
      if (!visited.contains(name)) {
        return _NextBlank(name: name, isNeighbor: false);
      }
    }
  }
  return null;
}

String? _regionOf(String prefecture) {
  for (final entry in _prefecturesByRegion.entries) {
    if (entry.value.contains(prefecture)) {
      return entry.key;
    }
  }
  return null;
}

const _regionOrder = [
  'hokkaido',
  'tohoku',
  'kanto',
  'chubu',
  'kinki',
  'chugoku',
  'shikoku',
  'kyushu',
];

const _prefecturesByRegion = <String, List<String>>{
  'hokkaido': ['北海道'],
  'tohoku': ['青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県'],
  'kanto': ['茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県'],
  'chubu': ['新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県', '岐阜県', '静岡県', '愛知県'],
  'kinki': ['三重県', '滋賀県', '京都府', '大阪府', '兵庫県', '奈良県', '和歌山県'],
  'chugoku': ['鳥取県', '島根県', '岡山県', '広島県', '山口県'],
  'shikoku': ['徳島県', '香川県', '愛媛県', '高知県'],
  'kyushu': ['福岡県', '佐賀県', '長崎県', '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県'],
};

const _neighbors = <String, List<String>>{
  '北海道': ['青森県'],
  '青森県': ['秋田県', '岩手県', '北海道'],
  '岩手県': ['青森県', '宮城県', '秋田県'],
  '宮城県': ['岩手県', '秋田県', '山形県', '福島県'],
  '秋田県': ['青森県', '岩手県', '宮城県', '山形県'],
  '山形県': ['秋田県', '宮城県', '福島県', '新潟県'],
  '福島県': ['宮城県', '山形県', '茨城県', '栃木県', '群馬県', '新潟県'],
  '茨城県': ['福島県', '栃木県', '埼玉県', '千葉県'],
  '栃木県': ['福島県', '茨城県', '群馬県', '埼玉県'],
  '群馬県': ['福島県', '栃木県', '埼玉県', '新潟県', '長野県'],
  '埼玉県': ['群馬県', '栃木県', '茨城県', '千葉県', '東京都', '山梨県', '長野県'],
  '千葉県': ['茨城県', '埼玉県', '東京都'],
  '東京都': ['埼玉県', '千葉県', '神奈川県', '山梨県'],
  '神奈川県': ['東京都', '山梨県', '静岡県'],
  '新潟県': ['山形県', '福島県', '群馬県', '長野県', '富山県'],
  '富山県': ['新潟県', '長野県', '岐阜県', '石川県'],
  '石川県': ['富山県', '岐阜県', '福井県'],
  '福井県': ['石川県', '岐阜県', '滋賀県', '京都府'],
  '山梨県': ['埼玉県', '東京都', '神奈川県', '静岡県', '長野県'],
  '長野県': ['新潟県', '群馬県', '埼玉県', '山梨県', '静岡県', '愛知県', '岐阜県', '富山県'],
  '岐阜県': ['富山県', '石川県', '福井県', '滋賀県', '三重県', '愛知県', '長野県'],
  '静岡県': ['神奈川県', '山梨県', '長野県', '愛知県'],
  '愛知県': ['長野県', '岐阜県', '静岡県', '三重県'],
  '三重県': ['愛知県', '岐阜県', '滋賀県', '京都府', '奈良県', '和歌山県'],
  '滋賀県': ['福井県', '岐阜県', '三重県', '京都府'],
  '京都府': ['福井県', '滋賀県', '三重県', '大阪府', '兵庫県', '奈良県'],
  '大阪府': ['京都府', '兵庫県', '奈良県', '和歌山県'],
  '兵庫県': ['京都府', '大阪府', '鳥取県', '岡山県'],
  '奈良県': ['三重県', '京都府', '大阪府', '和歌山県'],
  '和歌山県': ['三重県', '大阪府', '奈良県'],
  '鳥取県': ['兵庫県', '島根県', '岡山県', '広島県'],
  '島根県': ['鳥取県', '広島県', '山口県'],
  '岡山県': ['兵庫県', '鳥取県', '広島県'],
  '広島県': ['鳥取県', '島根県', '岡山県', '山口県'],
  '山口県': ['島根県', '広島県'],
  '徳島県': ['香川県', '愛媛県', '高知県'],
  '香川県': ['徳島県', '愛媛県'],
  '愛媛県': ['香川県', '徳島県', '高知県'],
  '高知県': ['徳島県', '愛媛県'],
  '福岡県': ['佐賀県', '熊本県', '大分県'],
  '佐賀県': ['福岡県', '長崎県'],
  '長崎県': ['佐賀県'],
  '熊本県': ['福岡県', '大分県', '宮崎県', '鹿児島県'],
  '大分県': ['福岡県', '熊本県', '宮崎県'],
  '宮崎県': ['大分県', '熊本県', '鹿児島県'],
  '鹿児島県': ['熊本県', '宮崎県'],
  '沖縄県': <String>[],
};
