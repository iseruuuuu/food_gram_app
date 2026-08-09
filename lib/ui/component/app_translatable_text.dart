import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/translation/translation_service.dart';
import 'package:food_gram_app/gen/strings.g.dart';

class AppTranslatableText extends ConsumerStatefulWidget {
  const AppTranslatableText(
    this.text, {
    super.key,
    this.style,
    this.overflow,
    this.textAlign,
    this.maxLines,
    this.softWrap,
    this.enableCopy = true,
    this.autoTranslate = false,
  });

  final String text;
  final TextStyle? style;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final int? maxLines;
  final bool? softWrap;
  final bool enableCopy;

  /// true のとき、アプリ言語へ自動翻訳して表示する。
  final bool autoTranslate;

  @override
  ConsumerState<AppTranslatableText> createState() => _TranslatableTextState();
}

class _TranslatableTextState extends ConsumerState<AppTranslatableText> {
  String? _translated;
  // 二重実行防止のためのフラグ
  bool _isTranslating = false;
  // ユーザーが原文表示を選んだ場合は自動翻訳結果を出さない
  bool _showOriginal = false;
  Locale? _lastLocale;
  String? _lastSourceText;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (widget.autoTranslate &&
        (_lastLocale != locale || _lastSourceText != widget.text)) {
      _lastLocale = locale;
      _lastSourceText = widget.text;
      _showOriginal = false;
      _translated = null;
      _scheduleAutoTranslate();
    }
  }

  @override
  void didUpdateWidget(covariant AppTranslatableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.autoTranslate != widget.autoTranslate) {
      _showOriginal = false;
      _translated = null;
      _lastSourceText = widget.text;
      if (widget.autoTranslate) {
        _scheduleAutoTranslate();
      }
    }
  }

  void _scheduleAutoTranslate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _handleTranslate(silent: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayText =
        (!_showOriginal && _translated != null) ? _translated! : widget.text;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: _onLongPress,
      child: Text(
        displayText,
        style: widget.style,
        overflow: widget.overflow,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        softWrap: widget.softWrap,
      ),
    );
  }

  Future<void> _onLongPress() async {
    if (!mounted) {
      return;
    }
    final t = Translations.of(context);
    final translateLabel = t.translatable.translate;
    final showOriginalLabel = t.translatable.showOriginal;
    final copyLabel = t.translatable.copy;
    final showingTranslated = !_showOriginal && _translated != null;
    // 長押しメニュー（翻訳/原文/コピー）
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!showingTranslated)
                ListTile(
                  leading: const Icon(Icons.translate),
                  title: Text(translateLabel),
                  onTap: () => Navigator.of(ctx).pop('translate'),
                ),
              if (showingTranslated)
                ListTile(
                  leading: const Icon(Icons.undo),
                  title: Text(showOriginalLabel),
                  onTap: () => Navigator.of(ctx).pop('original'),
                ),
              if (widget.enableCopy)
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: Text(copyLabel),
                  onTap: () => Navigator.of(ctx).pop('copy'),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }
    switch (action) {
      case 'translate':
        _showOriginal = false;
        await _handleTranslate(silent: false);
      case 'original':
        setState(() => _showOriginal = true);
      case 'copy':
        await _handleCopy();
    }
  }

  Future<void> _handleTranslate({required bool silent}) async {
    // 多重翻訳の連打対策
    if (_isTranslating) {
      return;
    }
    final svc = ref.read(translationServiceProvider);
    final locale = Localizations.localeOf(context);
    // 同一言語であれば何もしない
    final need = await svc.shouldTranslate(
      text: widget.text,
      targetLocale: locale,
    );
    if (!need) {
      if (!mounted || silent) {
        return;
      }
      final t = Translations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translatable.translateFailed)),
      );
      return;
    }
    setState(() => _isTranslating = true);
    try {
      final out = await svc.translateIfNeeded(
        text: widget.text,
        targetLocale: locale,
      );
      if (!mounted) {
        return;
      }
      // 翻訳できなかった（原文と同じ）の場合
      if (out.trim() == widget.text.trim()) {
        if (!silent) {
          final t = Translations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.translatable.translateFailed)),
          );
        }
        return;
      }
      setState(() {
        _translated = out;
        _showOriginal = false;
      });
      if (!silent) {
        await ref.read(firebaseAnalyticsServiceProvider).logEvent(
              name: AnalyticsEvent.postTranslate,
            );
      }
    } finally {
      if (mounted) {
        setState(() => _isTranslating = false);
      }
    }
  }

  Future<void> _handleCopy() async {
    final text =
        (!_showOriginal && _translated != null) ? _translated! : widget.text;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    final t = Translations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t.translatable.copied)));
  }
}
