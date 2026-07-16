import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ShareHelpers {
  void shareNormal(String url) {
    Share.share(url);
  }

  Rect _sharePositionOrigin(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 1,
      height: 1,
    );
  }

  Future<void> sharePosts(
    List<XFile> files,
    String text, {
    required BuildContext context,
  }) async {
    await Share.shareXFiles(
      files,
      text: text,
      sharePositionOrigin: _sharePositionOrigin(context),
    );
  }

  Future<void> shareOnlyPost(
    List<XFile> files, {
    required BuildContext context,
  }) async {
    await Share.shareXFiles(
      files,
      sharePositionOrigin: _sharePositionOrigin(context),
    );
  }

  /// 画面上の [RepaintBoundary] をそのままキャプチャしてシェアする
  Future<bool> captureBoundaryAndShare({
    required BuildContext context,
    required GlobalKey boundaryKey,
    required ValueNotifier<bool> loading,
    required bool hasText,
    required String errorMessage,
    String? shareText,
    String? precacheImageUrl,
    double pixelRatio = 3,
  }) async {
    ui.Image? image;
    try {
      loading.value = true;
      if (precacheImageUrl != null && context.mounted) {
        try {
          await precacheImage(
            CachedNetworkImageProvider(precacheImageUrl),
            context,
          );
        } on Object {
          // プリロード失敗時もキャプチャは続行する
        }
      }
      // レイアウト確定後にキャプチャする
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (!context.mounted) {
        return false;
      }
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('Share boundary is not ready');
      }
      image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null || byteData.lengthInBytes == 0) {
        throw StateError('Screenshot capture returned empty bytes');
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/shared_image.png';
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      if (!context.mounted) {
        return false;
      }
      if (hasText) {
        await sharePosts(
          [XFile(file.path)],
          shareText!,
          context: context,
        );
      } else {
        await shareOnlyPost([XFile(file.path)], context: context);
      }
      return true;
    } on Exception {
      if (context.mounted) {
        SnackBarHelper().openErrorSnackBar(context, errorMessage, '');
      }
      return false;
    } finally {
      image?.dispose();
      loading.value = false;
    }
  }

  Future<bool> captureAndShare({
    required BuildContext context,
    required Widget widget,
    required ValueNotifier<bool> loading,
    required bool hasText,
    required String errorMessage,
    String? shareText,
    Size? targetSize,
    double? pixelRatio,
    String? precacheImageUrl,
  }) async {
    try {
      loading.value = true;
      if (precacheImageUrl != null && context.mounted) {
        try {
          await precacheImage(
            CachedNetworkImageProvider(precacheImageUrl),
            context,
          );
        } on Object {
          // プリロード失敗時もキャプチャは続行する
        }
      }
      final screenshotController = ScreenshotController();
      final screenshotBytes = await screenshotController.captureFromWidget(
        widget,
        context: context,
        targetSize: targetSize,
        pixelRatio: pixelRatio,
        delay: const Duration(milliseconds: 500),
      );

      if (screenshotBytes.isEmpty) {
        throw StateError('Screenshot capture returned empty bytes');
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/shared_image.png';
      final file = File(filePath);
      await file.writeAsBytes(screenshotBytes);

      if (hasText) {
        await sharePosts(
          [XFile(file.path)],
          shareText!,
          context: context,
        );
      } else {
        await shareOnlyPost([XFile(file.path)], context: context);
      }
      return true;
    } on Exception {
      if (context.mounted) {
        SnackBarHelper().openErrorSnackBar(context, errorMessage, '');
      }
      return false;
    } finally {
      loading.value = false;
    }
  }
}
