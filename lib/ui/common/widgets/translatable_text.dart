import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/translation/translation_service.dart';

class TranslatableText extends ConsumerStatefulWidget {
  const TranslatableText(
    this.text, {
    super.key,
    this.style,
    this.overflow,
    this.textAlign,
    this.enableCopy = true,
  });

  final String text;
  final TextStyle? style;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool enableCopy;

  @override
  ConsumerState<TranslatableText> createState() => _TranslatableTextState();
}

class _TranslatableTextState extends ConsumerState<TranslatableText> {
  String? _translated;
  // 二重実行防止のためのフラグ
  bool _isTranslating = false;

  @override
  Widget build(BuildContext context) {
    final displayText = _translated ?? widget.text;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: _onLongPress,
      child: Text(
        displayText,
        style: widget.style,
        overflow: widget.overflow,
        textAlign: widget.textAlign,
      ),
    );
  }

  Future<void> _onLongPress() async {
    if (!mounted) {
      return;
    }
    // 長押しメニュー（翻訳/原文/コピー）
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.translate),
                onTap: () => Navigator.of(ctx).pop('translate'),
              ),
              if (_translated != null)
                ListTile(
                  leading: const Icon(Icons.undo),
                  onTap: () => Navigator.of(ctx).pop('original'),
                ),
              if (widget.enableCopy)
                ListTile(
                  leading: const Icon(Icons.copy),
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
        await _handleTranslate();
      case 'original':
        setState(() => _translated = null);
      case 'copy':
        await _handleCopy();
    }
  }

  Future<void> _handleTranslate() async {
    // 多重翻訳の連打対策
    if (_isTranslating) {
      return;
    }
    setState(() => _isTranslating = true);
    final svc = ref.read(translationServiceProvider);
    final locale = Localizations.localeOf(context);
    try {
      final out = await svc.translateIfNeeded(
        text: widget.text,
        targetLocale: locale,
      );
      if (!mounted) {
        return;
      }
      setState(() => _translated = out);
    } finally {
      if (mounted) {
        setState(() => _isTranslating = false);
      }
    }
  }

  Future<void> _handleCopy() async {
    final text = _translated ?? widget.text;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
    );
  }
}
