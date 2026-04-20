import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/api/currency/repository/currency_conversion_repository.dart';
import 'package:food_gram_app/core/utils/format/post_price_formatter.dart';

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

  String get _originalDisplay => formatPostPriceDisplay(
        amount: widget.amount,
        currencyCode: widget.currencyCode,
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_autoConvertIfNeeded());
  }

  @override
  Widget build(BuildContext context) {
    final hasConverted = _convertedDisplay != null;
    final primaryText = hasConverted ? _convertedDisplay! : _originalDisplay;
    final secondaryText = hasConverted ? '(元: $_originalDisplay)' : null;
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
    final sourceCurrency = widget.currencyCode.toUpperCase();
    final targetCurrency = defaultPostPriceCurrencyForLocale(locale);
    final key = '${widget.amount}|$sourceCurrency|$targetCurrency';
    if (_lastAutoConvertKey == key) {
      return;
    }
    _lastAutoConvertKey = key;
    if (targetCurrency == sourceCurrency) {
      return;
    }
    await _handleConvert(targetCurrencyOverride: targetCurrency);
  }

  Future<void> _handleConvert({String? targetCurrencyOverride}) async {
    if (_isConverting) {
      return;
    }
    final locale = Localizations.localeOf(context);
    final targetCurrency =
        targetCurrencyOverride ?? defaultPostPriceCurrencyForLocale(locale);
    final sourceCurrency = widget.currencyCode.toUpperCase();

    if (targetCurrency == sourceCurrency) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('すでにローカル通貨です')),
      );
      return;
    }

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
    } on Exception catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('通貨変換に失敗しました: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isConverting = false);
      }
    }
  }
}
