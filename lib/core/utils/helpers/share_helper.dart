import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/ui/component/app_share_widget.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_share_modal_sheet.dart';
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
    await Share.shareXFiles(
      files,
      text: text,
    );
  }

  Future<void> shareOnlyPost(List<XFile> files) async {
    await Share.shareXFiles(files);
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
      if (hasText) {
        await sharePosts([XFile(file.path)], shareText!);
      } else {
        await shareOnlyPost([XFile(file.path)]);
      }
    } finally {
      loading.value = false;
    }
  }
}
