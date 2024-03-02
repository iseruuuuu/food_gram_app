// ignore_for_file: type=lint

import 'l10n.dart';

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get email_text_field => 'Enter your email address';

  @override
  String get setting_icon => 'Select Icon';

  @override
  String get user_name => 'User Name';

  @override
  String get user_name_text_field => 'Enter your user name';

  @override
  String get user_id => 'User ID';

  @override
  String get user_id_text_field => 'Enter your user id';

  @override
  String get register_button => 'Register';
}
