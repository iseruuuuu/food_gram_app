import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class SnackBarHelper {
  void openErrorSnackBar(
    BuildContext? context,
    String title,
    String message,
  ) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text(title),
      description: message.isNotEmpty ? Text(message) : null,
      autoCloseDuration: const Duration(seconds: 5),
      alignment: Alignment.topRight,
    );
  }

  void openSuccessSnackBar(
    BuildContext? context,
    String title,
    String message,
  ) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      title: Text(title),
      description: message.isNotEmpty ? Text(message) : null,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topRight,
    );
  }

  void openComingSoonSnackBar(BuildContext? context) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.fillColored,
      title: const Text(
        '🙇　Coming Soon　🙇',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topRight,
    );
  }

  void openThanksSnackBar(BuildContext? context) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      title: const Text(
        'Thanks＼(^o^)／',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topRight,
    );
  }

  void hideSnackBar(BuildContext? context) {
    toastification.dismissAll();
  }

  /// シンプルなテキストメッセージを表示
  void openSimpleSnackBar(
    BuildContext? context,
    String message, {
    Color? backgroundColor,
    Duration? duration,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.fillColored,
      title: Text(message),
      autoCloseDuration: duration ?? const Duration(seconds: 3),
      alignment: Alignment.topRight,
    );
  }

  /// 情報メッセージを表示（複数行対応）
  void openInfoSnackBar(
    BuildContext? context,
    Widget content, {
    Color? backgroundColor,
    Duration? duration,
  }) {
    // Columnの場合はtitleとdescriptionに分ける
    if (content is Column && content.children.length >= 2) {
      final titleWidget = content.children[0];
      final descriptionWidget = content.children[1];
      String? titleText;
      String? descriptionText;

      if (titleWidget is Text) {
        titleText = titleWidget.data;
      }
      if (descriptionWidget is Text) {
        descriptionText = descriptionWidget.data;
      }

      if (titleText != null) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          title: Text(titleText),
          description: descriptionText != null ? Text(descriptionText) : null,
          autoCloseDuration: duration ?? const Duration(seconds: 3),
          alignment: Alignment.topRight,
        );
        return;
      }
    }

    // その他の場合はカスタム表示
    toastification.showCustom(
      context: context,
      autoCloseDuration: duration ?? const Duration(seconds: 3),
      alignment: Alignment.topRight,
      builder: (context, holder) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.blue,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: content,
        );
      },
    );
  }

  /// 警告メッセージを表示（赤背景など）
  void openWarningSnackBar(
    BuildContext? context,
    String message, {
    Color? backgroundColor,
    Duration? duration,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.fillColored,
      title: Text(message),
      autoCloseDuration: duration ?? const Duration(seconds: 3),
      alignment: Alignment.topRight,
    );
  }
}
