import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/api/currency/services/currency_rate_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'currency_conversion_repository.g.dart';

@Riverpod(keepAlive: true)
CurrencyConversionRepository currencyConversionRepository(Ref ref) {
  return CurrencyConversionRepository(
    rateService: ref.read(currencyRateServiceProvider),
  );
}

class CurrencyConversionRepository {
  CurrencyConversionRepository({required CurrencyRateService rateService})
      : _rateService = rateService;

  final CurrencyRateService _rateService;
  final Map<String, _RateCacheEntry> _rateCache = <String, _RateCacheEntry>{};
  static const Duration _cacheTtl = Duration(hours: 6);

  Future<double> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final from = _normalizeCurrencyCode(fromCurrency);
    final to = _normalizeCurrencyCode(toCurrency);
    if (from.isEmpty) {
      throw ArgumentError.value(
        fromCurrency,
        'fromCurrency',
        'Currency code must not be blank.',
      );
    }
    if (to.isEmpty) {
      throw ArgumentError.value(
        toCurrency,
        'toCurrency',
        'Currency code must not be blank.',
      );
    }
    if (from == to) {
      return amount;
    }
    final rate = await _getRate(from: from, to: to);
    return amount * rate;
  }

  String _normalizeCurrencyCode(String raw) {
    final code = raw.trim().toUpperCase();
    switch (code) {
      case r'NT$':
      case 'NTD':
        return 'TWD';
      default:
        return code;
    }
  }

  Future<double> _getRate({
    required String from,
    required String to,
  }) async {
    final key = '$from->$to';
    final cached = _rateCache[key];
    if (cached != null &&
        DateTime.now().difference(cached.fetchedAt) <= _cacheTtl) {
      return cached.rate;
    }

    final rate = await _fetchRateWithFallback(
      fromCurrency: from,
      toCurrency: to,
    );
    _rateCache[key] = _RateCacheEntry(
      rate: rate,
      fetchedAt: DateTime.now(),
    );
    return rate;
  }

  Future<double> _fetchRateWithFallback({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      return await _rateService.fetchRate(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
    } on CurrencyRateException catch (e) {
      if (!e.shouldTryUsdFallback) {
        rethrow;
      }
      if (fromCurrency == 'USD' || toCurrency == 'USD') {
        rethrow;
      }
      final toUsd = await _rateService.fetchRate(
        fromCurrency: fromCurrency,
        toCurrency: 'USD',
      );
      final usdToTarget = await _rateService.fetchRate(
        fromCurrency: 'USD',
        toCurrency: toCurrency,
      );
      return toUsd * usdToTarget;
    }
  }
}

class _RateCacheEntry {
  const _RateCacheEntry({
    required this.rate,
    required this.fetchedAt,
  });

  final double rate;
  final DateTime fetchedAt;
}
