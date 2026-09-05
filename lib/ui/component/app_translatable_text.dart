import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/translation/translation_service.dart';
import 'package:food_gram_app/core/utils/restaurant/restaurant_display_name.dart';
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
  bool _isTranslating = false;
  // ユーザーが原文表示を選んだ場合は自動翻訳結果を出さない
  bool _showOriginal = false;
  Locale? _lastLocale;
  String? _lastSourceText;
  // テキスト / ロケール変更のたびに増え、古い翻訳結果を捨てる
  int _generation = 0;
  // 翻訳中に新しい自動翻訳要求が来た場合に再実行する
  bool _pendingAutoTranslate = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (widget.autoTranslate &&
        !isUnknownRestaurantName(widget.text) &&
        (_lastLocale != locale || _lastSourceText != widget.text)) {
      _invalidateTranslation(locale: locale, sourceText: widget.text);
      _scheduleAutoTranslate();
    }
  }

  @override
  void didUpdateWidget(covariant AppTranslatableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.autoTranslate != widget.autoTranslate) {
      _invalidateTranslation(
        locale: _lastLocale ?? Localizations.localeOf(context),
        sourceText: widget.text,
      );
      if (widget.autoTranslate && !isUnknownRestaurantName(widget.text)) {
        _scheduleAutoTranslate();
      }
    }
  }

  void _invalidateTranslation({
    required Locale locale,
    required String sourceText,
  }) {
    _generation++;
    _showOriginal = false;
    _translated = null;
    _lastLocale = locale;
    _lastSourceText = sourceText;
  }

  void _scheduleAutoTranslate() {
    if (_isTranslating) {
      _pendingAutoTranslate = true;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !widget.autoTranslate ||
          isUnknownRestaurantName(widget.text)) {
        return;
      }
      _handleTranslate(silent: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final displayText = isUnknownRestaurantName(widget.text)
        ? localizedRestaurantName(widget.text, t)
        : ((!_showOriginal && _translated != null)
            ? _translated!
            : widget.text);
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
    final isUnknown = isUnknownRestaurantName(widget.text);
    // 長押しメニュー（翻訳/原文/コピー）
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!showingTranslated && !isUnknown)
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
    if (_isTranslating) {
      if (silent) {
        _pendingAutoTranslate = true;
      }
      return;
    }

    final svc = ref.read(translationServiceProvider);
    if (isUnknownRestaurantName(widget.text)) {
      return;
    }

    final sourceText = widget.text;
    final locale = Localizations.localeOf(context);
    final requestGeneration = _generation;

    final need = await svc.shouldTranslate(
      text: sourceText,
      targetLocale: locale,
    );
    if (!_isCurrentRequest(
      generation: requestGeneration,
      sourceText: sourceText,
      locale: locale,
    )) {
      return;
    }
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
        text: sourceText,
        targetLocale: locale,
      );
      if (!_isCurrentRequest(
        generation: requestGeneration,
        sourceText: sourceText,
        locale: locale,
      )) {
        return;
      }
      // 翻訳できなかった（原文と同じ）の場合
      if (out.trim() == sourceText.trim()) {
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
      } else {
        _isTranslating = false;
      }
      if (_pendingAutoTranslate && mounted && widget.autoTranslate) {
        _pendingAutoTranslate = false;
        _scheduleAutoTranslate();
      }
    }
  }

  bool _isCurrentRequest({
    required int generation,
    required String sourceText,
    required Locale locale,
  }) {
    if (!mounted) {
      return false;
    }
    return generation == _generation &&
        sourceText == widget.text &&
        locale == Localizations.localeOf(context);
  }

  Future<void> _handleCopy() async {
    final t = Translations.of(context);
    final text = isUnknownRestaurantName(widget.text)
        ? localizedRestaurantName(widget.text, t)
        : ((!_showOriginal && _translated != null)
            ? _translated!
            : widget.text);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t.translatable.copied)));
  }
}
