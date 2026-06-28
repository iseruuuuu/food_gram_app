import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/common/app_tab_loading.dart';
import 'package:gap/gap.dart';

class AppTabError extends StatelessWidget {
  const AppTabError({
    required this.type,
    required this.onRetry,
    super.key,
    this.compact = false,
  });

  const AppTabError.map({
    required this.onRetry,
    super.key,
    this.compact = false,
  }) : type = TabLoadingType.map;

  const AppTabError.food({
    required this.onRetry,
    super.key,
    this.compact = false,
  }) : type = TabLoadingType.food;

  const AppTabError.record({
    required this.onRetry,
    super.key,
    this.compact = false,
  }) : type = TabLoadingType.record;

  const AppTabError.myPage({
    required this.onRetry,
    super.key,
    this.compact = false,
  }) : type = TabLoadingType.myPage;

  factory AppTabError.forType({
    required TabLoadingType type,
    required VoidCallback onRetry,
    bool compact = false,
  }) {
    return switch (type) {
      TabLoadingType.map => AppTabError.map(onRetry: onRetry, compact: compact),
      TabLoadingType.food =>
        AppTabError.food(onRetry: onRetry, compact: compact),
      TabLoadingType.record =>
        AppTabError.record(onRetry: onRetry, compact: compact),
      TabLoadingType.myPage =>
        AppTabError.myPage(onRetry: onRetry, compact: compact),
    };
  }

  final TabLoadingType type;
  final VoidCallback onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = switch (type) {
      TabLoadingType.map => (
          color: const Color(0xFF0168B7),
          image: Assets.image.errorMap,
        ),
      TabLoadingType.food => (
          color: const Color(0xFF0168B7),
          image: Assets.image.errorFood,
        ),
      TabLoadingType.record => (
          color: const Color(0xFF0168B7),
          image: Assets.image.errorRecord,
        ),
      TabLoadingType.myPage => (
          color: const Color(0xFF0168B7),
          image: Assets.image.errorMypage,
        ),
    };

    final imageSize = compact ? 180.0 : 320.0;
    final titleColor = isDark ? Colors.white : const Color(0xFF555555);
    final subtitleColor = isDark ? Colors.white60 : const Color(0xFF888888);

    final content = Column(
      mainAxisAlignment:
          compact ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (!compact) const Spacer(),
        config.image.image(
          width: imageSize,
          height: imageSize,
          fit: BoxFit.contain,
        ),
        Text(
          t.notification.loadFailed,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: titleColor,
            height: 1.4,
          ),
        ),
        const Gap(4),
        Text(
          t.error.networkUnstable,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 13 : 14,
            fontWeight: FontWeight.w400,
            color: subtitleColor,
            height: 1.5,
          ),
        ),
        const Gap(24),
        _ReconnectButton(
          color: config.color,
          label: t.error.reconnectButton,
          onPressed: onRetry,
        ),
        if (!compact) const Gap(16),
        if (!compact) const Spacer(),
      ],
    );

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: compact
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: content,
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: content,
              ),
            ),
    );
  }
}

class _ReconnectButton extends StatelessWidget {
  const _ReconnectButton({
    required this.color,
    required this.label,
    required this.onPressed,
  });

  final Color color;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.sync, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
