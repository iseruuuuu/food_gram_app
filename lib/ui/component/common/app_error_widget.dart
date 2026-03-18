import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/app_elevated_button.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    required this.onTap,
    super.key,
  });

  final VoidCallback onTap;

  /// 多言語化時などで [Translations.of] が失敗した場合のフォールバック。
  static const _fallbackTitle = 'Communication Error';
  static const _fallbackDescription1 = 'A connection error has occurred.';
  static const _fallbackDescription2 =
      'Check your network connection and try again.';
  static const _fallbackRefreshButton = 'Reload';

  @override
  Widget build(BuildContext context) {
    String title;
    String description1;
    String description2;
    String refreshButton;
    try {
      final t = Translations.of(context);
      title = t.error.title;
      description1 = t.error.description1;
      description2 = t.error.description2;
      refreshButton = t.error.refreshButton;
    } on Object catch (_) {
      title = _fallbackTitle;
      description1 = _fallbackDescription1;
      description2 = _fallbackDescription2;
      refreshButton = _fallbackRefreshButton;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$description1\n$description2',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Assets.image.error.image(
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 50),
            AppElevatedButton(
              onPressed: onTap,
              title: refreshButton,
            ),
          ],
        ),
      ),
    );
  }
}

/// マップ周りで使うエラー表示用ウィジェット。
/// 「読み込み失敗」メッセージ＋リトライボタンだけのシンプルな UI。
class MapErrorWidget extends StatelessWidget {
  const MapErrorWidget({
    required this.onRetry,
    super.key,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          t.notification.loadFailed,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(t.error.refreshButton),
        ),
      ],
    );
  }
}
