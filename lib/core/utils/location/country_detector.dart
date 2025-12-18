/// 国情報
class Country {
  const Country({
    required this.name,
    required this.code,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });

  final String name;
  final String code;
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  bool contains(double lat, double lng) {
    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }
}

// 主要国の緯度経度範囲データ
class CountryDetector {
  CountryDetector._();

  static const List<Country> countries = [
    Country(
      name: '日本',
      code: 'JP',
      minLat: 24,
      maxLat: 46,
      minLng: 122,
      maxLng: 154,
    ),
    Country(
      name: '韓国',
      code: 'KR',
      minLat: 33,
      maxLat: 38.6,
      minLng: 124.5,
      maxLng: 131,
    ),
    // 香港と台湾は中国より前に配置（中国の範囲が広いため）
    Country(
      name: '香港',
      code: 'HK',
      minLat: 22.1,
      maxLat: 22.6,
      minLng: 113.8,
      maxLng: 114.5,
    ),
    Country(
      name: '台湾',
      code: 'TW',
      minLat: 21.9,
      maxLat: 25.3,
      minLng: 120,
      maxLng: 122,
    ),
    Country(
      name: 'マカオ',
      code: 'MO',
      minLat: 22.1,
      maxLat: 22.2,
      minLng: 113.5,
      maxLng: 113.6,
    ),
    Country(
      name: '中国',
      code: 'CN',
      minLat: 18,
      maxLat: 54,
      minLng: 73,
      maxLng: 135,
    ),
    Country(
      name: 'タイ',
      code: 'TH',
      minLat: 5.6,
      maxLat: 20.5,
      minLng: 97.3,
      maxLng: 105.6,
    ),
    Country(
      name: 'ベトナム',
      code: 'VN',
      minLat: 8.5,
      maxLat: 23.4,
      minLng: 102.1,
      maxLng: 109.5,
    ),
    Country(
      name: 'シンガポール',
      code: 'SG',
      minLat: 1.15,
      maxLat: 1.47,
      minLng: 103.6,
      maxLng: 104,
    ),
    Country(
      name: 'マレーシア',
      code: 'MY',
      minLat: 0.8,
      maxLat: 7.4,
      minLng: 99.6,
      maxLng: 119.3,
    ),
    Country(
      name: 'インドネシア',
      code: 'ID',
      minLat: -11,
      maxLat: 6,
      minLng: 95,
      maxLng: 141,
    ),
    Country(
      name: 'フィリピン',
      code: 'PH',
      minLat: 4.6,
      maxLat: 21.1,
      minLng: 116.9,
      maxLng: 126.6,
    ),
    Country(
      name: 'インド',
      code: 'IN',
      minLat: 6.7,
      maxLat: 35.5,
      minLng: 68.1,
      maxLng: 97.4,
    ),
    Country(
      name: 'カンボジア',
      code: 'KH',
      minLat: 10.4,
      maxLat: 14.7,
      minLng: 102.3,
      maxLng: 107.6,
    ),
    Country(
      name: 'ラオス',
      code: 'LA',
      minLat: 13.9,
      maxLat: 22.5,
      minLng: 100,
      maxLng: 107.6,
    ),
    Country(
      name: 'ミャンマー',
      code: 'MM',
      minLat: 9.8,
      maxLat: 28.5,
      minLng: 92.1,
      maxLng: 101.2,
    ),
    Country(
      name: 'スリランカ',
      code: 'LK',
      minLat: 5.9,
      maxLat: 9.8,
      minLng: 79.7,
      maxLng: 81.9,
    ),
    Country(
      name: 'バングラデシュ',
      code: 'BD',
      minLat: 20.7,
      maxLat: 26.6,
      minLng: 88,
      maxLng: 92.7,
    ),
    Country(
      name: 'パキスタン',
      code: 'PK',
      minLat: 23.6,
      maxLat: 37.1,
      minLng: 60.9,
      maxLng: 77.8,
    ),
    Country(
      name: 'ネパール',
      code: 'NP',
      minLat: 26.3,
      maxLat: 30.4,
      minLng: 80,
      maxLng: 88.2,
    ),
    Country(
      name: 'モンゴル',
      code: 'MN',
      minLat: 41.6,
      maxLat: 52.1,
      minLng: 87.7,
      maxLng: 119.9,
    ),

    // 中東
    Country(
      name: 'トルコ',
      code: 'TR',
      minLat: 35.8,
      maxLat: 42.1,
      minLng: 25.7,
      maxLng: 45,
    ),
    Country(
      name: 'UAE',
      code: 'AE',
      minLat: 22.6,
      maxLat: 26.1,
      minLng: 51,
      maxLng: 56.4,
    ),
    Country(
      name: 'イスラエル',
      code: 'IL',
      minLat: 29.5,
      maxLat: 33.3,
      minLng: 34.2,
      maxLng: 35.8,
    ),
    Country(
      name: 'サウジアラビア',
      code: 'SA',
      minLat: 16,
      maxLat: 32.2,
      minLng: 34.5,
      maxLng: 55.7,
    ),
    Country(
      name: 'エジプト',
      code: 'EG',
      minLat: 22,
      maxLat: 31.7,
      minLng: 24.6,
      maxLng: 37,
    ),
    Country(
      name: 'モロッコ',
      code: 'MA',
      minLat: 21.4,
      maxLat: 35.9,
      minLng: -17,
      maxLng: -1.1,
    ),

    // 北米
    Country(
      name: 'アメリカ',
      code: 'US',
      minLat: 24.5,
      maxLat: 49.4,
      minLng: -125,
      maxLng: -66.9,
    ),
    Country(
      name: 'カナダ',
      code: 'CA',
      minLat: 41.7,
      maxLat: 83.1,
      minLng: -141,
      maxLng: -52.6,
    ),
    Country(
      name: 'メキシコ',
      code: 'MX',
      minLat: 14.5,
      maxLat: 32.7,
      minLng: -118.4,
      maxLng: -86.7,
    ),

    // ヨーロッパ
    Country(
      name: 'イギリス',
      code: 'GB',
      minLat: 49.9,
      maxLat: 60.8,
      minLng: -8.6,
      maxLng: 1.8,
    ),
    Country(
      name: 'フランス',
      code: 'FR',
      minLat: 41.3,
      maxLat: 51.1,
      minLng: -5.1,
      maxLng: 9.6,
    ),
    Country(
      name: 'ドイツ',
      code: 'DE',
      minLat: 47.3,
      maxLat: 55.1,
      minLng: 5.9,
      maxLng: 15,
    ),
    Country(
      name: 'イタリア',
      code: 'IT',
      minLat: 36.6,
      maxLat: 47.1,
      minLng: 6.6,
      maxLng: 18.5,
    ),
    Country(
      name: 'スペイン',
      code: 'ES',
      minLat: 36,
      maxLat: 43.8,
      minLng: -9.3,
      maxLng: 4.3,
    ),
    Country(
      name: 'スイス',
      code: 'CH',
      minLat: 45.8,
      maxLat: 47.8,
      minLng: 5.9,
      maxLng: 10.5,
    ),
    Country(
      name: 'オランダ',
      code: 'NL',
      minLat: 50.7,
      maxLat: 53.7,
      minLng: 3.3,
      maxLng: 7.2,
    ),
    Country(
      name: 'ベルギー',
      code: 'BE',
      minLat: 49.5,
      maxLat: 51.5,
      minLng: 2.5,
      maxLng: 6.4,
    ),
    Country(
      name: 'オーストリア',
      code: 'AT',
      minLat: 46.4,
      maxLat: 49,
      minLng: 9.5,
      maxLng: 17.2,
    ),
    Country(
      name: 'ポーランド',
      code: 'PL',
      minLat: 49,
      maxLat: 54.8,
      minLng: 14.1,
      maxLng: 24.1,
    ),
    Country(
      name: 'スウェーデン',
      code: 'SE',
      minLat: 55.3,
      maxLat: 69.1,
      minLng: 11,
      maxLng: 24.2,
    ),
    Country(
      name: 'ノルウェー',
      code: 'NO',
      minLat: 57.9,
      maxLat: 71.2,
      minLng: 4.6,
      maxLng: 31.3,
    ),
    Country(
      name: 'デンマーク',
      code: 'DK',
      minLat: 54.5,
      maxLat: 57.8,
      minLng: 8,
      maxLng: 15.2,
    ),
    Country(
      name: 'フィンランド',
      code: 'FI',
      minLat: 59.8,
      maxLat: 70.1,
      minLng: 20.6,
      maxLng: 31.6,
    ),
    Country(
      name: 'ポルトガル',
      code: 'PT',
      minLat: 36.8,
      maxLat: 42.2,
      minLng: -9.5,
      maxLng: -6.2,
    ),
    Country(
      name: 'ギリシャ',
      code: 'GR',
      minLat: 34.8,
      maxLat: 41.7,
      minLng: 19.4,
      maxLng: 29.6,
    ),
    Country(
      name: 'チェコ',
      code: 'CZ',
      minLat: 48.5,
      maxLat: 51.1,
      minLng: 12.1,
      maxLng: 18.9,
    ),
    Country(
      name: 'ハンガリー',
      code: 'HU',
      minLat: 45.7,
      maxLat: 48.6,
      minLng: 16.1,
      maxLng: 22.9,
    ),
    Country(
      name: 'ロシア',
      code: 'RU',
      minLat: 41.2,
      maxLat: 81.9,
      minLng: 19.6,
      maxLng: 180,
    ),

    // 南米
    Country(
      name: 'ブラジル',
      code: 'BR',
      minLat: -33.7,
      maxLat: 5.3,
      minLng: -73.9,
      maxLng: -32.4,
    ),
    Country(
      name: 'アルゼンチン',
      code: 'AR',
      minLat: -55.1,
      maxLat: -21.8,
      minLng: -73.6,
      maxLng: -53.6,
    ),
    Country(
      name: 'チリ',
      code: 'CL',
      minLat: -55.9,
      maxLat: -17.5,
      minLng: -75.6,
      maxLng: -66.4,
    ),
    Country(
      name: 'ペルー',
      code: 'PE',
      minLat: -18.3,
      maxLat: 0,
      minLng: -81.3,
      maxLng: -68.7,
    ),
    Country(
      name: 'コロンビア',
      code: 'CO',
      minLat: -4.2,
      maxLat: 12.5,
      minLng: -79,
      maxLng: -66.9,
    ),

    // オセアニア
    Country(
      name: 'オーストラリア',
      code: 'AU',
      minLat: -43.6,
      maxLat: -10,
      minLng: 113.3,
      maxLng: 153.6,
    ),
    Country(
      name: 'ニュージーランド',
      code: 'NZ',
      minLat: -47.3,
      maxLat: -34.4,
      minLng: 166.4,
      maxLng: 178.6,
    ),

    // アフリカ
    Country(
      name: '南アフリカ',
      code: 'ZA',
      minLat: -34.8,
      maxLat: -22.1,
      minLng: 16.3,
      maxLng: 32.8,
    ),
    Country(
      name: 'ケニア',
      code: 'KE',
      minLat: -4.7,
      maxLat: 5.5,
      minLng: 33.9,
      maxLng: 41.9,
    ),
    Country(
      name: 'タンザニア',
      code: 'TZ',
      minLat: -11.8,
      maxLat: -0.9,
      minLng: 29.3,
      maxLng: 40.3,
    ),
  ];

  /// 緯度経度から国を判定
  static String? detectCountry(double lat, double lng) {
    for (final country in countries) {
      if (country.contains(lat, lng)) {
        return country.name;
      }
    }
    return 'その他';
  }

  /// 国コードを取得
  static String? getCountryCode(double lat, double lng) {
    for (final country in countries) {
      if (country.contains(lat, lng)) {
        return country.code;
      }
    }
    return null;
  }
}
