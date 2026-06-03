import 'dart:io';

import 'package:exif/exif.dart';

/// 画像ファイルの EXIF から GPS 座標を読み取る（取得できない場合は null）
Future<({double latitude, double longitude})?> readGpsFromImagePath(
  String path,
) async {
  try {
    final file = File(path);
    if (!file.existsSync()) {
      return null;
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      return null;
    }
    final tags = await readExifFromBytes(bytes);
    if (tags.isEmpty) {
      return null;
    }

    final lat = _gpsTagToDecimal(
      tags['GPS GPSLatitude'],
      tags['GPS GPSLatitudeRef']?.printable,
    );
    final lng = _gpsTagToDecimal(
      tags['GPS GPSLongitude'],
      tags['GPS GPSLongitudeRef']?.printable,
    );
    if (lat == null || lng == null) {
      return null;
    }
    if (!_isValidCoordinate(lat, lng)) {
      return null;
    }
    return (latitude: lat, longitude: lng);
  } on Object {
    return null;
  }
}

bool _isValidCoordinate(double lat, double lng) {
  if (lat.isNaN || lng.isNaN || lat.isInfinite || lng.isInfinite) {
    return false;
  }
  if (lat.abs() > 90 || lng.abs() > 180) {
    return false;
  }
  if (lat == 0 && lng == 0) {
    return false;
  }
  return true;
}

double? _gpsTagToDecimal(dynamic tag, String? ref) {
  if (tag is! IfdTag) {
    return null;
  }
  final values = tag.values.toList();
  if (values.isNotEmpty) {
    if (values.length >= 3) {
      final degrees = _ratioValueToDouble(values[0]);
      final minutes = _ratioValueToDouble(values[1]);
      final seconds = _ratioValueToDouble(values[2]);
      if (degrees == null || minutes == null || seconds == null) {
        return null;
      }
      var decimal = degrees + minutes / 60 + seconds / 3600;
      if (ref == 'S' || ref == 'W') {
        decimal = -decimal;
      }
      return decimal;
    }
    final single = _ratioValueToDouble(values.first);
    if (single == null) {
      return null;
    }
    if (ref == 'S' || ref == 'W') {
      return -single;
    }
    return single;
  }
  final parsed = double.tryParse(tag.printable);
  if (parsed == null) {
    return null;
  }
  if (ref == 'S' || ref == 'W') {
    return -parsed;
  }
  return parsed;
}

double? _ratioValueToDouble(dynamic value) {
  if (value is Ratio) {
    if (value.denominator == 0) {
      return null;
    }
    return value.numerator / value.denominator;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is double) {
    return value;
  }
  return double.tryParse(value.toString());
}
