import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';

/// ストリークバッジ取得・更新ダイアログを表示
Future<void> showStreakDialog({
  required BuildContext context,
  required int streakWeeks,
  required bool isFirstTime,
}) async {
  final t = Translations.of(context);

  final String title;
  final String content;

  title = t.streakDialog.firstTitle;

  if (isFirstTime || streakWeeks == 1) {
    // 初回またはリセット後の1週目
    content = t.streakDialog.firstContent;
  } else {
    // 2週目以降
    content = t.streakDialog.continueContent
        .replaceAll('{weeks}', streakWeeks.toString());
  }

  await showDialog<void>(
    context: context,
    builder: (context) {
      final deviceWidth = MediaQuery.of(context).size.width;
      final colorScheme = Theme.of(context).colorScheme;
      return Dialog(
        backgroundColor: colorScheme.surface,
        child: SizedBox(
          width: deviceWidth * 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.gif.postSuccess.image(
                height: 250,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: colorScheme.surfaceContainerHighest,
                    child: const Icon(
                      Icons.celebration,
                      size: 100,
                      color: Colors.orange,
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Text(
                  '✨$title✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Text(
                  content,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                  ),
                  child: Text(
                    t.close,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
