// ignore_for_file: type=lint

import 'l10n.dart';

/// The translations for Japanese (`ja`).
class L10nJa extends L10n {
  L10nJa([String locale = 'ja']) : super(locale);

  @override
  String get email_text_field => 'メールアドレスを入力してください';

  @override
  String get setting_icon => 'アイコンの設定';

  @override
  String get user_name => 'ユーザー名';

  @override
  String get user_name_text_field => 'ユーザー名を入力してください';

  @override
  String get user_id => 'ユーザーID';

  @override
  String get user_id_text_field => 'ユーザーIDを入力してください';

  @override
  String get register_button => '登録';
}
