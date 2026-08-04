import 'package:food_gram_app/gen/strings.g.dart';

/// 端末ロケールから Google Places API 向けの language コードを返す。
///
/// Places は BCP-47 形式（例: `zh-TW`）を受け付ける。
/// `zh` は簡体字、`zhTw` は繁体字として明示する。
String googlePlacesLanguageCode([AppLocale? locale]) {
  final current = locale ?? LocaleSettings.currentLocale;
  return switch (current) {
    AppLocale.zhTw => 'zh-TW',
    AppLocale.zh => 'zh-CN',
    _ => current.languageCode,
  };
}
