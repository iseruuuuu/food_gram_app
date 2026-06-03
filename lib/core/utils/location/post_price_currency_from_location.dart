import 'package:food_gram_app/core/utils/format/post_price_formatter.dart';
import 'package:food_gram_app/core/utils/location/image_gps_reader.dart';
import 'package:geocoding/geocoding.dart';

/// 画像パスの EXIF GPS → 逆ジオコーディング → 通貨（失敗時 null）
Future<String?> postPriceCurrencyFromImagePath(String imagePath) async {
  final gps = await readGpsFromImagePath(imagePath);
  if (gps == null) {
    return null;
  }
  return postPriceCurrencyFromCoordinates(
    latitude: gps.latitude,
    longitude: gps.longitude,
  );
}

/// 緯度経度 → 逆ジオコーディング → 通貨（失敗時 null）
Future<String?> postPriceCurrencyFromCoordinates({
  required double latitude,
  required double longitude,
}) async {
  final countryCode = await _countryCodeFromCoordinates(
    latitude: latitude,
    longitude: longitude,
  );
  if (countryCode == null || countryCode.isEmpty) {
    return null;
  }
  return defaultPostPriceCurrencyForCountry(countryCode);
}

Future<String?> _countryCodeFromCoordinates({
  required double latitude,
  required double longitude,
}) async {
  try {
    final placemarks = await placemarkFromCoordinates(
      latitude,
      longitude,
    );
    if (placemarks.isEmpty) {
      return null;
    }
    final code = placemarks.first.isoCountryCode?.trim().toUpperCase();
    if (code == null || code.isEmpty) {
      return null;
    }
    return code;
  } on Object {
    return null;
  }
}
