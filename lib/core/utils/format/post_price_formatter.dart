import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// ISO 4217 通貨コード（カンマ区切り・アルファベット順）。記号未定義はコードそのものを表示。
const String _kSupportedPostPriceCurrencyCsv =
    'AED,AFN,ALL,AMD,ANG,AOA,ARS,AUD,AWG,AZN,BAM,BBD,BDT,BGN,BHD,BIF,BMD,BND,'
    'BOB,BRL,BSD,BTN,BWP,BYN,BZD,CAD,CDF,CHF,CLP,CNY,COP,CRC,CUP,CVE,CZK,DJF,'
    'DKK,DOP,DZD,EGP,ERN,ETB,EUR,FJD,FKP,GBP,GEL,GHS,GIP,GMD,GNF,GTQ,GYD,HKD,'
    'HNL,HTG,HUF,IDR,ILS,INR,IQD,IRR,ISK,JMD,JOD,JPY,KES,KGS,KHR,KMF,KPW,KRW,'
    'KWD,KYD,KZT,LAK,LBP,LKR,LRD,LSL,LYD,MAD,MDL,MGA,MKD,MMK,MNT,MOP,MRU,MUR,'
    'MVR,MWK,MXN,MYR,MZN,NAD,NGN,NIO,NOK,NPR,NZD,OMR,PAB,PEN,PGK,PHP,PKR,PLN,'
    'PYG,QAR,RON,RSD,RUB,RWF,SAR,SBD,SCR,SDG,SEK,SGD,SHP,SLE,SOS,SRD,SSP,STN,'
    'SVC,SYP,SZL,THB,TJS,TMT,TND,TOP,TRY,TTD,TWD,TZS,UAH,UGX,USD,UYU,UZS,VES,'
    'VND,VUV,WST,XAF,XCD,XOF,XPF,YER,ZAR,ZMW,ZWL';

/// 投稿の参考価格で扱う ISO 4217 コード（通貨ピッカー用・**JPY 先頭**、あとはアルファベット順）
final List<String> kSupportedPostPriceCurrencies = _currencyPickerOrder();

List<String> _currencyPickerOrder() {
  final all = _kSupportedPostPriceCurrencyCsv.split(',');
  final rest = <String>[];
  for (final c in all) {
    if (c != 'JPY') {
      rest.add(c);
    }
  }
  rest.sort();
  return ['JPY', ...rest];
}

