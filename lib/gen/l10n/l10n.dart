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

  /// No description provided for @emailInputField.
  ///
  /// In ja, this message translates to:
  /// **'メールアドレスを入力してください'**
  String get emailInputField;

  /// No description provided for @settingsIcon.
  ///
  /// In ja, this message translates to:
  /// **'アイコンの設定'**
  String get settingsIcon;

  /// No description provided for @userName.
  ///
  /// In ja, this message translates to:
  /// **'ユーザー名'**
  String get userName;

  /// No description provided for @userNameInputField.
  ///
  /// In ja, this message translates to:
  /// **'ユーザー名を入力してください'**
  String get userNameInputField;

  /// No description provided for @userId.
  ///
  /// In ja, this message translates to:
  /// **'ユーザーID'**
  String get userId;

  /// No description provided for @userIdInputField.
  ///
  /// In ja, this message translates to:
  /// **'ユーザーIDを入力してください'**
  String get userIdInputField;

  /// No description provided for @registerButton.
  ///
  /// In ja, this message translates to:
  /// **'登録'**
  String get registerButton;

  /// No description provided for @settingsAppBar.
  ///
  /// In ja, this message translates to:
  /// **'基本設定'**
  String get settingsAppBar;

  /// No description provided for @settingsCheckVersion.
  ///
  /// In ja, this message translates to:
  /// **'最新バージョンの確認'**
  String get settingsCheckVersion;

  /// No description provided for @settingsCheckVersionDialogTitle.
  ///
  /// In ja, this message translates to:
  /// **'更新情報'**
  String get settingsCheckVersionDialogTitle;

  /// No description provided for @settingsCheckVersionDialogText1.
  ///
  /// In ja, this message translates to:
  /// **'新しいバージョンがご利用いただけます。'**
  String get settingsCheckVersionDialogText1;

  /// No description provided for @settingsCheckVersionDialogText2.
  ///
  /// In ja, this message translates to:
  /// **'最新版にアップデートしてご利用ください。'**
  String get settingsCheckVersionDialogText2;

  /// No description provided for @settingsDeveloper.
  ///
  /// In ja, this message translates to:
  /// **'開発者'**
  String get settingsDeveloper;

  /// No description provided for @settingsGithub.
  ///
  /// In ja, this message translates to:
  /// **'Github'**
  String get settingsGithub;

  /// No description provided for @settingsReview.
  ///
  /// In ja, this message translates to:
  /// **'レビューで応援する'**
  String get settingsReview;

  /// No description provided for @settingsLicense.
  ///
  /// In ja, this message translates to:
  /// **'ライセンス'**
  String get settingsLicense;

  /// No description provided for @settingsShareApp.
  ///
  /// In ja, this message translates to:
  /// **'このアプリをシェアする'**
  String get settingsShareApp;

  /// No description provided for @settingsFaq.
  ///
  /// In ja, this message translates to:
  /// **'FAQ'**
  String get settingsFaq;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In ja, this message translates to:
  /// **'プライバシーポリシー'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsOfUse.
  ///
  /// In ja, this message translates to:
  /// **'利用規約'**
  String get settingsTermsOfUse;

  /// No description provided for @settingsContact.
  ///
  /// In ja, this message translates to:
  /// **'お問い合せ'**
  String get settingsContact;

  /// No description provided for @settingsTutorial.
  ///
  /// In ja, this message translates to:
  /// **'チュートリアル'**
  String get settingsTutorial;

  /// No description provided for @settingsBatteryLevel.
  ///
  /// In ja, this message translates to:
  /// **'バッテリー残量'**
  String get settingsBatteryLevel;

  /// No description provided for @settingsDeviceInfo.
  ///
  /// In ja, this message translates to:
  /// **'端末情報'**
  String get settingsDeviceInfo;

  /// No description provided for @settingsIosVersion.
  ///
  /// In ja, this message translates to:
  /// **'iOSバージョン'**
  String get settingsIosVersion;

  /// No description provided for @settingsAndroidSdk.
  ///
  /// In ja, this message translates to:
  /// **'SDK'**
  String get settingsAndroidSdk;

  /// No description provided for @settingsAppVersion.
  ///
  /// In ja, this message translates to:
  /// **'アプリバージョン'**
  String get settingsAppVersion;

  /// No description provided for @settingsAccount.
  ///
  /// In ja, this message translates to:
  /// **'アカウント'**
  String get settingsAccount;

  /// No description provided for @settingsLogoutButton.
  ///
  /// In ja, this message translates to:
  /// **'ログアウト'**
  String get settingsLogoutButton;

  /// No description provided for @settingsDeleteAccountButton.
  ///
  /// In ja, this message translates to:
  /// **'アカウントの削除申請'**
  String get settingsDeleteAccountButton;

  /// No description provided for @postShareButton.
  ///
  /// In ja, this message translates to:
  /// **'シェア'**
  String get postShareButton;

  /// No description provided for @postFoodName.
  ///
  /// In ja, this message translates to:
  /// **'食べたもの'**
  String get postFoodName;

  /// No description provided for @postFoodNameInputField.
  ///
  /// In ja, this message translates to:
  /// **'食べたものを入力'**
  String get postFoodNameInputField;

  /// No description provided for @postRestaurantNameInputField.
  ///
  /// In ja, this message translates to:
  /// **'レストラン名を追加'**
  String get postRestaurantNameInputField;

  /// No description provided for @postComment.
  ///
  /// In ja, this message translates to:
  /// **'コメントを入力'**
  String get postComment;

  /// No description provided for @postCommentInputField.
  ///
  /// In ja, this message translates to:
  /// **'コメント(任意)'**
  String get postCommentInputField;

  /// No description provided for @editUpdateButton.
  ///
  /// In ja, this message translates to:
  /// **'更新'**
  String get editUpdateButton;

  /// No description provided for @editBio.
  ///
  /// In ja, this message translates to:
  /// **'自己紹介(任意)'**
  String get editBio;

  /// No description provided for @editBioInputField.
  ///
  /// In ja, this message translates to:
  /// **'自己紹介を入力してください'**
  String get editBioInputField;

  /// No description provided for @emptyPosts.
  ///
  /// In ja, this message translates to:
  /// **'投稿がありません'**
  String get emptyPosts;

  /// No description provided for @searchEmptyResult.
  ///
  /// In ja, this message translates to:
  /// **'該当する場所が見つかりませんでした'**
  String get searchEmptyResult;

  /// No description provided for @profilePostCount.
  ///
  /// In ja, this message translates to:
  /// **'投稿'**
  String get profilePostCount;

  /// No description provided for @profilePointCount.
  ///
  /// In ja, this message translates to:
  /// **'ポイント'**
  String get profilePointCount;

  /// No description provided for @profileEditButton.
  ///
  /// In ja, this message translates to:
  /// **'プロフィールを編集'**
  String get profileEditButton;

  /// No description provided for @profileExchangePointsButton.
  ///
  /// In ja, this message translates to:
  /// **'ポイントを交換する'**
  String get profileExchangePointsButton;

  /// No description provided for @postDetailLikeButton.
  ///
  /// In ja, this message translates to:
  /// **'いいね'**
  String get postDetailLikeButton;

  /// No description provided for @shareReviewPrefix.
  ///
  /// In ja, this message translates to:
  /// **'で食べたレビューを投稿しました！'**
  String get shareReviewPrefix;

  /// No description provided for @shareReviewSuffix.
  ///
  /// In ja, this message translates to:
  /// **'詳しくはfoodGramで確認してみよう！'**
  String get shareReviewSuffix;

  /// No description provided for @postDetailSheetTitle.
  ///
  /// In ja, this message translates to:
  /// **'この投稿について'**
  String get postDetailSheetTitle;

  /// No description provided for @postDetailSheetShareButton.
  ///
  /// In ja, this message translates to:
  /// **'この投稿をシェアする'**
  String get postDetailSheetShareButton;

  /// No description provided for @postDetailSheetReportButton.
  ///
  /// In ja, this message translates to:
  /// **'この投稿を報告する'**
  String get postDetailSheetReportButton;

  /// No description provided for @postDetailSheetBlockButton.
  ///
  /// In ja, this message translates to:
  /// **'このユーザーをブロックする'**
  String get postDetailSheetBlockButton;

  /// No description provided for @postSearchError.
  ///
  /// In ja, this message translates to:
  /// **'場所名の検索ができません'**
  String get postSearchError;

  /// No description provided for @dialogYesButton.
  ///
  /// In ja, this message translates to:
  /// **'はい'**
  String get dialogYesButton;

  /// No description provided for @dialogNoButton.
  ///
  /// In ja, this message translates to:
  /// **'いいえ'**
  String get dialogNoButton;

  /// No description provided for @dialogReportTitle.
  ///
  /// In ja, this message translates to:
  /// **'投稿の報告'**
  String get dialogReportTitle;

  /// No description provided for @dialogReportDescription1.
  ///
  /// In ja, this message translates to:
  /// **'この投稿について報告を行います'**
  String get dialogReportDescription1;

  /// No description provided for @dialogReportDescription2.
  ///
  /// In ja, this message translates to:
  /// **'Googleフォームに遷移します'**
  String get dialogReportDescription2;

  /// No description provided for @dialogBlockTitle.
  ///
  /// In ja, this message translates to:
  /// **'ブロック確認'**
  String get dialogBlockTitle;

  /// No description provided for @dialogBlockDescription1.
  ///
  /// In ja, this message translates to:
  /// **'このユーザーをブロックしますか？'**
  String get dialogBlockDescription1;

  /// No description provided for @dialogBlockDescription2.
  ///
  /// In ja, this message translates to:
  /// **'このユーザーの投稿を非表示にします'**
  String get dialogBlockDescription2;

  /// No description provided for @dialogBlockDescription3.
  ///
  /// In ja, this message translates to:
  /// **'ブロックしたユーザーはローカルで保存します'**
  String get dialogBlockDescription3;

  /// No description provided for @dialogDeleteTitle.
  ///
  /// In ja, this message translates to:
  /// **'投稿の削除'**
  String get dialogDeleteTitle;

  /// No description provided for @dialogDeleteDescription1.
  ///
  /// In ja, this message translates to:
  /// **'この投稿を削除しますか？'**
  String get dialogDeleteDescription1;

  /// No description provided for @dialogDeleteDescription2.
  ///
  /// In ja, this message translates to:
  /// **'一度削除してしまうと復元できません'**
  String get dialogDeleteDescription2;

  /// No description provided for @dialogDeleteError.
  ///
  /// In ja, this message translates to:
  /// **'削除が失敗しました'**
  String get dialogDeleteError;

  /// No description provided for @dialogLogoutTitle.
  ///
  /// In ja, this message translates to:
  /// **'ログアウトの確認'**
  String get dialogLogoutTitle;

  /// No description provided for @dialogLogoutDescription1.
  ///
  /// In ja, this message translates to:
  /// **'ログアウトしますか?'**
  String get dialogLogoutDescription1;

  /// No description provided for @dialogLogoutDescription2.
  ///
  /// In ja, this message translates to:
  /// **'アカウントの状態はサーバー上に保存されています。'**
  String get dialogLogoutDescription2;

  /// No description provided for @dialogLogoutButton.
  ///
  /// In ja, this message translates to:
  /// **'ログアウト'**
  String get dialogLogoutButton;

  /// No description provided for @errorTitle.
  ///
  /// In ja, this message translates to:
  /// **'通信エラー'**
  String get errorTitle;

  /// No description provided for @errorDescription1.
  ///
  /// In ja, this message translates to:
  /// **'接続エラーが発生しました'**
  String get errorDescription1;

  /// No description provided for @errorDescription2.
  ///
  /// In ja, this message translates to:
  /// **'ネットワーク接続を確認し、もう一度試してください'**
  String get errorDescription2;

  /// No description provided for @errorRefreshButton.
  ///
  /// In ja, this message translates to:
  /// **'再読み込み'**
  String get errorRefreshButton;

  /// No description provided for @appShareTitle.
  ///
  /// In ja, this message translates to:
  /// **'共有'**
  String get appShareTitle;

  /// No description provided for @appShareStoreButton.
  ///
  /// In ja, this message translates to:
  /// **'このお店を共有する'**
  String get appShareStoreButton;

  /// No description provided for @appShareGoButton.
  ///
  /// In ja, this message translates to:
  /// **'このお店に行ってみる'**
  String get appShareGoButton;

  /// No description provided for @appShareCloseButton.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get appShareCloseButton;

  /// No description provided for @agreeToTheTermsOfUse.
  ///
  /// In ja, this message translates to:
  /// **'利用規約に同意してください'**
  String get agreeToTheTermsOfUse;
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
