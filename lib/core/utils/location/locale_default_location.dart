import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// 位置情報がないときの最終フォールバック（日本中心付近）
const LatLng japanDefaultLocation = LatLng(36.2048, 137.9777);

/// 地域中心都市の座標
const LatLng _tokyo = LatLng(35.6812, 139.7671);
const LatLng _newYork = LatLng(40.7128, -74.006);
const LatLng _london = LatLng(51.5074, -0.1278);
const LatLng _sydney = LatLng(-33.8688, 151.2093);
const LatLng _toronto = LatLng(43.6532, -79.3832);
const LatLng _seoul = LatLng(37.5665, 126.978);
const LatLng _paris = LatLng(48.8566, 2.3522);
const LatLng _berlin = LatLng(52.52, 13.405);
const LatLng _bangkok = LatLng(13.7563, 100.5018);
const LatLng _mexicoCity = LatLng(19.4326, -99.1332);
const LatLng _madrid = LatLng(40.4168, -3.7038);
const LatLng _saoPaulo = LatLng(-23.5505, -46.6333);
const LatLng _lisbon = LatLng(38.7223, -9.1393);
const LatLng _taipei = LatLng(25.033, 121.5654);
const LatLng _shanghai = LatLng(31.2304, 121.4737);
const LatLng _hoChiMinh = LatLng(10.8231, 106.6297);

/// `language_COUNTRY` 完全一致（言語＋地域が揃っているときだけ使う）
const Map<String, LatLng> _byLanguageCountry = {
  'en_US': _newYork,
  'en_GB': _london,
  'en_AU': _sydney,
  'en_CA': _toronto,
  'es_MX': _mexicoCity,
  'es_ES': _madrid,
  'pt_BR': _saoPaulo,
  'pt_PT': _lisbon,
  'zh_TW': _taipei,
  'zh_CN': _shanghai,
  'ja_JP': _tokyo,
  'ko_KR': _seoul,
  'fr_FR': _paris,
  'de_DE': _berlin,
  'th_TH': _bangkok,
  'vi_VN': _hoChiMinh,
};

/// 言語のみ（端末の使用言語に合わせる。曖昧な言語は代表都市）
const Map<String, LatLng> _byLanguage = {
  'ja': _tokyo,
  'en': _newYork,
  'ko': _seoul,
  'fr': _paris,
  'de': _berlin,
  'th': _bangkok,
  'vi': _hoChiMinh,
  'es': _madrid,
  'pt': _saoPaulo,
  'zh': _shanghai,
};

/// 国コードのみ（言語で決まらないときの弱いフォールバック）
const Map<String, LatLng> _byCountry = {
  'JP': _tokyo,
  'US': _newYork,
  'GB': _london,
  'AU': _sydney,
  'CA': _toronto,
  'KR': _seoul,
  'FR': _paris,
  'DE': _berlin,
  'TH': _bangkok,
  'MX': _mexicoCity,
  'ES': _madrid,
  'BR': _saoPaulo,
  'PT': _lisbon,
  'TW': _taipei,
  'CN': _shanghai,
  'VN': _hoChiMinh,
};

/// 端末ロケールから地図の初期表示位置を決める。
///
/// 解決順: `language_COUNTRY` → `languageCode` → `countryCode` → 日本中心。
/// 言語を地域より優先する（例: `en_JP` → 英語としてニューヨーク）。
/// [locale] 省略時は [ui.PlatformDispatcher.instance.locale] を使う。
LatLng defaultLocationFromDeviceLocale([Locale? locale]) {
  final l = locale ?? ui.PlatformDispatcher.instance.locale;
  final language = l.languageCode.toLowerCase();
  final country = l.countryCode?.toUpperCase();
  final hasCountry = country != null && country.isNotEmpty;

  if (hasCountry) {
    final languageCountry = '${language}_$country';
    final byExact = _byLanguageCountry[languageCountry];
    if (byExact != null) {
      return byExact;
    }
  }

  final byLanguage = _byLanguage[language];
  if (byLanguage != null) {
    return byLanguage;
  }

  if (hasCountry) {
    final byCountry = _byCountry[country];
    if (byCountry != null) {
      return byCountry;
    }
  }

  return japanDefaultLocation;
}