/// 表示用記号（未設定は [postPriceCurrencySymbol] がコードを返す）
const Map<String, String> _kCurrencySymbols = {
  'AED': 'د.إ',
  'AFN': '؋',
  'ALL': 'L',
  'AMD': '֏',
  'ANG': 'ƒ',
  'AOA': 'Kz',
  'ARS': r'$',
  'AUD': r'A$',
  'AWG': 'ƒ',
  'AZN': '₼',
  'BAM': 'КМ',
  'BBD': r'$',
  'BDT': '৳',
  'BGN': 'лв',
  'BHD': '.د.ب',
  'BIF': 'Fr',
  'BMD': r'$',
  'BND': r'$',
  'BOB': 'Bs.',
  'BRL': r'R$',
  'BSD': r'$',
  'BTN': 'Nu.',
  'BWP': 'P',
  'BYN': 'Br',
  'BZD': r'$',
  'CAD': r'CA$',
  'CDF': 'Fr',
  'CHF': 'Fr ',
  'CLP': r'$',
  'CNY': '¥',
  'COP': r'$',
  'CRC': '₡',
  'CUP': r'$',
  'CVE': r'$',
  'CZK': 'Kč',
  'DJF': 'Fr',
  'DKK': 'kr',
  'DOP': r'$',
  'DZD': 'د.ج',
  'EGP': 'E£',
  'ERN': 'Nfk',
  'ETB': 'Br',
  'EUR': '€',
  'FJD': r'$',
  'FKP': '£',
  'GBP': '£',
  'GEL': '₾',
  'GHS': '₵',
  'GIP': '£',
  'GMD': 'D',
  'GNF': 'Fr',
  'GTQ': 'Q',
  'GYD': r'$',
  'HKD': r'HK$',
  'HNL': 'L',
  'HTG': 'G',
  'HUF': 'Ft',
  'IDR': 'Rp',
  'ILS': '₪',
  'INR': '₹',
  'IQD': 'ع.د',
  'IRR': '﷼',
  'ISK': 'kr',
  'JMD': r'$',
  'JOD': 'د.ا',
  'JPY': '¥',
  'KES': 'KSh',
  'KGS': 'с',
  'KHR': '៛',
  'KMF': 'Fr',
  'KPW': '₩',
  'KRW': '₩',
  'KWD': 'د.ك',
  'KYD': r'$',
  'KZT': '₸',
  'LAK': '₭',
  'LBP': 'ل.ل',
  'LKR': 'Rs',
  'LRD': r'$',
  'LSL': 'L',
  'LYD': 'ل.د',
  'MAD': 'د.م.',
  'MDL': 'L',
  'MGA': 'Ar',
  'MKD': 'ден',
  'MMK': 'K',
  'MNT': '₮',
  'MOP': 'P',
  'MRU': 'UM',
  'MUR': '₨',
  'MVR': 'Rf',
  'MWK': 'MK',
  'MXN': r'MX$',
  'MYR': 'RM',
  'MZN': 'MT',
  'NAD': r'$',
  'NGN': '₦',
  'NIO': r'C$',
  'NOK': 'kr',
  'NPR': '₨',
  'NZD': r'NZ$',
  'OMR': '﷼',
  'PAB': r'$',
  'PEN': 'S/',
  'PGK': 'K',
  'PHP': '₱',
  'PKR': '₨',
  'PLN': 'zł',
  'PYG': '₲',
  'QAR': 'ر.ق',
  'RON': 'lei',
  'RSD': 'дин',
  'RUB': '₽',
  'RWF': 'Fr',
  'SAR': 'ر.س',
  'SBD': r'$',
  'SCR': '₨',
  'SDG': 'ج.س.',
  'SEK': 'kr',
  'SGD': r'S$',
  'SHP': '£',
  'SLE': 'Le',
  'SOS': 'Sh',
  'SRD': r'$',
  'SSP': '£',
  'STN': 'Db',
  'SVC': r'$',
  'SYP': '£',
  'SZL': 'L',
  'THB': '฿',
  'TJS': 'ЅМ',
  'TMT': 'm',
  'TND': 'د.ت',
  'TOP': r'T$',
  'TRY': '₺',
  'TTD': r'$',
  'TWD': r'NT$',
  'TZS': 'Sh',
  'UAH': '₴',
  'UGX': 'USh',
  'USD': r'$',
  'UYU': r'$U',
  'VES': 'Bs.',
  'VND': '₫',
  'VUV': 'Vt',
  'WST': 'T',
  'XAF': 'Fr',
  'XCD': r'$',
  'XOF': 'Fr',
  'XPF': 'Fr',
  'YER': '﷼',
  'ZAR': 'R',
  'ZMW': 'ZK',
  'ZWL': r'$',
};

String postPriceCurrencySymbol(String code) {
  return _kCurrencySymbols[code.toUpperCase()] ?? code;
}

