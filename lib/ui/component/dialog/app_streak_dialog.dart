import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/i18n/strings.g.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

/// ストリークバッジ取得・更新ダイアログを表示
Future<void> showStreakDialog({
  required BuildContext context,
  required int streakWeeks,
  required bool isFirstTime,
}) async {
  final t = Translations.of(context);

  final String title;
  final String content;

  title = t.streakDialogFirstTitle;

  if (isFirstTime || streakWeeks == 1) {
    // 初回またはリセット後の1週目
    content = t.streakDialogFirstContent;
  } else {
    // 2週目以降
    content = t.streakDialogContinueContent
        .replaceAll('{weeks}', streakWeeks.toString());
  }

  await showDialog<void>(
    context: context,
    builder: (context) {
      final deviceWidth = MediaQuery.of(context).size.width;
      return SizedBox(
        width: deviceWidth * 0.85,
        child: GiffyDialog.image(
          Assets.gif.postSuccess.image(
            height: 250,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 250,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.celebration,
                  size: 100,
                  color: Colors.orange,
                ),
              );
            },
          ),
          title: Text(
            '✨$title✨',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
                child: Text(
                  t.close,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
          backgroundColor: Colors.white,
        ),
      );
    },
  );
}
