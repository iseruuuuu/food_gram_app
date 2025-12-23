import 'package:flutter/material.dart';

class URL {
  const URL._();

  static const sns = 'https://x.com/FoodGram_dev';
  static const github = 'https://github.com/iseruuuuu/food_gram_app';
  static const appleStore =
      'https://apps.apple.com/hu/app/foodgram/id6474065183';
  static const googleStore =
      'https://play.google.com/store/apps/details?id=com.food_gram_app.com.com.com';
  static const contact = 'https://forms.gle/mjucjntt3c2SZsUc7';
  static const report =
      'https://docs.google.com/forms/d/1uDNHpaPTNPK7tBjbfNW87ykYH3JZO0D2l10oBtVxaQA/edit';
  static const question =
      'https://marshmallow-qa.com/z74iurv681w1qeh?t=CpDR1z&utm_medium=url_text&utm_source=promotion';

  // GitHub base URL
  static const _githubBase =
      'https://github.com/iseruuuuu/food_gram_app/blob/main/docs';

  // Language-specific URLs
  static const _faqJa = '$_githubBase/ja/FAQ.md';
  static const _faqEn = '$_githubBase/en/FAQ.md';
  static const _privacyPolicyJa = '$_githubBase/ja/PRIVACY_POLICY.md';
  static const _privacyPolicyEn = '$_githubBase/en/PRIVACY_POLICY.md';
  static const _termsOfServiceJa = '$_githubBase/ja/TERMS_OF_SERVICE.md';
  static const _termsOfServiceEn = '$_githubBase/en/TERMS_OF_SERVICE.md';

  /// Get FAQ URL based on current locale
  static String faq(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ja' ? _faqJa : _faqEn;
  }

  /// Get Privacy Policy URL based on current locale
  static String privacyPolicy(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ja' ? _privacyPolicyJa : _privacyPolicyEn;
  }

  /// Get Terms of Service URL based on current locale
  static String termsOfUse(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ja' ? _termsOfServiceJa : _termsOfServiceEn;
  }

  static String go(String restaurant) =>
      'https://www.google.com/maps/search/?api=1&query=$restaurant';

  static String search(String restaurant) =>
      'https://www.google.com/search?q=$restaurant';
}
