import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// Android 9（API 28）以下では、MapLibre の GeoJSON ソースが
/// ネイティブの SIGSEGV でプロセスを落とす。
/// その端末では実行時 GeoJSON を渡さず、Annotation のピンだけ使う。
class MapGeoJsonSupport {
  MapGeoJsonSupport._();

  static const int minSafeAndroidSdk = 29;

  static bool _loaded = false;
  static bool _androidAllows = false;

  static Future<void> load() async {
    if (!Platform.isAndroid) {
      _loaded = true;
      _androidAllows = true;
      return;
    }
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      _androidAllows = info.version.sdkInt >= minSafeAndroidSdk;
    } on Object {
      _androidAllows = false;
    }
    _loaded = true;
  }

  static bool get allowsRuntimeGeoJson {
    if (!Platform.isAndroid) {
      return true;
    }
    return _loaded && _androidAllows;
  }
}
