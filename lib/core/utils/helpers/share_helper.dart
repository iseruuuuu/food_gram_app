import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ShareHelpers {
  void shareNormal(String url) {
    Share.share(url);
  }

  Future<void> sharePosts(
    List<XFile> files,
    String text,
  ) async {
    try {
      await Share.shareXFiles(
        files,
        text: text,
      ).timeout(const Duration(seconds: 5));
    } on TimeoutException {
      return;
    }
  }

  Future<void> shareOnlyPost(List<XFile> files) async {
    try {
      await Share.shareXFiles(files).timeout(const Duration(seconds: 5));
    } on TimeoutException {
      return;
    }
  }

  Future<void> captureAndShare({
    required Widget widget,
    required ValueNotifier<bool> loading,
    required bool hasText,
    String? shareText,
  }) async {
    try {
      loading.value = true;
      final screenshotController = ScreenshotController();
      final screenshotBytes =
          await screenshotController.captureFromWidget(widget);

      // 一時ディレクトリに保存
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/shared_image.png';
      final file = File(filePath);
      await file.writeAsBytes(screenshotBytes);
      // シェア処理を実行（タイムアウト付き）
      if (hasText) {
        await sharePosts([XFile(file.path)], shareText!);
      } else {
        await shareOnlyPost([XFile(file.path)]);
      }
    } on Exception {
      return;
    } finally {
      loading.value = false;
    }
  }
}
