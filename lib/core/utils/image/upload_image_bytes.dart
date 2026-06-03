import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// 従来の [ImagePicker] 設定（maxWidth/maxHeight: 960, imageQuality: 100）に合わせる
const double kUploadImageMaxDimension = 960;
const int kUploadImageJpegQuality = 100;

/// 編集後の画像をアップロード用 JPEG に変換（長辺最大 [kUploadImageMaxDimension]）
Future<Uint8List> prepareUploadImageBytes(Uint8List bytes) {
  return compute(_encodeUploadJpeg, bytes);
}

Uint8List _encodeUploadJpeg(Uint8List bytes) {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return bytes;
    }
    // リサイズしない場合もピクセルに向きを焼き込む（ImagePicker 相当の表示向き）
    final oriented = img.bakeOrientation(decoded);
    final resized = _resizeToMaxDimension(
      oriented,
      maxDimension: kUploadImageMaxDimension.round(),
    );
    return Uint8List.fromList(
      img.encodeJpg(resized, quality: kUploadImageJpegQuality),
    );
  } on Object {
    return bytes;
  }
}

img.Image _resizeToMaxDimension(
  img.Image image, {
  required int maxDimension,
}) {
  final w = image.width;
  final h = image.height;
  if (w <= maxDimension && h <= maxDimension) {
    return image;
  }
  if (w >= h) {
    return img.copyResize(image, width: maxDimension);
  }
  return img.copyResize(image, height: maxDimension);
}
