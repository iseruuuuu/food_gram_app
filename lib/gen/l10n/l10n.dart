// ignore_for_file
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_ja.dart';

// ignore_for_file: type=lint

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
  /// **'アップデート'**
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
  /// **'公式Twitter'**
  String get settingsDeveloper;

  /// No description provided for @settingsGithub.
  ///
  /// In ja, this message translates to:
  /// **'Github'**
  String get settingsGithub;

  /// No description provided for @settingsReview.
  ///
  /// In ja, this message translates to:
  /// **'レビューする'**
  String get settingsReview;

  /// No description provided for @settingsLicense.
  ///
  /// In ja, this message translates to:
  /// **'ライセンス'**
  String get settingsLicense;

  /// No description provided for @settingsShareApp.
  ///
  /// In ja, this message translates to:
  /// **'シェアする'**
  String get settingsShareApp;

  /// No description provided for @settingsFaq.
  ///
  /// In ja, this message translates to:
  /// **'FAQ'**
  String get settingsFaq;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In ja, this message translates to:
  /// **'プライバシー'**
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

  /// No description provided for @settingsCredit.
  ///
  /// In ja, this message translates to:
  /// **'クレジット'**
  String get settingsCredit;

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
  /// **'アカウント削除申請'**
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

  /// No description provided for @postError.
  ///
  /// In ja, this message translates to:
  /// **'投稿失敗'**
  String get postError;

  /// No description provided for @postCategoryTitle.
  ///
  /// In ja, this message translates to:
  /// **'国・料理カテゴリーの選択(任意)'**
  String get postCategoryTitle;

  /// No description provided for @postCountryCategory.
  ///
  /// In ja, this message translates to:
  /// **'国'**
  String get postCountryCategory;

  /// No description provided for @postCuisineCategory.
  ///
  /// In ja, this message translates to:
  /// **'料理'**
  String get postCuisineCategory;

  /// No description provided for @postTitle.
  ///
  /// In ja, this message translates to:
  /// **'投稿'**
  String get postTitle;

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

  /// No description provided for @homeCooking.
  ///
  /// In ja, this message translates to:
  /// **'自炊'**
  String get homeCooking;

  /// No description provided for @unknown.
  ///
  /// In ja, this message translates to:
  /// **'不明・ヒットなし'**
  String get unknown;

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

  /// No description provided for @appShareInstagramButton.
  ///
  /// In ja, this message translates to:
  /// **'Instagramで共有する'**
  String get appShareInstagramButton;

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

  /// No description provided for @appRestaurantLabel.
  ///
  /// In ja, this message translates to:
  /// **'レストランを検索'**
  String get appRestaurantLabel;

  /// No description provided for @restaurantCategoryList.
  ///
  /// In ja, this message translates to:
  /// **'国別料理を選ぶ'**
  String get restaurantCategoryList;

  /// No description provided for @cookingCategoryList.
  ///
  /// In ja, this message translates to:
  /// **'料理カテゴリーを選ぶ'**
  String get cookingCategoryList;

  /// No description provided for @tabHome.
  ///
  /// In ja, this message translates to:
  /// **'フード'**
  String get tabHome;

  /// No description provided for @tabMap.
  ///
  /// In ja, this message translates to:
  /// **'マップ'**
  String get tabMap;

  /// No description provided for @tabMyPage.
  ///
  /// In ja, this message translates to:
  /// **'マイページ'**
  String get tabMyPage;

  /// No description provided for @tabSetting.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get tabSetting;

  /// No description provided for @logoutFailure.
  ///
  /// In ja, this message translates to:
  /// **'ログアウト失敗'**
  String get logoutFailure;

  /// No description provided for @accountDeletionFailure.
  ///
  /// In ja, this message translates to:
  /// **'アカウント削除失敗'**
  String get accountDeletionFailure;

  /// No description provided for @appleLoginFailure.
  ///
  /// In ja, this message translates to:
  /// **'Appleログインはできません'**
  String get appleLoginFailure;

  /// No description provided for @emailAuthenticationFailure.
  ///
  /// In ja, this message translates to:
  /// **'メール認証の失敗'**
  String get emailAuthenticationFailure;

  /// No description provided for @loginError.
  ///
  /// In ja, this message translates to:
  /// **'ログインエラー'**
  String get loginError;

  /// No description provided for @loginSuccessful.
  ///
  /// In ja, this message translates to:
  /// **'ログイン成功'**
  String get loginSuccessful;

  /// No description provided for @emailAuthentication.
  ///
  /// In ja, this message translates to:
  /// **'メールアプリで認証をしてください'**
  String get emailAuthentication;

  /// No description provided for @emailEmpty.
  ///
  /// In ja, this message translates to:
  /// **'メールアドレスが入力されていません'**
  String get emailEmpty;

  /// No description provided for @error.
  ///
  /// In ja, this message translates to:
  /// **'エラーが発生しました'**
  String get error;

  /// No description provided for @appRequestTitle.
  ///
  /// In ja, this message translates to:
  /// **'🙇現在地をオンにしてください🙇'**
  String get appRequestTitle;

  /// No description provided for @appRequestReason.
  ///
  /// In ja, this message translates to:
  /// **'レストランの選択には現在地のデータが必要になります'**
  String get appRequestReason;

  /// No description provided for @appRequestInduction.
  ///
  /// In ja, this message translates to:
  /// **'以下のボタンから設定画面に遷移します'**
  String get appRequestInduction;

  /// No description provided for @appRequestOpenSetting.
  ///
  /// In ja, this message translates to:
  /// **'設定画面を開く'**
  String get appRequestOpenSetting;

  /// No description provided for @email.
  ///
  /// In ja, this message translates to:
  /// **'メールアドレス'**
  String get email;

  /// No description provided for @enterTheCorrectFormat.
  ///
  /// In ja, this message translates to:
  /// **'正しい形式で入力してください'**
  String get enterTheCorrectFormat;

  /// No description provided for @camera.
  ///
  /// In ja, this message translates to:
  /// **'カメラ'**
  String get camera;

  /// No description provided for @album.
  ///
  /// In ja, this message translates to:
  /// **'アルバム'**
  String get album;

  /// No description provided for @snsLogin.
  ///
  /// In ja, this message translates to:
  /// **'SNSログイン'**
  String get snsLogin;

  /// No description provided for @tutorialFirstPageTitle.
  ///
  /// In ja, this message translates to:
  /// **'美味しい瞬間、シェアしよう'**
  String get tutorialFirstPageTitle;

  /// No description provided for @tutorialFirstPageSubTitle.
  ///
  /// In ja, this message translates to:
  /// **'FoodGramで、毎日の食事がもっと特別に\n新しい味との出会いを楽しもう'**
  String get tutorialFirstPageSubTitle;

  /// No description provided for @tutorialSecondPageTitle.
  ///
  /// In ja, this message translates to:
  /// **'このアプリだけのフードマップ'**
  String get tutorialSecondPageTitle;

  /// No description provided for @tutorialSecondPageSubTitle.
  ///
  /// In ja, this message translates to:
  /// **'このアプリだけのマップ作りをしよう\nあなたの投稿でマップが進化していく'**
  String get tutorialSecondPageSubTitle;

  /// No description provided for @tutorialThirdPageTitle.
  ///
  /// In ja, this message translates to:
  /// **'利用規約'**
  String get tutorialThirdPageTitle;

  /// No description provided for @tutorialThirdPageSubTitle.
  ///
  /// In ja, this message translates to:
  /// **'・氏名、住所、電話番号などの個人情報や位置情報の公開には注意しましょう。\n\n・攻撃的、不適切、または有害なコンテンツの投稿を避け、他人の作品を無断で使用しないようにしましょう。\n\n・食べ物以外の投稿は削除させていただく場合があります。\n\n・違反が繰り返されるユーザーや不快なコンテンツは運営側で削除します。\n\n・アプリには不完全な部分があるかもしれませんので、ご理解ください。\n\n・みなさんと一緒にこのアプリをより良くしていけることを楽しみにしています。\n\n・サービス向上のため、ご協力お願いします🙇 by 開発者'**
  String get tutorialThirdPageSubTitle;

  /// No description provided for @tutorialThirdPageButton.
  ///
  /// In ja, this message translates to:
  /// **'利用規約に同意する'**
  String get tutorialThirdPageButton;

  /// No description provided for @tutorialThirdPageClose.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get tutorialThirdPageClose;

  /// No description provided for @settingRestoreSuccessTitle.
  ///
  /// In ja, this message translates to:
  /// **'復元が成功しました'**
  String get settingRestoreSuccessTitle;

  /// No description provided for @settingRestoreSuccessSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'プレミアム機能が有効になりました！'**
  String get settingRestoreSuccessSubtitle;

  /// No description provided for @settingRestoreFailureTitle.
  ///
  /// In ja, this message translates to:
  /// **'復元失敗'**
  String get settingRestoreFailureTitle;

  /// No description provided for @settingRestoreFailureSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'購入履歴がない場合はサポートにご連絡を'**
  String get settingRestoreFailureSubtitle;

  /// No description provided for @settingRestore.
  ///
  /// In ja, this message translates to:
  /// **'購入を復元'**
  String get settingRestore;

  /// No description provided for @authInvalidFormat.
  ///
  /// In ja, this message translates to:
  /// **'メールアドレスのフォーマットが間違っています'**
  String get authInvalidFormat;

  /// No description provided for @authSocketException.
  ///
  /// In ja, this message translates to:
  /// **'ネットワークに問題があります。接続を確認してください'**
  String get authSocketException;

  /// No description provided for @detailMenuShare.
  ///
  /// In ja, this message translates to:
  /// **'シェア'**
  String get detailMenuShare;

  /// No description provided for @detailMenuVisit.
  ///
  /// In ja, this message translates to:
  /// **'行く'**
  String get detailMenuVisit;

  /// No description provided for @detailMenuPost.
  ///
  /// In ja, this message translates to:
  /// **'投稿'**
  String get detailMenuPost;

  /// No description provided for @detailMenuSearch.
  ///
  /// In ja, this message translates to:
  /// **'調べる'**
  String get detailMenuSearch;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In ja, this message translates to:
  /// **'アップデートのお知らせ'**
  String get forceUpdateTitle;

  /// No description provided for @forceUpdateText.
  ///
  /// In ja, this message translates to:
  /// **'このアプリの新しいバージョンがリリースされました。最新の機能や安全な環境でご利用いただくために、アプリをアップデートしてください。'**
  String get forceUpdateText;

  /// No description provided for @forceUpdateButtonTitle.
  ///
  /// In ja, this message translates to:
  /// **'アップデート'**
  String get forceUpdateButtonTitle;

  /// No description provided for @mapLoadingError.
  ///
  /// In ja, this message translates to:
  /// **'エラーが発生しました'**
  String get mapLoadingError;

  /// No description provided for @mapLoadingRestaurant.
  ///
  /// In ja, this message translates to:
  /// **'店舗情報を取得中...'**
  String get mapLoadingRestaurant;

  /// No description provided for @postMissingInfo.
  ///
  /// In ja, this message translates to:
  /// **'必須項目を入力してください'**
  String get postMissingInfo;

  /// No description provided for @postPhotoSuccess.
  ///
  /// In ja, this message translates to:
  /// **'写真を追加しました'**
  String get postPhotoSuccess;

  /// No description provided for @postCameraPermission.
  ///
  /// In ja, this message translates to:
  /// **'カメラの許可が必要です'**
  String get postCameraPermission;

  /// No description provided for @postAlbumPermission.
  ///
  /// In ja, this message translates to:
  /// **'フォトライブラリの許可が必要です'**
  String get postAlbumPermission;

  /// No description provided for @postSuccess.
  ///
  /// In ja, this message translates to:
  /// **'投稿が完了しました'**
  String get postSuccess;
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
