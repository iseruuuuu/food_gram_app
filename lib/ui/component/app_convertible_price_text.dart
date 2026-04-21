import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/api/currency/repository/currency_conversion_repository.dart';
import 'package:food_gram_app/core/utils/format/post_price_formatter.dart';
import 'package:food_gram_app/gen/strings.g.dart';

class AppConvertiblePriceText extends ConsumerStatefulWidget {
  const AppConvertiblePriceText({
    required this.amount,
    required this.currencyCode,
    required this.style,
    super.key,
  });

  final double amount;
  final String currencyCode;
  final TextStyle style;

  @override
  ConsumerState<AppConvertiblePriceText> createState() =>
      _AppConvertiblePriceTextState();
}

class _AppConvertiblePriceTextState
    extends ConsumerState<AppConvertiblePriceText> {
  String? _convertedDisplay;
  bool _isConverting = false;
  String? _lastAutoConvertKey;
  String? _dependencyLocaleTag;

  String get _originalDisplay => formatPostPriceDisplay(
        amount: widget.amount,
        currencyCode: widget.currencyCode.trim(),
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    final tag = locale.toLanguageTag();
    if (_dependencyLocaleTag != tag) {
      _dependencyLocaleTag = tag;
      _clearAndScheduleConvert();
    }
  }

  @override
  void didUpdateWidget(covariant AppConvertiblePriceText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount ||
        oldWidget.currencyCode != widget.currencyCode) {
      _clearAndScheduleConvert();
    }
  }

  void _clearAndScheduleConvert() {
    if (!mounted) {
      return;
    }
    setState(() {
      _convertedDisplay = null;
      _lastAutoConvertKey = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_autoConvertIfNeeded());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final hasConverted = _convertedDisplay != null;
    final primaryText = hasConverted ? _convertedDisplay! : _originalDisplay;
    final secondaryText = hasConverted
        ? t.translatable.priceConvertedOriginalSuffix
            .replaceAll('{price}', _originalDisplay)
        : null;
    final secondaryStyle = widget.style.copyWith(
      fontSize: (widget.style.fontSize ?? 16) * 0.7,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: primaryText,
            style: widget.style,
          ),
          if (secondaryText != null)
            TextSpan(
              text: ' $secondaryText',
              style: secondaryStyle,
            ),
        ],
      ),
    );
  }

  Future<void> _autoConvertIfNeeded() async {
    final locale = Localizations.localeOf(context);
    final sourceCurrency = widget.currencyCode.trim().toUpperCase();
    final targetCurrency = defaultPostPriceCurrencyForLocale(locale);
    final key = '${locale.toLanguageTag()}'
        '|${widget.amount}'
        '|$sourceCurrency'
        '|$targetCurrency';

    if (_lastAutoConvertKey == key) {
      return;
    }
    _lastAutoConvertKey = key;

    if (targetCurrency == sourceCurrency) {
      if (_convertedDisplay != null && mounted) {
        setState(() => _convertedDisplay = null);
      }
      return;
    }

    await _handleConvert(
      targetCurrencyOverride: targetCurrency,
      sourceCurrencyOverride: sourceCurrency,
    );
  }

  Future<void> _handleConvert({
    required String targetCurrencyOverride,
    required String sourceCurrencyOverride,
  }) async {
    if (_isConverting) {
      return;
    }
    final targetCurrency = targetCurrencyOverride;
    final sourceCurrency = sourceCurrencyOverride;

    setState(() => _isConverting = true);
    try {
      final repository = ref.read(currencyConversionRepositoryProvider);
      final converted = await repository.convert(
        amount: widget.amount,
        fromCurrency: sourceCurrency,
        toCurrency: targetCurrency,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _convertedDisplay = formatPostPriceDisplay(
          amount: converted,
          currencyCode: targetCurrency,
        );
      });
    } on Exception catch (e, st) {
      debugPrint('AppConvertiblePriceText: convert failed: $e\n$st');
      if (!mounted) {
        return;
      }
      final t = Translations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translatable.priceConversionFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _isConverting = false);
      }
    }
  }
}