/// 端末ロケールから初期通貨を推定（換算はしない）
String defaultPostPriceCurrencyForLocale(Locale locale) {
  final country = locale.countryCode?.toUpperCase();
  switch (country) {
    case 'JP':
      return 'JPY';
    case 'US':
    case 'EC':
    case 'SV':
    case 'ZW':
      return 'USD';
    case 'TW':
      return 'TWD';
    case 'GB':
      return 'GBP';
    case 'KR':
      return 'KRW';
    case 'CN':
      return 'CNY';
    case 'HK':
      return 'HKD';
    case 'MO':
      return 'MOP';
    case 'AU':
      return 'AUD';
    case 'NZ':
      return 'NZD';
    case 'CA':
      return 'CAD';
    case 'CH':
    case 'LI':
      return 'CHF';
    case 'SG':
      return 'SGD';
    case 'TH':
      return 'THB';
    case 'VN':
      return 'VND';
    case 'PH':
      return 'PHP';
    case 'ID':
      return 'IDR';
    case 'MY':
      return 'MYR';
    case 'IN':
      return 'INR';
    case 'PK':
      return 'PKR';
    case 'BD':
      return 'BDT';
    case 'LK':
      return 'LKR';
    case 'NP':
      return 'NPR';
    case 'BR':
      return 'BRL';
    case 'MX':
      return 'MXN';
    case 'AR':
      return 'ARS';
    case 'CL':
      return 'CLP';
    case 'CO':
      return 'COP';
    case 'PE':
      return 'PEN';
    case 'UY':
      return 'UYU';
    case 'PY':
      return 'PYG';
    case 'BO':
      return 'BOB';
    case 'CR':
      return 'CRC';
    case 'PA':
      return 'PAB';
    case 'GT':
      return 'GTQ';
    case 'DO':
      return 'DOP';
    case 'JM':
      return 'JMD';
    case 'TT':
      return 'TTD';
    case 'SE':
      return 'SEK';
    case 'NO':
      return 'NOK';
    case 'DK':
      return 'DKK';
    case 'IS':
      return 'ISK';
    case 'PL':
      return 'PLN';
    case 'CZ':
      return 'CZK';
    case 'HU':
      return 'HUF';
    case 'RO':
      return 'RON';
    case 'BG':
      return 'BGN';
    case 'TR':
      return 'TRY';
    case 'RU':
      return 'RUB';
    case 'UA':
      return 'UAH';
    case 'BY':
      return 'BYN';
    case 'GE':
      return 'GEL';
    case 'AM':
      return 'AMD';
    case 'AZ':
      return 'AZN';
    case 'KZ':
      return 'KZT';
    case 'UZ':
      return 'UZS';
    case 'AE':
      return 'AED';
    case 'SA':
      return 'SAR';
    case 'QA':
      return 'QAR';
    case 'KW':
      return 'KWD';
    case 'BH':
      return 'BHD';
    case 'OM':
      return 'OMR';
    case 'IL':
    case 'PS':
      return 'ILS';
    case 'JO':
      return 'JOD';
    case 'LB':
      return 'LBP';
    case 'EG':
      return 'EGP';
    case 'ZA':
      return 'ZAR';
    case 'NG':
      return 'NGN';
    case 'KE':
      return 'KES';
    case 'GH':
      return 'GHS';
    case 'TZ':
      return 'TZS';
    case 'UG':
      return 'UGX';
    case 'ET':
      return 'ETB';
    case 'DZ':
      return 'DZD';
    case 'MA':
      return 'MAD';
    case 'TN':
      return 'TND';
    case 'SN':
    case 'CI':
    case 'BF':
    case 'ML':
    case 'NE':
    case 'BJ':
    case 'TG':
    case 'GW':
      return 'XOF';
    case 'CM':
    case 'CF':
    case 'TD':
    case 'CG':
    case 'GQ':
    case 'GA':
      return 'XAF';
    case 'PF':
    case 'NC':
    case 'WF':
      return 'XPF';
    case 'AI':
    case 'MS':
      return 'XCD';
    default:
      const eurCountries = {
        'DE',
        'FR',
        'ES',
        'IT',
        'NL',
        'BE',
        'AT',
        'PT',
        'IE',
        'FI',
        'GR',
        'LU',
        'CY',
        'MT',
        'SK',
        'SI',
        'EE',
        'LV',
        'LT',
        'HR',
        'MC',
        'AD',
        'SM',
        'VA',
        'ME',
        'XK',
      };
      if (country != null && eurCountries.contains(country)) {
        return 'EUR';
      }
      return 'USD';
  }
}

String defaultPostPriceCurrencyFromPlatform() {
  return defaultPostPriceCurrencyForLocale(
    ui.PlatformDispatcher.instance.locale,
  );
}

bool _isIntegerStyleCurrency(String code) {
  switch (code.toUpperCase()) {
    case 'JPY':
    case 'KRW':
    case 'VND':
    case 'CLP':
    case 'UGX':
    case 'VUV':
    case 'XAF':
    case 'XOF':
    case 'XPF':
    case 'PYG':
    case 'ISK':
    case 'COP':
      return true;
    default:
      return false;
  }
}

