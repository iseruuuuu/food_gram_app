import 'dart:math';

/// 都道府県情報
class Prefecture {
  const Prefecture({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final double latitude;
  final double longitude;
}

// 日本の47都道府県の中心座標データ
class PrefectureDetector {
  PrefectureDetector._();
  static const List<Prefecture> prefectures = [
    Prefecture(name: '北海道', latitude: 43.064, longitude: 141.347),
    Prefecture(name: '青森県', latitude: 40.824, longitude: 140.740),
    Prefecture(name: '岩手県', latitude: 39.703, longitude: 141.153),
    Prefecture(name: '宮城県', latitude: 38.268, longitude: 140.872),
    Prefecture(name: '秋田県', latitude: 39.719, longitude: 140.102),
    Prefecture(name: '山形県', latitude: 38.240, longitude: 140.363),
    Prefecture(name: '福島県', latitude: 37.750, longitude: 140.467),
    Prefecture(name: '茨城県', latitude: 36.341, longitude: 140.447),
    Prefecture(name: '栃木県', latitude: 36.566, longitude: 139.883),
    Prefecture(name: '群馬県', latitude: 36.391, longitude: 139.060),
    Prefecture(name: '埼玉県', latitude: 35.857, longitude: 139.649),
    Prefecture(name: '千葉県', latitude: 35.605, longitude: 140.123),
    Prefecture(name: '東京都', latitude: 35.689, longitude: 139.692),
    Prefecture(name: '神奈川県', latitude: 35.448, longitude: 139.642),
    Prefecture(name: '新潟県', latitude: 37.902, longitude: 139.023),
    Prefecture(name: '富山県', latitude: 36.695, longitude: 137.211),
    Prefecture(name: '石川県', latitude: 36.594, longitude: 136.626),
    Prefecture(name: '福井県', latitude: 36.065, longitude: 136.222),
    Prefecture(name: '山梨県', latitude: 35.664, longitude: 138.568),
    Prefecture(name: '長野県', latitude: 36.651, longitude: 138.181),
    Prefecture(name: '岐阜県', latitude: 35.391, longitude: 136.722),
    Prefecture(name: '静岡県', latitude: 34.977, longitude: 138.383),
    Prefecture(name: '愛知県', latitude: 35.180, longitude: 136.907),
    Prefecture(name: '三重県', latitude: 34.730, longitude: 136.509),
    Prefecture(name: '滋賀県', latitude: 35.004, longitude: 135.869),
    Prefecture(name: '京都府', latitude: 35.021, longitude: 135.756),
    Prefecture(name: '大阪府', latitude: 34.686, longitude: 135.520),
    Prefecture(name: '兵庫県', latitude: 34.691, longitude: 135.183),
    Prefecture(name: '奈良県', latitude: 34.685, longitude: 135.833),
    Prefecture(name: '和歌山県', latitude: 34.226, longitude: 135.167),
    Prefecture(name: '鳥取県', latitude: 35.504, longitude: 134.238),
    Prefecture(name: '島根県', latitude: 35.472, longitude: 133.051),
    Prefecture(name: '岡山県', latitude: 34.662, longitude: 133.935),
    Prefecture(name: '広島県', latitude: 34.396, longitude: 132.460),
    Prefecture(name: '山口県', latitude: 34.186, longitude: 131.471),
    Prefecture(name: '徳島県', latitude: 34.066, longitude: 134.559),
    Prefecture(name: '香川県', latitude: 34.340, longitude: 134.043),
    Prefecture(name: '愛媛県', latitude: 33.841, longitude: 132.766),
    Prefecture(name: '高知県', latitude: 33.560, longitude: 133.531),
    Prefecture(name: '福岡県', latitude: 33.606, longitude: 130.418),
    Prefecture(name: '佐賀県', latitude: 33.249, longitude: 130.299),
    Prefecture(name: '長崎県', latitude: 32.745, longitude: 129.874),
    Prefecture(name: '熊本県', latitude: 32.790, longitude: 130.742),
    Prefecture(name: '大分県', latitude: 33.238, longitude: 131.613),
    Prefecture(name: '宮崎県', latitude: 31.911, longitude: 131.424),
    Prefecture(name: '鹿児島県', latitude: 31.560, longitude: 130.558),
    Prefecture(name: '沖縄県', latitude: 26.212, longitude: 127.681),
  ];

  /// 緯度経度から最も近い都道府県を判定
  static String? detectPrefecture(double lat, double lng) {
    // 日本の範囲外の場合はnull
    if (lat < 24.0 || lat > 46.0 || lng < 122.0 || lng > 154.0) {
      return null;
    }

    var minDistance = double.infinity;
    String? nearestPrefecture;

    for (final prefecture in prefectures) {
      final distance = _calculateDistance(
        lat,
        lng,
        prefecture.latitude,
        prefecture.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestPrefecture = prefecture.name;
      }
    }

    // 最も近い都道府県が50km以内であれば、その都道府県と判定
    if (minDistance < 50) {
      return nearestPrefecture;
    }

    return null;
  }

  /// 2点間の距離を計算（簡易版：km単位）
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371; // 地球の半径（km）
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * asin(sqrt(a));
    return r * c;
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}
