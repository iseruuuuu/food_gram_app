import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/api/currency/services/currency_rate_service.dart';

final currencyConversionRepositoryProvider =
    Provider<CurrencyConversionRepository>(
  (ref) => CurrencyConversionRepository(
    rateService: ref.read(currencyRateServiceProvider),
  ),
);

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
    final from = fromCurrency.toUpperCase();
    final to = toCurrency.toUpperCase();
    if (from == to) {
      return amount;
    }
    final rate = await _getRate(from: from, to: to);
    return amount * rate;
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

    final rate = await _rateService.fetchRate(
      fromCurrency: from,
      toCurrency: to,
    );
    _rateCache[key] = _RateCacheEntry(
      rate: rate,
      fetchedAt: DateTime.now(),
    );
    return rate;
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