String _formatThousandsInt(int n) {
  final digits = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buf.write(',');
    }
    buf.write(digits[i]);
  }
  final core = buf.toString();
  return n < 0 ? '-$core' : core;
}

/// 保存・表示で同じ桁になるよう [amount] を丸める。
double _canonicalPostPriceAmount(double amount, String currencyCode) {
  final code = currencyCode.toUpperCase();
  if (_isIntegerStyleCurrency(code)) {
    return amount.roundToDouble();
  }
  return double.parse(amount.toStringAsFixed(2));
}

/// カンマ除去後の [normalized]（`.` が小数点）が通貨の許容桁を超えていれば true。
bool _hasDisallowedFractionalScale(String normalized, String currencyCode) {
  final code = currencyCode.toUpperCase();
  final dot = normalized.indexOf('.');
  if (dot < 0) {
    return false;
  }
  final frac = normalized.substring(dot + 1);
  if (_isIntegerStyleCurrency(code)) {
    if (frac.isEmpty) {
      return false;
    }
    final v = int.tryParse(frac);
    if (v == null) {
      return true;
    }
    return v != 0;
  }
  return frac.length > 2;
}

/// 表示用（例: ¥1,200 / $15 / €10）。換算はしない。
String formatPostPriceDisplay({
  required double amount,
  required String currencyCode,
}) {
  final code = currencyCode.toUpperCase();
  final sym = postPriceCurrencySymbol(code);
  final a = _canonicalPostPriceAmount(amount, code);
  if (_isIntegerStyleCurrency(code)) {
    return '$sym${_formatThousandsInt(a.round())}';
  }
  var s = a.toStringAsFixed(2);
  if (s.endsWith('.00')) {
    s = s.substring(0, s.length - 3);
  } else {
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
  }
  return '$sym$s';
}

/// 未入力: [PostPriceParseResult.isEmpty]
/// 不正: [PostPriceParseResult.isInvalid]
/// 成功: 金額と通貨
class PostPriceParseResult {
  const PostPriceParseResult.empty()
      : isEmpty = true,
        isInvalid = false,
        amount = null,
        currency = null;

  const PostPriceParseResult.invalid()
      : isEmpty = false,
        isInvalid = true,
        amount = null,
        currency = null;

  const PostPriceParseResult.value({
    required this.amount,
    required this.currency,
  })  : isEmpty = false,
        isInvalid = false;

  final bool isEmpty;
  final bool isInvalid;
  final double? amount;
  final String? currency;
}

PostPriceParseResult parsePostPriceInput({
  required String rawAmount,
  required String currencyCode,
}) {
  final trimmed = rawAmount.trim();
  if (trimmed.isEmpty) {
    return const PostPriceParseResult.empty();
  }
  final code = currencyCode.toUpperCase();
  final normalized = trimmed.replaceAll(',', '');
  if (_hasDisallowedFractionalScale(normalized, code)) {
    return const PostPriceParseResult.invalid();
  }
  final value = double.tryParse(normalized);
  if (value == null || value < 0 || value > 999999999) {
    return const PostPriceParseResult.invalid();
  }
  final canonical = _canonicalPostPriceAmount(value, code);
  if (canonical != value) {
    return const PostPriceParseResult.invalid();
  }
  return PostPriceParseResult.value(
    amount: canonical,
    currency: code,
  );
}

/// 編集画面の初期表示用（保存・一覧表示と同じ桁に揃える）
String formatPostPriceForEditing(double? amount, String? currencyCode) {
  if (amount == null) {
    return '';
  }
  final code = (currencyCode ?? 'JPY').toUpperCase();
  final a = _canonicalPostPriceAmount(amount, code);
  if (_isIntegerStyleCurrency(code)) {
    return a.round().toString();
  }
  final s = a.toStringAsFixed(2);
  if (s.endsWith('.00')) {
    return s.substring(0, s.length - 3);
  }
  return s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

double? nullableDoubleFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString());
}
