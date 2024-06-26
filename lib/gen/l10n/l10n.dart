// ignore_for_file: type=lint
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_ja.dart';

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ja'),
    Locale('en')
  ];

  /// No description provided for @close.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @email_text_field.
  ///
  /// In ja, this message translates to:
  /// **'メールアドレスを入力してください'**
  String get email_text_field;

  /// No description provided for @setting_icon.
  ///
  /// In ja, this message translates to:
  /// **'アイコンの設定'**
  String get setting_icon;

  /// No description provided for @user_name.
  ///
  /// In ja, this message translates to:
  /// **'ユーザー名'**
  String get user_name;

  /// No description provided for @user_name_text_field.
  ///
  /// In ja, this message translates to:
  /// **'ユーザー名を入力してください'**
  String get user_name_text_field;

  /// No description provided for @user_id.
  ///
  /// In ja, this message translates to:
  /// **'ユーザーID'**
  String get user_id;

  /// No description provided for @user_id_text_field.
  ///
  /// In ja, this message translates to:
  /// **'ユーザーIDを入力してください'**
  String get user_id_text_field;

  /// No description provided for @register_button.
  ///
  /// In ja, this message translates to:
  /// **'登録'**
  String get register_button;

  /// No description provided for @setting_app_bar.
  ///
  /// In ja, this message translates to:
  /// **'基本設定'**
  String get setting_app_bar;

  /// No description provided for @setting_check_version.
  ///
  /// In ja, this message translates to:
  /// **'最新バージョンの確認'**
  String get setting_check_version;

  /// No description provided for @setting_check_version_dialog_title.
  ///
  /// In ja, this message translates to:
  /// **'更新情報'**
  String get setting_check_version_dialog_title;

  /// No description provided for @setting_check_version_dialog_text_1.
  ///
  /// In ja, this message translates to:
  /// **'新しいバージョンがご利用いただけます。'**
  String get setting_check_version_dialog_text_1;

  /// No description provided for @setting_check_version_dialog_text_2.
  ///
  /// In ja, this message translates to:
  /// **'最新版にアップデートしてご利用ください。'**
  String get setting_check_version_dialog_text_2;

  /// No description provided for @setting_developer.
  ///
  /// In ja, this message translates to:
  /// **'開発者'**
  String get setting_developer;

  /// No description provided for @setting_github.
  ///
  /// In ja, this message translates to:
  /// **'Github'**
  String get setting_github;

  /// No description provided for @setting_review.
  ///
  /// In ja, this message translates to:
  /// **'レビューで応援する'**
  String get setting_review;

  /// No description provided for @setting_license.
  ///
  /// In ja, this message translates to:
  /// **'ライセンス'**
  String get setting_license;

  /// No description provided for @setting_share.
  ///
  /// In ja, this message translates to:
  /// **'このアプリをシェアする'**
  String get setting_share;

  /// No description provided for @setting_faq.
  ///
  /// In ja, this message translates to:
  /// **'FAQ'**
  String get setting_faq;

  /// No description provided for @setting_privacy_policy.
  ///
  /// In ja, this message translates to:
  /// **'プライバシーポリシー'**
  String get setting_privacy_policy;

  /// No description provided for @setting_terms_of_use.
  ///
  /// In ja, this message translates to:
  /// **'利用規約'**
  String get setting_terms_of_use;

  /// No description provided for @setting_contact.
  ///
  /// In ja, this message translates to:
  /// **'お問い合せ'**
  String get setting_contact;

  /// No description provided for @setting_tutorial.
  ///
  /// In ja, this message translates to:
  /// **'チュートリアル'**
  String get setting_tutorial;

  /// No description provided for @setting_battery.
  ///
  /// In ja, this message translates to:
  /// **'バッテリー残量'**
  String get setting_battery;

  /// No description provided for @setting_device.
  ///
  /// In ja, this message translates to:
  /// **'端末情報'**
  String get setting_device;

  /// No description provided for @setting_ios.
  ///
  /// In ja, this message translates to:
  /// **'iOSバージョン'**
  String get setting_ios;

  /// No description provided for @setting_android.
  ///
  /// In ja, this message translates to:
  /// **'SDK'**
  String get setting_android;

  /// No description provided for @setting_app_version.
  ///
  /// In ja, this message translates to:
  /// **'アプリバージョン'**
  String get setting_app_version;

  /// No description provided for @setting_account.
  ///
  /// In ja, this message translates to:
  /// **'アカウント'**
  String get setting_account;

  /// No description provided for @setting_logout_button.
  ///
  /// In ja, this message translates to:
  /// **'ログアウト'**
  String get setting_logout_button;

  /// No description provided for @setting_delete_account_button.
  ///
  /// In ja, this message translates to:
  /// **'アカウントの削除申請'**
  String get setting_delete_account_button;

  /// No description provided for @post_share.
  ///
  /// In ja, this message translates to:
  /// **'シェア'**
  String get post_share;

  /// No description provided for @post_food_name.
  ///
  /// In ja, this message translates to:
  /// **'食べたもの'**
  String get post_food_name;

  /// No description provided for @post_food_name_text_field.
  ///
  /// In ja, this message translates to:
  /// **'食べたものを入力'**
  String get post_food_name_text_field;

  /// No description provided for @post_place.
  ///
  /// In ja, this message translates to:
  /// **'レストラン名を追加'**
  String get post_place;

  /// No description provided for @post_comment.
  ///
  /// In ja, this message translates to:
  /// **'コメントを入力'**
  String get post_comment;

  /// No description provided for @post_comment_text_field.
  ///
  /// In ja, this message translates to:
  /// **'コメント(任意)'**
  String get post_comment_text_field;

  /// No description provided for @edit_update_button.
  ///
  /// In ja, this message translates to:
  /// **'更新'**
  String get edit_update_button;

  /// No description provided for @edit_bio.
  ///
  /// In ja, this message translates to:
  /// **'自己紹介(任意)'**
  String get edit_bio;

  /// No description provided for @edit_bio_text_field.
  ///
  /// In ja, this message translates to:
  /// **'自己紹介を入力してください'**
  String get edit_bio_text_field;

  /// No description provided for @empty.
  ///
  /// In ja, this message translates to:
  /// **'投稿がありません'**
  String get empty;

  /// No description provided for @search_empty.
  ///
  /// In ja, this message translates to:
  /// **'該当する場所が見つかりませんでした'**
  String get search_empty;

  /// No description provided for @my_profile_post_length.
  ///
  /// In ja, this message translates to:
  /// **'投稿'**
  String get my_profile_post_length;

  /// No description provided for @my_profile_edit_button.
  ///
  /// In ja, this message translates to:
  /// **'プロフィールを編集'**
  String get my_profile_edit_button;

  /// No description provided for @my_profile_exchange_point_button.
  ///
  /// In ja, this message translates to:
  /// **'ポイントを交換する'**
  String get my_profile_exchange_point_button;

  /// No description provided for @post_detail_heart.
  ///
  /// In ja, this message translates to:
  /// **'いいね'**
  String get post_detail_heart;

  /// No description provided for @share_review_1.
  ///
  /// In ja, this message translates to:
  /// **'で食べたレビューを投稿しました！'**
  String get share_review_1;

  /// No description provided for @share_review_2.
  ///
  /// In ja, this message translates to:
  /// **'詳しくはfoodGramで確認してみよう！'**
  String get share_review_2;

  /// No description provided for @posts_detail_sheet_title.
  ///
  /// In ja, this message translates to:
  /// **'この投稿について'**
  String get posts_detail_sheet_title;

  /// No description provided for @posts_detail_sheet_share.
  ///
  /// In ja, this message translates to:
  /// **'この投稿をシェアする'**
  String get posts_detail_sheet_share;

  /// No description provided for @posts_detail_sheet_search.
  ///
  /// In ja, this message translates to:
  /// **'この投稿をシェアする'**
  String get posts_detail_sheet_search;

  /// No description provided for @posts_detail_sheet_report.
  ///
  /// In ja, this message translates to:
  /// **'この投稿を報告する'**
  String get posts_detail_sheet_report;

  /// No description provided for @posts_detail_sheet_block.
  ///
  /// In ja, this message translates to:
  /// **'このユーザーをブロックする'**
  String get posts_detail_sheet_block;

  /// No description provided for @posts_search_error.
  ///
  /// In ja, this message translates to:
  /// **'場所名の検索ができません'**
  String get posts_search_error;

  /// No description provided for @dialog_yes.
  ///
  /// In ja, this message translates to:
  /// **'はい'**
  String get dialog_yes;

  /// No description provided for @dialog_no.
  ///
  /// In ja, this message translates to:
  /// **'いいえ'**
  String get dialog_no;

  /// No description provided for @dialog_report_title.
  ///
  /// In ja, this message translates to:
  /// **'投稿の報告'**
  String get dialog_report_title;

  /// No description provided for @dialog_report_description_1.
  ///
  /// In ja, this message translates to:
  /// **'この投稿について報告を行います'**
  String get dialog_report_description_1;

  /// No description provided for @dialog_report_description_2.
  ///
  /// In ja, this message translates to:
  /// **'Googleフォームに遷移します'**
  String get dialog_report_description_2;

  /// No description provided for @dialog_block_title.
  ///
  /// In ja, this message translates to:
  /// **'ブロック確認'**
  String get dialog_block_title;

  /// No description provided for @dialog_block_description_1.
  ///
  /// In ja, this message translates to:
  /// **'この投稿をユーザーをブロックしますか？'**
  String get dialog_block_description_1;

  /// No description provided for @dialog_block_description_2.
  ///
  /// In ja, this message translates to:
  /// **'このユーザーの投稿を非表示にします'**
  String get dialog_block_description_2;

  /// No description provided for @dialog_block_description_3.
  ///
  /// In ja, this message translates to:
  /// **'ブロックしたユーザーはローカルで保存します'**
  String get dialog_block_description_3;

  /// No description provided for @dialog_delete_title.
  ///
  /// In ja, this message translates to:
  /// **'投稿の削除'**
  String get dialog_delete_title;

  /// No description provided for @dialog_delete_description_1.
  ///
  /// In ja, this message translates to:
  /// **'この投稿を削除しますか？'**
  String get dialog_delete_description_1;

  /// No description provided for @dialog_delete_description_2.
  ///
  /// In ja, this message translates to:
  /// **'一度削除してしまうと復元できません'**
  String get dialog_delete_description_2;

  /// No description provided for @dialog_delete_error.
  ///
  /// In ja, this message translates to:
  /// **'削除が失敗しました'**
  String get dialog_delete_error;

  /// No description provided for @dialog_logout_title.
  ///
  /// In ja, this message translates to:
  /// **'ログアウトの確認'**
  String get dialog_logout_title;

  /// No description provided for @dialog_logout_description_1.
  ///
  /// In ja, this message translates to:
  /// **'ログアウトしますか?'**
  String get dialog_logout_description_1;

  /// No description provided for @dialog_logout_description_2.
  ///
  /// In ja, this message translates to:
  /// **'アカウントの状態はサーバー上に保存されています。'**
  String get dialog_logout_description_2;

  /// No description provided for @dialog_logout.
  ///
  /// In ja, this message translates to:
  /// **'ログアウト'**
  String get dialog_logout;

  /// No description provided for @error_title.
  ///
  /// In ja, this message translates to:
  /// **'通信エラー'**
  String get error_title;

  /// No description provided for @error_description_1.
  ///
  /// In ja, this message translates to:
  /// **'接続エラーが発生しました'**
  String get error_description_1;

  /// No description provided for @error_description_2.
  ///
  /// In ja, this message translates to:
  /// **'ネットワーク接続を確認し、もう一度試してください'**
  String get error_description_2;

  /// No description provided for @error_refresh.
  ///
  /// In ja, this message translates to:
  /// **'再読み込み'**
  String get error_refresh;

  /// No description provided for @app_share_title.
  ///
  /// In ja, this message translates to:
  /// **'共有'**
  String get app_share_title;

  /// No description provided for @app_share_share_store.
  ///
  /// In ja, this message translates to:
  /// **'このお店を共有する'**
  String get app_share_share_store;

  /// No description provided for @app_share_go.
  ///
  /// In ja, this message translates to:
  /// **'このお店に行ってみる'**
  String get app_share_go;

  /// No description provided for @app_share_close.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get app_share_close;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return L10nEn();
    case 'ja': return L10nJa();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
