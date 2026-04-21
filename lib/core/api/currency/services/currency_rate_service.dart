import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final currencyRateServiceProvider = Provider<CurrencyRateService>(
  (ref) => CurrencyRateService(supabase: ref.read(supabaseProvider)),
);

class CurrencyRateService {
  CurrencyRateService({required SupabaseClient supabase})
      : _supabase = supabase;

  final SupabaseClient _supabase;
  static const String _functionName = 'currency-convert';

  Future<double> fetchRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final from = fromCurrency.trim().toUpperCase();
    final to = toCurrency.trim().toUpperCase();

    final FunctionResponse res;
    try {
      res = await _supabase.functions.invoke(
        _functionName,
        body: <String, dynamic>{
          'from': from,
          'to': to,
          'base': from,
          'symbols': [to],
          'quotes': [to],
          'target': to,
        },
      );
    } on FunctionException catch (e) {
      throw Exception(
        'Edge Function invoke failed: ${e.details ?? e.toString()}',
      );
    }

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid Edge Function response');
    }
    if (data['success'] == false) {
      final error = data['error']?.toString() ?? 'Unknown error';
      throw Exception('Edge Function error: $error');
    }

    final parsedRate = _extractRate(data: data, to: to);
    if (parsedRate != null) {
      return parsedRate;
    }
    throw Exception('Rate not found in Edge Function response');
  }

  double? _extractRate({
    required Map<String, dynamic> data,
    required String to,
  }) {
    final directRate = data['rate'];
    if (directRate is num && directRate > 0) {
      return directRate.toDouble();
    }

    final result = data['result'];
    if (result is num && result > 0) {
      return result.toDouble();
    }

    final rates = data['rates'];
    if (rates is Map) {
      final dynamic rate = rates[to];
      if (rate is num && rate > 0) {
        return rate.toDouble();
      }
    }

    final nestedData = data['data'];
    if (nestedData is Map<String, dynamic>) {
      return _extractRate(data: nestedData, to: to);
    }
    return null;
  }
}
