import 'package:flutter/services.dart';
import 'package:food_gram_app/core/utils/location/country_polygon_index.dart';

/// 国情報
class Country {
  const Country({
    required this.name,
    required this.code,
  });

  final String name;
  final String code;
}

/// 投稿座標から国を判定する。国ポリゴン（ISO）を使う。
class CountryDetector {
  CountryDetector._();

  static const _geoJsonAssetPath = 'assets/map/world_countries.geojson';
  static CountryPolygonIndex? _index;
  static Future<void>? _loading;

  static bool get isLoaded => _index != null;

  /// アセットの国ポリゴンを読み込む。何度呼んでもよい。
  static Future<void> ensureLoaded() {
    if (_index != null) {
      return Future<void>.value();
    }
    return _loading ??= () async {
      try {
        final geoJson = await rootBundle.loadString(_geoJsonAssetPath);
        loadFromGeoJsonString(geoJson);
      } on Object {
        _loading = null;
        rethrow;
      }
    }();
  }

  /// テスト用。GeoJSON 文字列からインデックスを組み立てる。
  static void loadFromGeoJsonString(String geoJson) {
    _index = CountryPolygonIndex.parse(geoJson);
  }

  /// テスト用。読み込み済みインデックスを捨てる。
  static void resetForTest() {
    _index = null;
    _loading = null;
  }

  /// 緯度経度から国を判定
  static String? detectCountry(double lat, double lng) {
    return find(lat, lng)?.name ?? 'その他';
  }

  /// 国コードを取得
  static String? getCountryCode(double lat, double lng) {
    return find(lat, lng)?.code;
  }

  /// 緯度経度から国データを取得。範囲外または未ロードなら null
  static Country? find(double lat, double lng) {
    final index = _index;
    if (index == null) {
      return null;
    }
    final hit = index.find(lat, lng);
    if (hit == null) {
      return null;
    }
    return Country(
      code: hit.code,
      name: _japaneseCountryNames[hit.code] ?? hit.nameEn,
    );
  }
}

const _japaneseCountryNames = <String, String>{
  'JP': '日本',
  'KR': '韓国',
  'HK': '香港',
  'TW': '台湾',
  'MO': 'マカオ',
  'CN': '中国',
  'TH': 'タイ',
  'VN': 'ベトナム',
  'SG': 'シンガポール',
  'MY': 'マレーシア',
  'ID': 'インドネシア',
  'PH': 'フィリピン',
  'IN': 'インド',
  'KH': 'カンボジア',
  'LA': 'ラオス',
  'MM': 'ミャンマー',
  'LK': 'スリランカ',
  'BD': 'バングラデシュ',
  'PK': 'パキスタン',
  'NP': 'ネパール',
  'MN': 'モンゴル',
  'TR': 'トルコ',
  'AE': 'UAE',
  'IL': 'イスラエル',
  'SA': 'サウジアラビア',
  'EG': 'エジプト',
  'MA': 'モロッコ',
  'US': 'アメリカ',
  'CA': 'カナダ',
  'MX': 'メキシコ',
  'GB': 'イギリス',
  'FR': 'フランス',
  'DE': 'ドイツ',
  'IT': 'イタリア',
  'ES': 'スペイン',
  'CH': 'スイス',
  'NL': 'オランダ',
  'BE': 'ベルギー',
  'AT': 'オーストリア',
  'PL': 'ポーランド',
  'SE': 'スウェーデン',
  'NO': 'ノルウェー',
  'DK': 'デンマーク',
  'FI': 'フィンランド',
  'PT': 'ポルトガル',
  'GR': 'ギリシャ',
  'CZ': 'チェコ',
  'HU': 'ハンガリー',
  'RU': 'ロシア',
  'BR': 'ブラジル',
  'AR': 'アルゼンチン',
  'CL': 'チリ',
  'PE': 'ペルー',
  'CO': 'コロンビア',
  'AU': 'オーストラリア',
  'NZ': 'ニュージーランド',
  'ZA': '南アフリカ',
  'KE': 'ケニア',
  'TZ': 'タンザニア',
};
