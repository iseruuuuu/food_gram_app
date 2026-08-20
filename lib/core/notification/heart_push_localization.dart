import 'dart:io';

import 'package:food_gram_app/gen/strings.g.dart';

const int heartPushVariantCount = 5;

Translations devicePushTranslations() {
  final rawLocale = Platform.localeName.replaceAll('_', '-');
  final appLocale = AppLocaleUtils.parse(rawLocale);
  return LocaleSettings.instance.translationMap[appLocale] ??
      LocaleSettings.instance.translationMap[AppLocale.en]!;
}

int parseHeartPushVariant(Object? raw) {
  final parsed = raw is int ? raw : int.tryParse('$raw');
  if (parsed == null) {
    return 0;
  }
  return parsed.abs() % heartPushVariantCount;
}

({String title, String body}) heartPushCopy({
  required Translations translations,
  required int variant,
  required String userName,
}) {
  final push = translations.notification.heartPush;
  final (title, bodyTemplate) = switch (variant % heartPushVariantCount) {
    0 => (push.title0, push.body0),
    1 => (push.title1, push.body1),
    2 => (push.title2, push.body2),
    3 => (push.title3, push.body3),
    _ => (push.title4, push.body4),
  };
  return (
    title: title,
    body: bodyTemplate.replaceAll('{name}', userName),
  );
}
