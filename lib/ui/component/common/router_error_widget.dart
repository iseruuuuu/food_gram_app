import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/strings.g.dart';

/// Router（GoRouter）で `extra` が不正/不足だった場合などに表示するエラーUI。
class RouterErrorWidget extends StatelessWidget {
  const RouterErrorWidget({
    this.onBack,
    super.key,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.error.routerErrorTitle,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              t.error.routerErrorMessage,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (onBack != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                label: Text(t.error.routerErrorBack),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
