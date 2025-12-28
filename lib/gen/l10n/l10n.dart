// ignore_for_file
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_de.dart';
import 'l10n_en.dart';
import 'l10n_es.dart';
import 'l10n_fr.dart';
import 'l10n_ja.dart';
import 'l10n_ko.dart';
import 'l10n_pt.dart';
import 'l10n_th.dart';
import 'l10n_vi.dart';
import 'l10n_zh.dart';

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
  L10n(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ja'),
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('ko'),
    Locale('pt'),
    Locale('th'),
    Locale('vi'),
    Locale('zh'),
    Locale('zh', 'TW')
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

  /// No description provided for @editTitle.
  ///
  /// In ja, this message translates to:
  /// **'編集'**
  String get editTitle;

  /// No description provided for @editPostButton.
  ///
  /// In ja, this message translates to:
  /// **'編集する'**
  String get editPostButton;

  /// No description provided for @emailInputField.
  ///
  /// In ja, this message translates to:
  /// **'メールアドレスを入力してください'**
  String get emailInputField;

  /// No description provided for @settingIcon.
  ///
  /// In ja, this message translates to:
  /// **'アイコンの設定'**
  String get settingIcon;

  /// No description provided for @userName.
  ///
  /// In ja, this message translates to:
  /// **'ユーザー名'**
  String get userName;

  /// No description provided for @userNameInputField.
  ///
  /// In ja, this message translates to:
  /// **'ユーザー名（例：いせりゅー）'**
  String get userNameInputField;

  /// No description provided for @userId.
  ///
  /// In ja, this message translates to:
  /// **'ユーザーID'**
  String get userId;

  /// No description provided for @userIdInputField.
  ///
  /// In ja, this message translates to:
  /// **'ユーザーID （例：iseryuuu）'**
  String get userIdInputField;

  /// No description provided for @registerButton.
  ///
  /// In ja, this message translates to:
  /// **'登録'**
  String get registerButton;

  /// No description provided for @settingAppBar.
  ///
  /// In ja, this message translates to:
  /// **'基本設定'**
  String get settingAppBar;

  /// No description provided for @settingCheckVersion.
  ///
  /// In ja, this message translates to:
  /// **'アップデート'**
  String get settingCheckVersion;

  /// No description provided for @settingCheckVersionDialogTitle.
  ///
  /// In ja, this message translates to:
  /// **'更新情報'**
  String get settingCheckVersionDialogTitle;

  /// No description provided for @settingCheckVersionDialogText1.
  ///
  /// In ja, this message translates to:
  /// **'新しいバージョンがご利用いただけます。'**
  String get settingCheckVersionDialogText1;

  /// No description provided for @settingCheckVersionDialogText2.
  ///
  /// In ja, this message translates to:
  /// **'最新版にアップデートしてご利用ください。'**
  String get settingCheckVersionDialogText2;

  /// No description provided for @settingDeveloper.
  ///
  /// In ja, this message translates to:
  /// **'公式Twitter'**
  String get settingDeveloper;

  /// No description provided for @settingGithub.
  ///
  /// In ja, this message translates to:
  /// **'Github'**
  String get settingGithub;

  /// No description provided for @settingReview.
  ///
  /// In ja, this message translates to:
  /// **'レビューする'**
  String get settingReview;

  /// No description provided for @settingLicense.
  ///
  /// In ja, this message translates to:
  /// **'ライセンス'**
  String get settingLicense;

  /// No description provided for @settingShareApp.
  ///
  /// In ja, this message translates to:
  /// **'シェアする'**
  String get settingShareApp;

  /// No description provided for @settingFaq.
  ///
  /// In ja, this message translates to:
  /// **'FAQ'**
  String get settingFaq;

  /// No description provided for @settingPrivacyPolicy.
  ///
  /// In ja, this message translates to:
  /// **'プライバシー'**
  String get settingPrivacyPolicy;

  /// No description provided for @settingTermsOfUse.
  ///
  /// In ja, this message translates to:
  /// **'利用規約'**
  String get settingTermsOfUse;

  /// No description provided for @settingContact.
  ///
  /// In ja, this message translates to:
  /// **'お問い合せ'**
  String get settingContact;

  /// No description provided for @settingTutorial.
  ///
  /// In ja, this message translates to:
  /// **'チュートリアル'**
  String get settingTutorial;

  /// No description provided for @settingCredit.
  ///
  /// In ja, this message translates to:
  /// **'クレジット'**
  String get settingCredit;

  /// No description provided for @unregistered.
  ///
  /// In ja, this message translates to:
  /// **'未登録'**
  String get unregistered;

  /// No description provided for @settingBatteryLevel.
  ///
  /// In ja, this message translates to:
  /// **'バッテリー残量'**
  String get settingBatteryLevel;

  /// No description provided for @settingDeviceInfo.
  ///
  /// In ja, this message translates to:
  /// **'端末情報'**
  String get settingDeviceInfo;

  /// No description provided for @settingIosVersion.
  ///
  /// In ja, this message translates to:
  /// **'iOSバージョン'**
  String get settingIosVersion;

  /// No description provided for @settingAndroidSdk.
  ///
  /// In ja, this message translates to:
  /// **'SDK'**
  String get settingAndroidSdk;

  /// No description provided for @settingAppVersion.
  ///
  /// In ja, this message translates to:
  /// **'アプリバージョン'**
  String get settingAppVersion;

  /// No description provided for @settingAccount.
  ///
  /// In ja, this message translates to:
  /// **'アカウント'**
  String get settingAccount;

  /// No description provided for @settingLogoutButton.
  ///
  /// In ja, this message translates to:
  /// **'ログアウト'**
  String get settingLogoutButton;

  /// No description provided for @settingDeleteAccountButton.
  ///
  /// In ja, this message translates to:
  /// **'アカウント削除申請'**
  String get settingDeleteAccountButton;

  /// No description provided for @settingQuestion.
  ///
  /// In ja, this message translates to:
  /// **'質問箱'**
  String get settingQuestion;

  /// No description provided for @settingAccountManagement.
  ///
  /// In ja, this message translates to:
  /// **'アカウント管理'**
  String get settingAccountManagement;

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

  /// No description provided for @settingPremiumMembership.
  ///
  /// In ja, this message translates to:
  /// **'プレミアム会員になって特別な体験を'**
  String get settingPremiumMembership;

  /// No description provided for @shareButton.
  ///
  /// In ja, this message translates to:
  /// **'シェア'**
  String get shareButton;

  /// No description provided for @postFoodName.
  ///
  /// In ja, this message translates to:
  /// **'食べたもの'**
  String get postFoodName;

  /// No description provided for @postFoodNameInputField.
  ///
  /// In ja, this message translates to:
  /// **'食べたものを入力(必須)'**
  String get postFoodNameInputField;

  /// No description provided for @postRestaurantNameInputField.
  ///
  /// In ja, this message translates to:
  /// **'レストラン名を追加(必須)'**
  String get postRestaurantNameInputField;

  /// No description provided for @postComment.
  ///
  /// In ja, this message translates to:
  /// **'コメントを入力(任意)'**
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
  /// **'国・料理タグの選択(任意)'**
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

  /// No description provided for @postMissingInfo.
  ///
  /// In ja, this message translates to:
  /// **'必須項目を入力してください'**
  String get postMissingInfo;

  /// No description provided for @postMissingPhoto.
  ///
  /// In ja, this message translates to:
  /// **'写真を追加してください'**
  String get postMissingPhoto;

  /// No description provided for @postMissingFoodName.
  ///
  /// In ja, this message translates to:
  /// **'食べたものを入力してください'**
  String get postMissingFoodName;

  /// No description provided for @postMissingRestaurant.
  ///
  /// In ja, this message translates to:
  /// **'レストラン名を追加してください'**
  String get postMissingRestaurant;

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

  /// No description provided for @postSearchError.
  ///
  /// In ja, this message translates to:
  /// **'場所名の検索ができません'**
  String get postSearchError;

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

  /// No description provided for @editFavoriteTagTitle.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りタグの選択'**
  String get editFavoriteTagTitle;

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

  /// No description provided for @searchButton.
  ///
  /// In ja, this message translates to:
  /// **'検索'**
  String get searchButton;

  /// No description provided for @searchTitle.
  ///
  /// In ja, this message translates to:
  /// **'検索'**
  String get searchTitle;

  /// No description provided for @searchRestaurantTitle.
  ///
  /// In ja, this message translates to:
  /// **'レストランを探す'**
  String get searchRestaurantTitle;

  /// No description provided for @searchUserTitle.
  ///
  /// In ja, this message translates to:
  /// **'ユーザー検索'**
  String get searchUserTitle;

  /// No description provided for @searchUserHeader.
  ///
  /// In ja, this message translates to:
  /// **'ユーザー検索（投稿数順）'**
  String get searchUserHeader;

  /// No description provided for @searchUserPostCount.
  ///
  /// In ja, this message translates to:
  /// **'投稿数: {count}件'**
  String searchUserPostCount(Object count);

  /// No description provided for @searchUserLatestPosts.
  ///
  /// In ja, this message translates to:
  /// **'最新の投稿'**
  String get searchUserLatestPosts;

  /// No description provided for @searchUserNoUsers.
  ///
  /// In ja, this message translates to:
  /// **'投稿しているユーザーがいません'**
  String get searchUserNoUsers;

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

  /// No description provided for @profileFavoriteGenre.
  ///
  /// In ja, this message translates to:
  /// **'好きなジャンル'**
  String get profileFavoriteGenre;

  /// No description provided for @likeButton.
  ///
  /// In ja, this message translates to:
  /// **'いいね'**
  String get likeButton;

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

  /// No description provided for @heartLimitMessage.
  ///
  /// In ja, this message translates to:
  /// **'今日は10回までです。明日までお待ちください。'**
  String get heartLimitMessage;

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

  /// No description provided for @error.
  ///
  /// In ja, this message translates to:
  /// **'エラーが発生しました'**
  String get error;

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

  /// No description provided for @shareInviteMessage.
  ///
  /// In ja, this message translates to:
  /// **'美味しいフードをFoodGramでシェアしよう!'**
  String get shareInviteMessage;

  /// No description provided for @appRestaurantLabel.
  ///
  /// In ja, this message translates to:
  /// **'レストランを検索'**
  String get appRestaurantLabel;

  /// No description provided for @appRequestTitle.
  ///
  /// In ja, this message translates to:
  /// **'位置情報をオンにしよう！'**
  String get appRequestTitle;

  /// No description provided for @appRequestReason.
  ///
  /// In ja, this message translates to:
  /// **'近くのおいしいお店を見つけるために、\n美味しいレストランを探しやすくするために'**
  String get appRequestReason;

  /// No description provided for @appRequestInduction.
  ///
  /// In ja, this message translates to:
  /// **'以下のボタンから設定画面に遷移します'**
  String get appRequestInduction;

  /// No description provided for @appRequestOpenSetting.
  ///
  /// In ja, this message translates to:
  /// **'位置情報をオンにする'**
  String get appRequestOpenSetting;

  /// No description provided for @appTitle.
  ///
  /// In ja, this message translates to:
  /// **'FoodGram'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'美味しい瞬間、シェアしよう'**
  String get appSubtitle;

  /// No description provided for @agreeToTheTermsOfUse.
  ///
  /// In ja, this message translates to:
  /// **'利用規約に同意してください'**
  String get agreeToTheTermsOfUse;

  /// No description provided for @restaurantCategoryList.
  ///
  /// In ja, this message translates to:
  /// **'国別料理を選ぶ'**
  String get restaurantCategoryList;

  /// No description provided for @cookingCategoryList.
  ///
  /// In ja, this message translates to:
  /// **'料理タグを選ぶ'**
  String get cookingCategoryList;

  /// No description provided for @restaurantReviewNew.
  ///
  /// In ja, this message translates to:
  /// **'新着'**
  String get restaurantReviewNew;

  /// No description provided for @restaurantReviewViewDetails.
  ///
  /// In ja, this message translates to:
  /// **'詳細を見る'**
  String get restaurantReviewViewDetails;

  /// No description provided for @restaurantReviewOtherPosts.
  ///
  /// In ja, this message translates to:
  /// **'他の投稿も見てみる'**
  String get restaurantReviewOtherPosts;

  /// No description provided for @restaurantReviewReviewList.
  ///
  /// In ja, this message translates to:
  /// **'レビュー一覧'**
  String get restaurantReviewReviewList;

  /// No description provided for @restaurantReviewError.
  ///
  /// In ja, this message translates to:
  /// **'エラーが発生しました'**
  String get restaurantReviewError;

  /// No description provided for @nearbyRestaurants.
  ///
  /// In ja, this message translates to:
  /// **'📍近いレストラン'**
  String get nearbyRestaurants;

  /// No description provided for @seeMore.
  ///
  /// In ja, this message translates to:
  /// **'もっとみる'**
  String get seeMore;

  /// No description provided for @selectCountryTag.
  ///
  /// In ja, this message translates to:
  /// **'国タグの選択'**
  String get selectCountryTag;

  /// No description provided for @selectFavoriteTag.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りタグを選択'**
  String get selectFavoriteTag;

  /// No description provided for @favoriteTagPlaceholder.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りのタグ'**
  String get favoriteTagPlaceholder;

  /// No description provided for @selectFoodTag.
  ///
  /// In ja, this message translates to:
  /// **'料理タグの選択'**
  String get selectFoodTag;

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

  /// No description provided for @tabMyMap.
  ///
  /// In ja, this message translates to:
  /// **'マイマップ'**
  String get tabMyMap;

  /// No description provided for @tabSearch.
  ///
  /// In ja, this message translates to:
  /// **'探す'**
  String get tabSearch;

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

  /// No description provided for @mapStatsVisitedArea.
  ///
  /// In ja, this message translates to:
  /// **'訪問エリア'**
  String get mapStatsVisitedArea;

  /// No description provided for @mapStatsPosts.
  ///
  /// In ja, this message translates to:
  /// **'投稿'**
  String get mapStatsPosts;

  /// No description provided for @mapStatsActivityDays.
  ///
  /// In ja, this message translates to:
  /// **'活動日数'**
  String get mapStatsActivityDays;

  /// No description provided for @dayUnit.
  ///
  /// In ja, this message translates to:
  /// **'日'**
  String get dayUnit;

  /// No description provided for @mapStatsPrefectures.
  ///
  /// In ja, this message translates to:
  /// **'都道府県'**
  String get mapStatsPrefectures;

  /// No description provided for @mapStatsAchievementRate.
  ///
  /// In ja, this message translates to:
  /// **'達成率'**
  String get mapStatsAchievementRate;

  /// No description provided for @mapStatsVisitedCountries.
  ///
  /// In ja, this message translates to:
  /// **'訪問国'**
  String get mapStatsVisitedCountries;

  /// No description provided for @mapViewTypeRecord.
  ///
  /// In ja, this message translates to:
  /// **'記録'**
  String get mapViewTypeRecord;

  /// No description provided for @mapViewTypeJapan.
  ///
  /// In ja, this message translates to:
  /// **'日本'**
  String get mapViewTypeJapan;

  /// No description provided for @mapViewTypeWorld.
  ///
  /// In ja, this message translates to:
  /// **'世界'**
  String get mapViewTypeWorld;

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

  /// No description provided for @tutorialDiscoverTitle.
  ///
  /// In ja, this message translates to:
  /// **'最高の一皿、見つけに行こう！'**
  String get tutorialDiscoverTitle;

  /// No description provided for @tutorialDiscoverSubTitle.
  ///
  /// In ja, this message translates to:
  /// **'スクロールするたび、おいしい発見\n美味しいフードを探求しよう'**
  String get tutorialDiscoverSubTitle;

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
  /// **'・氏名、住所、電話番号などの個人情報や位置情報の公開には注意しましょう。\n\n・攻撃的、不適切、または有害なコンテンツの投稿を避け、他人の作品を無断で使用しないようにしましょう。\n\n・食べ物以外の投稿は削除させていただく場合があります。\n\n・違反が繰り返されるユーザーや不快なコンテンツは運営側で削除します。\n\n・みなさんと一緒にこのアプリをより良くしていけることを楽しみにしています by 開発者'**
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

  /// No description provided for @newAccountImportantTitle.
  ///
  /// In ja, this message translates to:
  /// **'重要な注意事項'**
  String get newAccountImportantTitle;

  /// No description provided for @newAccountImportant.
  ///
  /// In ja, this message translates to:
  /// **'アカウントを作成する際、ユーザー名やユーザーIDには、メールアドレスや電話番号などの個人情報を含めないようにしてください。安全なオンライン体験のため、個人情報が特定されない名前を設定してください。'**
  String get newAccountImportant;

  /// No description provided for @accountRegistrationSuccess.
  ///
  /// In ja, this message translates to:
  /// **'アカウントの登録が完了しました'**
  String get accountRegistrationSuccess;

  /// No description provided for @accountRegistrationError.
  ///
  /// In ja, this message translates to:
  /// **'エラーが発生しました'**
  String get accountRegistrationError;

  /// No description provided for @requiredInfoMissing.
  ///
  /// In ja, this message translates to:
  /// **'必要な情報が入力されていません'**
  String get requiredInfoMissing;

  /// No description provided for @shareTextAndImage.
  ///
  /// In ja, this message translates to:
  /// **'テキスト＋画像でシェア'**
  String get shareTextAndImage;

  /// No description provided for @shareImageOnly.
  ///
  /// In ja, this message translates to:
  /// **'画像のみシェア'**
  String get shareImageOnly;

  /// No description provided for @foodCategoryNoodles.
  ///
  /// In ja, this message translates to:
  /// **'麺類'**
  String get foodCategoryNoodles;

  /// No description provided for @foodCategoryMeat.
  ///
  /// In ja, this message translates to:
  /// **'肉料理'**
  String get foodCategoryMeat;

  /// No description provided for @foodCategoryFastFood.
  ///
  /// In ja, this message translates to:
  /// **'ファストフード'**
  String get foodCategoryFastFood;

  /// No description provided for @foodCategoryRiceDishes.
  ///
  /// In ja, this message translates to:
  /// **'ごはん'**
  String get foodCategoryRiceDishes;

  /// No description provided for @foodCategorySeafood.
  ///
  /// In ja, this message translates to:
  /// **'魚介'**
  String get foodCategorySeafood;

  /// No description provided for @foodCategoryBread.
  ///
  /// In ja, this message translates to:
  /// **'パン'**
  String get foodCategoryBread;

  /// No description provided for @foodCategorySweetsAndSnacks.
  ///
  /// In ja, this message translates to:
  /// **'スイーツ'**
  String get foodCategorySweetsAndSnacks;

  /// No description provided for @foodCategoryFruits.
  ///
  /// In ja, this message translates to:
  /// **'フルーツ'**
  String get foodCategoryFruits;

  /// No description provided for @foodCategoryVegetables.
  ///
  /// In ja, this message translates to:
  /// **'野菜'**
  String get foodCategoryVegetables;

  /// No description provided for @foodCategoryBeverages.
  ///
  /// In ja, this message translates to:
  /// **'飲み物'**
  String get foodCategoryBeverages;

  /// No description provided for @foodCategoryOthers.
  ///
  /// In ja, this message translates to:
  /// **'その他'**
  String get foodCategoryOthers;

  /// No description provided for @foodCategoryAll.
  ///
  /// In ja, this message translates to:
  /// **'全て'**
  String get foodCategoryAll;

  /// No description provided for @rankEmerald.
  ///
  /// In ja, this message translates to:
  /// **'エメラルド'**
  String get rankEmerald;

  /// No description provided for @rankDiamond.
  ///
  /// In ja, this message translates to:
  /// **'ダイヤモンド'**
  String get rankDiamond;

  /// No description provided for @rankGold.
  ///
  /// In ja, this message translates to:
  /// **'ゴールド'**
  String get rankGold;

  /// No description provided for @rankSilver.
  ///
  /// In ja, this message translates to:
  /// **'シルバー'**
  String get rankSilver;

  /// No description provided for @rankBronze.
  ///
  /// In ja, this message translates to:
  /// **'ブロンズ'**
  String get rankBronze;

  /// No description provided for @rank.
  ///
  /// In ja, this message translates to:
  /// **'ランク'**
  String get rank;

  /// No description provided for @promoteDialogTitle.
  ///
  /// In ja, this message translates to:
  /// **'✨プレミアム会員になろう✨'**
  String get promoteDialogTitle;

  /// No description provided for @promoteDialogTrophyTitle.
  ///
  /// In ja, this message translates to:
  /// **'トロフィー機能'**
  String get promoteDialogTrophyTitle;

  /// No description provided for @promoteDialogTrophyDesc.
  ///
  /// In ja, this message translates to:
  /// **'特定の活動に応じてトロフィーを表示できるようになります。'**
  String get promoteDialogTrophyDesc;

  /// No description provided for @promoteDialogTagTitle.
  ///
  /// In ja, this message translates to:
  /// **'カスタムタグ'**
  String get promoteDialogTagTitle;

  /// No description provided for @promoteDialogTagDesc.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りのフードに独自のタグを設定できます。'**
  String get promoteDialogTagDesc;

  /// No description provided for @promoteDialogIconTitle.
  ///
  /// In ja, this message translates to:
  /// **'カスタムアイコン'**
  String get promoteDialogIconTitle;

  /// No description provided for @promoteDialogIconDesc.
  ///
  /// In ja, this message translates to:
  /// **'プロフィールアイコンを自由な画像に設定できます!!'**
  String get promoteDialogIconDesc;

  /// No description provided for @promoteDialogAdTitle.
  ///
  /// In ja, this message translates to:
  /// **'広告フリー'**
  String get promoteDialogAdTitle;

  /// No description provided for @promoteDialogAdDesc.
  ///
  /// In ja, this message translates to:
  /// **'すべての広告が表示されなくなります!!'**
  String get promoteDialogAdDesc;

  /// No description provided for @promoteDialogButton.
  ///
  /// In ja, this message translates to:
  /// **'プレミアム会員になる'**
  String get promoteDialogButton;

  /// No description provided for @promoteDialogLater.
  ///
  /// In ja, this message translates to:
  /// **'後で考える'**
  String get promoteDialogLater;

  /// No description provided for @paywallTitle.
  ///
  /// In ja, this message translates to:
  /// **'FoodGram Premium'**
  String get paywallTitle;

  /// No description provided for @paywallPremiumTitle.
  ///
  /// In ja, this message translates to:
  /// **'✨ プレミアム特典 ✨'**
  String get paywallPremiumTitle;

  /// No description provided for @paywallTrophyTitle.
  ///
  /// In ja, this message translates to:
  /// **'投稿数に応じて称号がもらえる'**
  String get paywallTrophyTitle;

  /// No description provided for @paywallTrophyDesc.
  ///
  /// In ja, this message translates to:
  /// **'投稿数が増えると称号が変わる'**
  String get paywallTrophyDesc;

  /// No description provided for @paywallTagTitle.
  ///
  /// In ja, this message translates to:
  /// **'好きなジャンルを設定可能に'**
  String get paywallTagTitle;

  /// No description provided for @paywallTagDesc.
  ///
  /// In ja, this message translates to:
  /// **'設定してよりおしゃれなプロフィールに'**
  String get paywallTagDesc;

  /// No description provided for @paywallIconTitle.
  ///
  /// In ja, this message translates to:
  /// **'アイコンを好きな画像に変更可能'**
  String get paywallIconTitle;

  /// No description provided for @paywallIconDesc.
  ///
  /// In ja, this message translates to:
  /// **'他の投稿者よりも目立つようになる'**
  String get paywallIconDesc;

  /// No description provided for @paywallAdTitle.
  ///
  /// In ja, this message translates to:
  /// **'広告が一切表示されなくなる'**
  String get paywallAdTitle;

  /// No description provided for @paywallAdDesc.
  ///
  /// In ja, this message translates to:
  /// **'中断されずにFoodGramを楽しめる'**
  String get paywallAdDesc;

  /// No description provided for @paywallComingSoon.
  ///
  /// In ja, this message translates to:
  /// **'Coming Soon...'**
  String get paywallComingSoon;

  /// No description provided for @paywallNewFeatures.
  ///
  /// In ja, this message translates to:
  /// **'プレミアム会員限定の新機能を\n随時リリース予定！'**
  String get paywallNewFeatures;

  /// No description provided for @paywallSubscribeButton.
  ///
  /// In ja, this message translates to:
  /// **'プレミアム会員になる'**
  String get paywallSubscribeButton;

  /// No description provided for @paywallPrice.
  ///
  /// In ja, this message translates to:
  /// **'月額  ￥ 300 / 月'**
  String get paywallPrice;

  /// No description provided for @paywallCancelNote.
  ///
  /// In ja, this message translates to:
  /// **'いつでも解約可能'**
  String get paywallCancelNote;

  /// No description provided for @paywallWelcomeTitle.
  ///
  /// In ja, this message translates to:
  /// **'Welcome to\nFoodGram Members!'**
  String get paywallWelcomeTitle;

  /// No description provided for @paywallSkip.
  ///
  /// In ja, this message translates to:
  /// **'スキップ'**
  String get paywallSkip;

  /// No description provided for @purchaseError.
  ///
  /// In ja, this message translates to:
  /// **'購入処理中にエラーが発生しました'**
  String get purchaseError;

  /// No description provided for @paywallTagline.
  ///
  /// In ja, this message translates to:
  /// **'✨️ あなたの食事体験をもっと豪華に ✨️'**
  String get paywallTagline;

  /// No description provided for @paywallMapTitle.
  ///
  /// In ja, this message translates to:
  /// **'衛生地図でレストランを探せる'**
  String get paywallMapTitle;

  /// No description provided for @paywallMapDesc.
  ///
  /// In ja, this message translates to:
  /// **'より快適に楽しく見つけることができる'**
  String get paywallMapDesc;

  /// No description provided for @paywallRankTitle.
  ///
  /// In ja, this message translates to:
  /// **'投稿数に応じて称号がもらえる'**
  String get paywallRankTitle;

  /// No description provided for @paywallRankDesc.
  ///
  /// In ja, this message translates to:
  /// **'投稿数が増えると称号が変わる'**
  String get paywallRankDesc;

  /// No description provided for @paywallGenreTitle.
  ///
  /// In ja, this message translates to:
  /// **'好きなジャンルを設定可能に'**
  String get paywallGenreTitle;

  /// No description provided for @paywallGenreDesc.
  ///
  /// In ja, this message translates to:
  /// **'設定してよりおしゃれなプロフィールに'**
  String get paywallGenreDesc;

  /// No description provided for @paywallCustomIconTitle.
  ///
  /// In ja, this message translates to:
  /// **'アイコンを好きな画像に変更可能'**
  String get paywallCustomIconTitle;

  /// No description provided for @paywallCustomIconDesc.
  ///
  /// In ja, this message translates to:
  /// **'他の投稿者よりも目立つようになる'**
  String get paywallCustomIconDesc;

  /// No description provided for @anonymousPost.
  ///
  /// In ja, this message translates to:
  /// **'匿名で投稿'**
  String get anonymousPost;

  /// No description provided for @anonymousPostDescription.
  ///
  /// In ja, this message translates to:
  /// **'ユーザー名が非表示になります'**
  String get anonymousPostDescription;

  /// No description provided for @anonymousShare.
  ///
  /// In ja, this message translates to:
  /// **'匿名でシェア'**
  String get anonymousShare;

  /// No description provided for @anonymousUpdate.
  ///
  /// In ja, this message translates to:
  /// **'匿名で更新'**
  String get anonymousUpdate;

  /// No description provided for @anonymousPoster.
  ///
  /// In ja, this message translates to:
  /// **'とある投稿者'**
  String get anonymousPoster;

  /// No description provided for @anonymousUsername.
  ///
  /// In ja, this message translates to:
  /// **'foodgramer'**
  String get anonymousUsername;

  /// No description provided for @tagOtherCuisine.
  ///
  /// In ja, this message translates to:
  /// **'その他の料理'**
  String get tagOtherCuisine;

  /// No description provided for @tagOtherFood.
  ///
  /// In ja, this message translates to:
  /// **'その他の食べ物'**
  String get tagOtherFood;

  /// No description provided for @tagJapaneseCuisine.
  ///
  /// In ja, this message translates to:
  /// **'日本料理'**
  String get tagJapaneseCuisine;

  /// No description provided for @tagItalianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'イタリアン料理'**
  String get tagItalianCuisine;

  /// No description provided for @tagFrenchCuisine.
  ///
  /// In ja, this message translates to:
  /// **'フレンチ料理'**
  String get tagFrenchCuisine;

  /// No description provided for @tagChineseCuisine.
  ///
  /// In ja, this message translates to:
  /// **'中華料理'**
  String get tagChineseCuisine;

  /// No description provided for @tagIndianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'インド料理'**
  String get tagIndianCuisine;

  /// No description provided for @tagMexicanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'メキシカン料理'**
  String get tagMexicanCuisine;

  /// No description provided for @tagHongKongCuisine.
  ///
  /// In ja, this message translates to:
  /// **'香港料理'**
  String get tagHongKongCuisine;

  /// No description provided for @tagAmericanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'アメリカ料理'**
  String get tagAmericanCuisine;

  /// No description provided for @tagMediterraneanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'地中海料理'**
  String get tagMediterraneanCuisine;

  /// No description provided for @tagThaiCuisine.
  ///
  /// In ja, this message translates to:
  /// **'タイ料理'**
  String get tagThaiCuisine;

  /// No description provided for @tagGreekCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ギリシャ料理'**
  String get tagGreekCuisine;

  /// No description provided for @tagTurkishCuisine.
  ///
  /// In ja, this message translates to:
  /// **'トルコ料理'**
  String get tagTurkishCuisine;

  /// No description provided for @tagKoreanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'韓国料理'**
  String get tagKoreanCuisine;

  /// No description provided for @tagRussianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ロシア料理'**
  String get tagRussianCuisine;

  /// No description provided for @tagSpanishCuisine.
  ///
  /// In ja, this message translates to:
  /// **'スペイン料理'**
  String get tagSpanishCuisine;

  /// No description provided for @tagVietnameseCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ベトナム料理'**
  String get tagVietnameseCuisine;

  /// No description provided for @tagPortugueseCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ポルトガル料理'**
  String get tagPortugueseCuisine;

  /// No description provided for @tagAustrianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'オーストリア料理'**
  String get tagAustrianCuisine;

  /// No description provided for @tagBelgianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ベルギー料理'**
  String get tagBelgianCuisine;

  /// No description provided for @tagSwedishCuisine.
  ///
  /// In ja, this message translates to:
  /// **'スウェーデン料理'**
  String get tagSwedishCuisine;

  /// No description provided for @tagGermanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ドイツ料理'**
  String get tagGermanCuisine;

  /// No description provided for @tagBritishCuisine.
  ///
  /// In ja, this message translates to:
  /// **'イギリス料理'**
  String get tagBritishCuisine;

  /// No description provided for @tagDutchCuisine.
  ///
  /// In ja, this message translates to:
  /// **'オランダ料理'**
  String get tagDutchCuisine;

  /// No description provided for @tagAustralianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'オーストラリア料理'**
  String get tagAustralianCuisine;

  /// No description provided for @tagBrazilianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ブラジル料理'**
  String get tagBrazilianCuisine;

  /// No description provided for @tagArgentineCuisine.
  ///
  /// In ja, this message translates to:
  /// **'アルゼンチン料理'**
  String get tagArgentineCuisine;

  /// No description provided for @tagColombianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'コロンビア料理'**
  String get tagColombianCuisine;

  /// No description provided for @tagPeruvianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ペルー料理'**
  String get tagPeruvianCuisine;

  /// No description provided for @tagNorwegianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ノルウェー料理'**
  String get tagNorwegianCuisine;

  /// No description provided for @tagDanishCuisine.
  ///
  /// In ja, this message translates to:
  /// **'デンマーク料理'**
  String get tagDanishCuisine;

  /// No description provided for @tagPolishCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ポーランド料理'**
  String get tagPolishCuisine;

  /// No description provided for @tagCzechCuisine.
  ///
  /// In ja, this message translates to:
  /// **'チェコ料理'**
  String get tagCzechCuisine;

  /// No description provided for @tagHungarianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ハンガリー料理'**
  String get tagHungarianCuisine;

  /// No description provided for @tagSouthAfricanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'南アフリカ料理'**
  String get tagSouthAfricanCuisine;

  /// No description provided for @tagEgyptianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'エジプト料理'**
  String get tagEgyptianCuisine;

  /// No description provided for @tagMoroccanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'モロッコ料理'**
  String get tagMoroccanCuisine;

  /// No description provided for @tagNewZealandCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ニュージーランド料理'**
  String get tagNewZealandCuisine;

  /// No description provided for @tagFilipinoCuisine.
  ///
  /// In ja, this message translates to:
  /// **'フィリピン料理'**
  String get tagFilipinoCuisine;

  /// No description provided for @tagMalaysianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'マレーシア料理'**
  String get tagMalaysianCuisine;

  /// No description provided for @tagSingaporeanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'シンガポール料理'**
  String get tagSingaporeanCuisine;

  /// No description provided for @tagIndonesianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'インドネシア料理'**
  String get tagIndonesianCuisine;

  /// No description provided for @tagIranianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'イラン料理'**
  String get tagIranianCuisine;

  /// No description provided for @tagSaudiArabianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'サウジアラビア料理'**
  String get tagSaudiArabianCuisine;

  /// No description provided for @tagMongolianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'モンゴル料理'**
  String get tagMongolianCuisine;

  /// No description provided for @tagCambodianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'カンボジア料理'**
  String get tagCambodianCuisine;

  /// No description provided for @tagLaotianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ラオス料理'**
  String get tagLaotianCuisine;

  /// No description provided for @tagCubanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'キューバ料理'**
  String get tagCubanCuisine;

  /// No description provided for @tagJamaicanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ジャマイカ料理'**
  String get tagJamaicanCuisine;

  /// No description provided for @tagChileanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'チリ料理'**
  String get tagChileanCuisine;

  /// No description provided for @tagVenezuelanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ベネズエラ料理'**
  String get tagVenezuelanCuisine;

  /// No description provided for @tagPanamanianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'パナマ料理'**
  String get tagPanamanianCuisine;

  /// No description provided for @tagBolivianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ボリビア料理'**
  String get tagBolivianCuisine;

  /// No description provided for @tagIcelandicCuisine.
  ///
  /// In ja, this message translates to:
  /// **'アイスランド料理'**
  String get tagIcelandicCuisine;

  /// No description provided for @tagLithuanianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'リトアニア料理'**
  String get tagLithuanianCuisine;

  /// No description provided for @tagEstonianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'エストニア料理'**
  String get tagEstonianCuisine;

  /// No description provided for @tagLatvianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ラトビア料理'**
  String get tagLatvianCuisine;

  /// No description provided for @tagFinnishCuisine.
  ///
  /// In ja, this message translates to:
  /// **'フィンランド料理'**
  String get tagFinnishCuisine;

  /// No description provided for @tagCroatianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'クロアチア料理'**
  String get tagCroatianCuisine;

  /// No description provided for @tagSlovenianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'スロベニア料理'**
  String get tagSlovenianCuisine;

  /// No description provided for @tagSlovakCuisine.
  ///
  /// In ja, this message translates to:
  /// **'スロバキア料理'**
  String get tagSlovakCuisine;

  /// No description provided for @tagRomanianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ルーマニア料理'**
  String get tagRomanianCuisine;

  /// No description provided for @tagBulgarianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ブルガリア料理'**
  String get tagBulgarianCuisine;

  /// No description provided for @tagSerbianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'セルビア料理'**
  String get tagSerbianCuisine;

  /// No description provided for @tagAlbanianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'アルバニア料理'**
  String get tagAlbanianCuisine;

  /// No description provided for @tagGeorgianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ジョージア料理'**
  String get tagGeorgianCuisine;

  /// No description provided for @tagArmenianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'アルメニア料理'**
  String get tagArmenianCuisine;

  /// No description provided for @tagAzerbaijaniCuisine.
  ///
  /// In ja, this message translates to:
  /// **'アゼルバイジャン料理'**
  String get tagAzerbaijaniCuisine;

  /// No description provided for @tagUkrainianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ウクライナ料理'**
  String get tagUkrainianCuisine;

  /// No description provided for @tagBelarusianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ベラルーシ料理'**
  String get tagBelarusianCuisine;

  /// No description provided for @tagKazakhCuisine.
  ///
  /// In ja, this message translates to:
  /// **'カザフスタン料理'**
  String get tagKazakhCuisine;

  /// No description provided for @tagUzbekCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ウズベキスタン料理'**
  String get tagUzbekCuisine;

  /// No description provided for @tagKyrgyzCuisine.
  ///
  /// In ja, this message translates to:
  /// **'キルギス料理'**
  String get tagKyrgyzCuisine;

  /// No description provided for @tagTurkmenCuisine.
  ///
  /// In ja, this message translates to:
  /// **'トルクメニスタン料理'**
  String get tagTurkmenCuisine;

  /// No description provided for @tagTajikCuisine.
  ///
  /// In ja, this message translates to:
  /// **'タジキスタン料理'**
  String get tagTajikCuisine;

  /// No description provided for @tagMaldivianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'モルディブ料理'**
  String get tagMaldivianCuisine;

  /// No description provided for @tagNepaleseCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ネパール料理'**
  String get tagNepaleseCuisine;

  /// No description provided for @tagBangladeshiCuisine.
  ///
  /// In ja, this message translates to:
  /// **'バングラデシュ料理'**
  String get tagBangladeshiCuisine;

  /// No description provided for @tagMyanmarCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ミャンマー料理'**
  String get tagMyanmarCuisine;

  /// No description provided for @tagBruneianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ブルネイ料理'**
  String get tagBruneianCuisine;

  /// No description provided for @tagTaiwaneseCuisine.
  ///
  /// In ja, this message translates to:
  /// **'台湾料理'**
  String get tagTaiwaneseCuisine;

  /// No description provided for @tagNigerianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ナイジェリア料理'**
  String get tagNigerianCuisine;

  /// No description provided for @tagKenyanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ケニア料理'**
  String get tagKenyanCuisine;

  /// No description provided for @tagGhanaianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ガーナ料理'**
  String get tagGhanaianCuisine;

  /// No description provided for @tagEthiopianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'エチオピア料理'**
  String get tagEthiopianCuisine;

  /// No description provided for @tagSudaneseCuisine.
  ///
  /// In ja, this message translates to:
  /// **'スーダン料理'**
  String get tagSudaneseCuisine;

  /// No description provided for @tagTunisianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'チュニジア料理'**
  String get tagTunisianCuisine;

  /// No description provided for @tagAngolanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'アンゴラ料理'**
  String get tagAngolanCuisine;

  /// No description provided for @tagCongoleseCuisine.
  ///
  /// In ja, this message translates to:
  /// **'コンゴ料理'**
  String get tagCongoleseCuisine;

  /// No description provided for @tagZimbabweanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ジンバブエ料理'**
  String get tagZimbabweanCuisine;

  /// No description provided for @tagMalagasyCuisine.
  ///
  /// In ja, this message translates to:
  /// **'マダガスカル料理'**
  String get tagMalagasyCuisine;

  /// No description provided for @tagPapuaNewGuineanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'パプアニューギニア料理'**
  String get tagPapuaNewGuineanCuisine;

  /// No description provided for @tagSamoanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'サモア料理'**
  String get tagSamoanCuisine;

  /// No description provided for @tagTuvaluanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ツバル料理'**
  String get tagTuvaluanCuisine;

  /// No description provided for @tagFijianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'フィジー料理'**
  String get tagFijianCuisine;

  /// No description provided for @tagPalauanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'パラオ料理'**
  String get tagPalauanCuisine;

  /// No description provided for @tagKiribatiCuisine.
  ///
  /// In ja, this message translates to:
  /// **'キリバス料理'**
  String get tagKiribatiCuisine;

  /// No description provided for @tagVanuatuanCuisine.
  ///
  /// In ja, this message translates to:
  /// **'バヌアツ料理'**
  String get tagVanuatuanCuisine;

  /// No description provided for @tagBahrainiCuisine.
  ///
  /// In ja, this message translates to:
  /// **'バーレーン料理'**
  String get tagBahrainiCuisine;

  /// No description provided for @tagQatariCuisine.
  ///
  /// In ja, this message translates to:
  /// **'カタール料理'**
  String get tagQatariCuisine;

  /// No description provided for @tagKuwaitiCuisine.
  ///
  /// In ja, this message translates to:
  /// **'クウェート料理'**
  String get tagKuwaitiCuisine;

  /// No description provided for @tagOmaniCuisine.
  ///
  /// In ja, this message translates to:
  /// **'オマーン料理'**
  String get tagOmaniCuisine;

  /// No description provided for @tagYemeniCuisine.
  ///
  /// In ja, this message translates to:
  /// **'イエメン料理'**
  String get tagYemeniCuisine;

  /// No description provided for @tagLebaneseCuisine.
  ///
  /// In ja, this message translates to:
  /// **'レバノン料理'**
  String get tagLebaneseCuisine;

  /// No description provided for @tagSyrianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'シリア料理'**
  String get tagSyrianCuisine;

  /// No description provided for @tagJordanianCuisine.
  ///
  /// In ja, this message translates to:
  /// **'ヨルダン料理'**
  String get tagJordanianCuisine;

  /// No description provided for @tagNoodles.
  ///
  /// In ja, this message translates to:
  /// **'麺類'**
  String get tagNoodles;

  /// No description provided for @tagMeatDishes.
  ///
  /// In ja, this message translates to:
  /// **'肉料理'**
  String get tagMeatDishes;

  /// No description provided for @tagFastFood.
  ///
  /// In ja, this message translates to:
  /// **'軽食系'**
  String get tagFastFood;

  /// No description provided for @tagRiceDishes.
  ///
  /// In ja, this message translates to:
  /// **'ご飯物'**
  String get tagRiceDishes;

  /// No description provided for @tagSeafood.
  ///
  /// In ja, this message translates to:
  /// **'魚介類'**
  String get tagSeafood;

  /// No description provided for @tagBread.
  ///
  /// In ja, this message translates to:
  /// **'パン類'**
  String get tagBread;

  /// No description provided for @tagSweetsAndSnacks.
  ///
  /// In ja, this message translates to:
  /// **'おやつ'**
  String get tagSweetsAndSnacks;

  /// No description provided for @tagFruits.
  ///
  /// In ja, this message translates to:
  /// **'フルーツ'**
  String get tagFruits;

  /// No description provided for @tagVegetables.
  ///
  /// In ja, this message translates to:
  /// **'野菜類'**
  String get tagVegetables;

  /// No description provided for @tagBeverages.
  ///
  /// In ja, this message translates to:
  /// **'ドリンク'**
  String get tagBeverages;

  /// No description provided for @tagOthers.
  ///
  /// In ja, this message translates to:
  /// **'その他'**
  String get tagOthers;

  /// No description provided for @tagPasta.
  ///
  /// In ja, this message translates to:
  /// **'パスタ'**
  String get tagPasta;

  /// No description provided for @tagRamen.
  ///
  /// In ja, this message translates to:
  /// **'ラーメン'**
  String get tagRamen;

  /// No description provided for @tagSteak.
  ///
  /// In ja, this message translates to:
  /// **'ステーキ'**
  String get tagSteak;

  /// No description provided for @tagYakiniku.
  ///
  /// In ja, this message translates to:
  /// **'焼き肉'**
  String get tagYakiniku;

  /// No description provided for @tagChicken.
  ///
  /// In ja, this message translates to:
  /// **'チキン'**
  String get tagChicken;

  /// No description provided for @tagBacon.
  ///
  /// In ja, this message translates to:
  /// **'ベーコン'**
  String get tagBacon;

  /// No description provided for @tagHamburger.
  ///
  /// In ja, this message translates to:
  /// **'ハンバーガー'**
  String get tagHamburger;

  /// No description provided for @tagFrenchFries.
  ///
  /// In ja, this message translates to:
  /// **'フライドポテト'**
  String get tagFrenchFries;

  /// No description provided for @tagPizza.
  ///
  /// In ja, this message translates to:
  /// **'ピザ'**
  String get tagPizza;

  /// No description provided for @tagTacos.
  ///
  /// In ja, this message translates to:
  /// **'タコス'**
  String get tagTacos;

  /// No description provided for @tagTamales.
  ///
  /// In ja, this message translates to:
  /// **'タマル'**
  String get tagTamales;

  /// No description provided for @tagGyoza.
  ///
  /// In ja, this message translates to:
  /// **'餃子'**
  String get tagGyoza;

  /// No description provided for @tagFriedShrimp.
  ///
  /// In ja, this message translates to:
  /// **'エビフライ'**
  String get tagFriedShrimp;

  /// No description provided for @tagHotPot.
  ///
  /// In ja, this message translates to:
  /// **'鍋'**
  String get tagHotPot;

  /// No description provided for @tagCurry.
  ///
  /// In ja, this message translates to:
  /// **'カレー'**
  String get tagCurry;

  /// No description provided for @tagPaella.
  ///
  /// In ja, this message translates to:
  /// **'パエリア'**
  String get tagPaella;

  /// No description provided for @tagFondue.
  ///
  /// In ja, this message translates to:
  /// **'フォンデュ'**
  String get tagFondue;

  /// No description provided for @tagOnigiri.
  ///
  /// In ja, this message translates to:
  /// **'おにぎり'**
  String get tagOnigiri;

  /// No description provided for @tagRice.
  ///
  /// In ja, this message translates to:
  /// **'ご飯'**
  String get tagRice;

  /// No description provided for @tagBento.
  ///
  /// In ja, this message translates to:
  /// **'弁当'**
  String get tagBento;

  /// No description provided for @tagSushi.
  ///
  /// In ja, this message translates to:
  /// **'寿司'**
  String get tagSushi;

  /// No description provided for @tagFish.
  ///
  /// In ja, this message translates to:
  /// **'魚'**
  String get tagFish;

  /// No description provided for @tagOctopus.
  ///
  /// In ja, this message translates to:
  /// **'タコ'**
  String get tagOctopus;

  /// No description provided for @tagSquid.
  ///
  /// In ja, this message translates to:
  /// **'イカ'**
  String get tagSquid;

  /// No description provided for @tagShrimp.
  ///
  /// In ja, this message translates to:
  /// **'エビ'**
  String get tagShrimp;

  /// No description provided for @tagCrab.
  ///
  /// In ja, this message translates to:
  /// **'カニ'**
  String get tagCrab;

  /// No description provided for @tagShellfish.
  ///
  /// In ja, this message translates to:
  /// **'貝'**
  String get tagShellfish;

  /// No description provided for @tagOyster.
  ///
  /// In ja, this message translates to:
  /// **'カキ'**
  String get tagOyster;

  /// No description provided for @tagSandwich.
  ///
  /// In ja, this message translates to:
  /// **'サンドイッチ'**
  String get tagSandwich;

  /// No description provided for @tagHotDog.
  ///
  /// In ja, this message translates to:
  /// **'ホットドッグ'**
  String get tagHotDog;

  /// No description provided for @tagDonut.
  ///
  /// In ja, this message translates to:
  /// **'ドーナツ'**
  String get tagDonut;

  /// No description provided for @tagPancake.
  ///
  /// In ja, this message translates to:
  /// **'パンケーキ'**
  String get tagPancake;

  /// No description provided for @tagCroissant.
  ///
  /// In ja, this message translates to:
  /// **'クロワッサン'**
  String get tagCroissant;

  /// No description provided for @tagBagel.
  ///
  /// In ja, this message translates to:
  /// **'ベーグル'**
  String get tagBagel;

  /// No description provided for @tagBaguette.
  ///
  /// In ja, this message translates to:
  /// **'バゲット'**
  String get tagBaguette;

  /// No description provided for @tagPretzel.
  ///
  /// In ja, this message translates to:
  /// **'プレッツェル'**
  String get tagPretzel;

  /// No description provided for @tagBurrito.
  ///
  /// In ja, this message translates to:
  /// **'ブリトー'**
  String get tagBurrito;

  /// No description provided for @tagIceCream.
  ///
  /// In ja, this message translates to:
  /// **'アイスクリーム'**
  String get tagIceCream;

  /// No description provided for @tagPudding.
  ///
  /// In ja, this message translates to:
  /// **'プリン'**
  String get tagPudding;

  /// No description provided for @tagRiceCracker.
  ///
  /// In ja, this message translates to:
  /// **'せんべい'**
  String get tagRiceCracker;

  /// No description provided for @tagDango.
  ///
  /// In ja, this message translates to:
  /// **'団子'**
  String get tagDango;

  /// No description provided for @tagShavedIce.
  ///
  /// In ja, this message translates to:
  /// **'かき氷'**
  String get tagShavedIce;

  /// No description provided for @tagPie.
  ///
  /// In ja, this message translates to:
  /// **'パイ'**
  String get tagPie;

  /// No description provided for @tagCupcake.
  ///
  /// In ja, this message translates to:
  /// **'カップケーキ'**
  String get tagCupcake;

  /// No description provided for @tagCake.
  ///
  /// In ja, this message translates to:
  /// **'ケーキ'**
  String get tagCake;

  /// No description provided for @tagCandy.
  ///
  /// In ja, this message translates to:
  /// **'飴'**
  String get tagCandy;

  /// No description provided for @tagLollipop.
  ///
  /// In ja, this message translates to:
  /// **'キャンディ'**
  String get tagLollipop;

  /// No description provided for @tagChocolate.
  ///
  /// In ja, this message translates to:
  /// **'チョコレート'**
  String get tagChocolate;

  /// No description provided for @tagPopcorn.
  ///
  /// In ja, this message translates to:
  /// **'ポップコーン'**
  String get tagPopcorn;

  /// No description provided for @tagCookie.
  ///
  /// In ja, this message translates to:
  /// **'クッキー'**
  String get tagCookie;

  /// No description provided for @tagPeanuts.
  ///
  /// In ja, this message translates to:
  /// **'ピーナッツ'**
  String get tagPeanuts;

  /// No description provided for @tagBeans.
  ///
  /// In ja, this message translates to:
  /// **'豆'**
  String get tagBeans;

  /// No description provided for @tagChestnut.
  ///
  /// In ja, this message translates to:
  /// **'栗'**
  String get tagChestnut;

  /// No description provided for @tagFortuneCookie.
  ///
  /// In ja, this message translates to:
  /// **'フォーチュンクッキー'**
  String get tagFortuneCookie;

  /// No description provided for @tagMooncake.
  ///
  /// In ja, this message translates to:
  /// **'月餅'**
  String get tagMooncake;

  /// No description provided for @tagHoney.
  ///
  /// In ja, this message translates to:
  /// **'はちみつ'**
  String get tagHoney;

  /// No description provided for @tagWaffle.
  ///
  /// In ja, this message translates to:
  /// **'ワッフル'**
  String get tagWaffle;

  /// No description provided for @tagApple.
  ///
  /// In ja, this message translates to:
  /// **'りんご'**
  String get tagApple;

  /// No description provided for @tagPear.
  ///
  /// In ja, this message translates to:
  /// **'梨'**
  String get tagPear;

  /// No description provided for @tagOrange.
  ///
  /// In ja, this message translates to:
  /// **'みかん'**
  String get tagOrange;

  /// No description provided for @tagLemon.
  ///
  /// In ja, this message translates to:
  /// **'レモン'**
  String get tagLemon;

  /// No description provided for @tagLime.
  ///
  /// In ja, this message translates to:
  /// **'ライム'**
  String get tagLime;

  /// No description provided for @tagBanana.
  ///
  /// In ja, this message translates to:
  /// **'バナナ'**
  String get tagBanana;

  /// No description provided for @tagWatermelon.
  ///
  /// In ja, this message translates to:
  /// **'スイカ'**
  String get tagWatermelon;

  /// No description provided for @tagGrapes.
  ///
  /// In ja, this message translates to:
  /// **'ぶどう'**
  String get tagGrapes;

  /// No description provided for @tagStrawberry.
  ///
  /// In ja, this message translates to:
  /// **'いちご'**
  String get tagStrawberry;

  /// No description provided for @tagBlueberry.
  ///
  /// In ja, this message translates to:
  /// **'ブルーベリー'**
  String get tagBlueberry;

  /// No description provided for @tagMelon.
  ///
  /// In ja, this message translates to:
  /// **'メロン'**
  String get tagMelon;

  /// No description provided for @tagCherry.
  ///
  /// In ja, this message translates to:
  /// **'さくらんぼ'**
  String get tagCherry;

  /// No description provided for @tagPeach.
  ///
  /// In ja, this message translates to:
  /// **'もも'**
  String get tagPeach;

  /// No description provided for @tagMango.
  ///
  /// In ja, this message translates to:
  /// **'マンゴー'**
  String get tagMango;

  /// No description provided for @tagPineapple.
  ///
  /// In ja, this message translates to:
  /// **'パイナップル'**
  String get tagPineapple;

  /// No description provided for @tagCoconut.
  ///
  /// In ja, this message translates to:
  /// **'ココナッツ'**
  String get tagCoconut;

  /// No description provided for @tagKiwi.
  ///
  /// In ja, this message translates to:
  /// **'キウイ'**
  String get tagKiwi;

  /// No description provided for @tagSalad.
  ///
  /// In ja, this message translates to:
  /// **'サラダ'**
  String get tagSalad;

  /// No description provided for @tagTomato.
  ///
  /// In ja, this message translates to:
  /// **'トマト'**
  String get tagTomato;

  /// No description provided for @tagEggplant.
  ///
  /// In ja, this message translates to:
  /// **'なす'**
  String get tagEggplant;

  /// No description provided for @tagAvocado.
  ///
  /// In ja, this message translates to:
  /// **'アボカド'**
  String get tagAvocado;

  /// No description provided for @tagGreenBeans.
  ///
  /// In ja, this message translates to:
  /// **'さやいんげん'**
  String get tagGreenBeans;

  /// No description provided for @tagBroccoli.
  ///
  /// In ja, this message translates to:
  /// **'ブロッコリー'**
  String get tagBroccoli;

  /// No description provided for @tagLettuce.
  ///
  /// In ja, this message translates to:
  /// **'レタス'**
  String get tagLettuce;

  /// No description provided for @tagCucumber.
  ///
  /// In ja, this message translates to:
  /// **'きゅうり'**
  String get tagCucumber;

  /// No description provided for @tagChili.
  ///
  /// In ja, this message translates to:
  /// **'唐辛子'**
  String get tagChili;

  /// No description provided for @tagBellPepper.
  ///
  /// In ja, this message translates to:
  /// **'ピーマン'**
  String get tagBellPepper;

  /// No description provided for @tagCorn.
  ///
  /// In ja, this message translates to:
  /// **'とうもろこし'**
  String get tagCorn;

  /// No description provided for @tagCarrot.
  ///
  /// In ja, this message translates to:
  /// **'にんじん'**
  String get tagCarrot;

  /// No description provided for @tagOlive.
  ///
  /// In ja, this message translates to:
  /// **'オリーブ'**
  String get tagOlive;

  /// No description provided for @tagGarlic.
  ///
  /// In ja, this message translates to:
  /// **'にんにく'**
  String get tagGarlic;

  /// No description provided for @tagOnion.
  ///
  /// In ja, this message translates to:
  /// **'玉ねぎ'**
  String get tagOnion;

  /// No description provided for @tagPotato.
  ///
  /// In ja, this message translates to:
  /// **'じゃがいも'**
  String get tagPotato;

  /// No description provided for @tagSweetPotato.
  ///
  /// In ja, this message translates to:
  /// **'さつまいも'**
  String get tagSweetPotato;

  /// No description provided for @tagGinger.
  ///
  /// In ja, this message translates to:
  /// **'しょうが'**
  String get tagGinger;

  /// No description provided for @tagShiitake.
  ///
  /// In ja, this message translates to:
  /// **'しいたけ'**
  String get tagShiitake;

  /// No description provided for @tagTeapot.
  ///
  /// In ja, this message translates to:
  /// **'ティーポット'**
  String get tagTeapot;

  /// No description provided for @tagCoffee.
  ///
  /// In ja, this message translates to:
  /// **'コーヒー'**
  String get tagCoffee;

  /// No description provided for @tagTea.
  ///
  /// In ja, this message translates to:
  /// **'お茶'**
  String get tagTea;

  /// No description provided for @tagJuice.
  ///
  /// In ja, this message translates to:
  /// **'ジュース'**
  String get tagJuice;

  /// No description provided for @tagSoftDrink.
  ///
  /// In ja, this message translates to:
  /// **'ソフトドリンク'**
  String get tagSoftDrink;

  /// No description provided for @tagBubbleTea.
  ///
  /// In ja, this message translates to:
  /// **'タピオカティー'**
  String get tagBubbleTea;

  /// No description provided for @tagSake.
  ///
  /// In ja, this message translates to:
  /// **'日本酒'**
  String get tagSake;

  /// No description provided for @tagBeer.
  ///
  /// In ja, this message translates to:
  /// **'ビール'**
  String get tagBeer;

  /// No description provided for @tagChampagne.
  ///
  /// In ja, this message translates to:
  /// **'シャンパン'**
  String get tagChampagne;

  /// No description provided for @tagWine.
  ///
  /// In ja, this message translates to:
  /// **'ワイン'**
  String get tagWine;

  /// No description provided for @tagWhiskey.
  ///
  /// In ja, this message translates to:
  /// **'ウィスキー'**
  String get tagWhiskey;

  /// No description provided for @tagCocktail.
  ///
  /// In ja, this message translates to:
  /// **'カクテル'**
  String get tagCocktail;

  /// No description provided for @tagTropicalCocktail.
  ///
  /// In ja, this message translates to:
  /// **'トロピカルカクテル'**
  String get tagTropicalCocktail;

  /// No description provided for @tagMateTea.
  ///
  /// In ja, this message translates to:
  /// **'マテ茶'**
  String get tagMateTea;

  /// No description provided for @tagMilk.
  ///
  /// In ja, this message translates to:
  /// **'ミルク'**
  String get tagMilk;

  /// No description provided for @tagKamaboko.
  ///
  /// In ja, this message translates to:
  /// **'かまぼこ'**
  String get tagKamaboko;

  /// No description provided for @tagOden.
  ///
  /// In ja, this message translates to:
  /// **'おでん'**
  String get tagOden;

  /// No description provided for @tagCheese.
  ///
  /// In ja, this message translates to:
  /// **'チーズ'**
  String get tagCheese;

  /// No description provided for @tagEgg.
  ///
  /// In ja, this message translates to:
  /// **'卵'**
  String get tagEgg;

  /// No description provided for @tagFriedEgg.
  ///
  /// In ja, this message translates to:
  /// **'目玉焼き'**
  String get tagFriedEgg;

  /// No description provided for @tagButter.
  ///
  /// In ja, this message translates to:
  /// **'バター'**
  String get tagButter;

  /// No description provided for @done.
  ///
  /// In ja, this message translates to:
  /// **'決定'**
  String get done;

  /// No description provided for @save.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @searchFood.
  ///
  /// In ja, this message translates to:
  /// **'料理を検索'**
  String get searchFood;

  /// No description provided for @noResultsFound.
  ///
  /// In ja, this message translates to:
  /// **'検索結果が見つかりませんでした'**
  String get noResultsFound;

  /// No description provided for @searchCountry.
  ///
  /// In ja, this message translates to:
  /// **'国を検索'**
  String get searchCountry;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In ja, this message translates to:
  /// **'店舗名を入力して検索してください'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptyHintTitle.
  ///
  /// In ja, this message translates to:
  /// **'検索のヒント'**
  String get searchEmptyHintTitle;

  /// No description provided for @searchEmptyHintLocation.
  ///
  /// In ja, this message translates to:
  /// **'位置情報をオンにすると近い順で表示します'**
  String get searchEmptyHintLocation;

  /// No description provided for @searchEmptyHintSearch.
  ///
  /// In ja, this message translates to:
  /// **'店舗名や料理ジャンルで検索できます'**
  String get searchEmptyHintSearch;

  /// No description provided for @postErrorPickImage.
  ///
  /// In ja, this message translates to:
  /// **'写真ができませんでした'**
  String get postErrorPickImage;

  /// No description provided for @favoritePostEmptyTitle.
  ///
  /// In ja, this message translates to:
  /// **'保存した投稿がありません'**
  String get favoritePostEmptyTitle;

  /// No description provided for @favoritePostEmptySubtitle.
  ///
  /// In ja, this message translates to:
  /// **'気になった投稿を保存してみましょう!'**
  String get favoritePostEmptySubtitle;

  /// No description provided for @userInfoFetchError.
  ///
  /// In ja, this message translates to:
  /// **'ユーザー情報の取得に失敗しました'**
  String get userInfoFetchError;

  /// No description provided for @saved.
  ///
  /// In ja, this message translates to:
  /// **'保存済み'**
  String get saved;

  /// No description provided for @savedPosts.
  ///
  /// In ja, this message translates to:
  /// **'保存した投稿'**
  String get savedPosts;

  /// No description provided for @postSaved.
  ///
  /// In ja, this message translates to:
  /// **'投稿を保存しました'**
  String get postSaved;

  /// No description provided for @postSavedMessage.
  ///
  /// In ja, this message translates to:
  /// **'マイページにて保存した投稿が確認できます'**
  String get postSavedMessage;

  /// No description provided for @noMapAppAvailable.
  ///
  /// In ja, this message translates to:
  /// **'マップアプリが利用できません'**
  String get noMapAppAvailable;

  /// No description provided for @notificationLunchTitle.
  ///
  /// In ja, this message translates to:
  /// **'#今日のごはん、もう投稿した？🍜'**
  String get notificationLunchTitle;

  /// No description provided for @notificationLunchBody.
  ///
  /// In ja, this message translates to:
  /// **'今日のランチ、思い出せるうちに記録しませんか？'**
  String get notificationLunchBody;

  /// No description provided for @notificationDinnerTitle.
  ///
  /// In ja, this message translates to:
  /// **'#今日のごはん、もう投稿した？🍛'**
  String get notificationDinnerTitle;

  /// No description provided for @notificationDinnerBody.
  ///
  /// In ja, this message translates to:
  /// **'今日のごはん、投稿して1日をゆるっと締めくくろう📷'**
  String get notificationDinnerBody;

  /// No description provided for @posted.
  ///
  /// In ja, this message translates to:
  /// **'に投稿'**
  String get posted;

  /// No description provided for @tutorialLocationTitle.
  ///
  /// In ja, this message translates to:
  /// **'位置情報をオンにしよう！'**
  String get tutorialLocationTitle;

  /// No description provided for @tutorialLocationSubTitle.
  ///
  /// In ja, this message translates to:
  /// **'近くのおいしいお店を見つけるために、\n美味しいレストランを探しやすくするために'**
  String get tutorialLocationSubTitle;

  /// No description provided for @tutorialLocationButton.
  ///
  /// In ja, this message translates to:
  /// **'位置情報をオンにする'**
  String get tutorialLocationButton;

  /// No description provided for @tutorialNotificationTitle.
  ///
  /// In ja, this message translates to:
  /// **'通知をオンにしよう！'**
  String get tutorialNotificationTitle;

  /// No description provided for @tutorialNotificationSubTitle.
  ///
  /// In ja, this message translates to:
  /// **'ランチとディナーのときに\n通知をお送りします'**
  String get tutorialNotificationSubTitle;

  /// No description provided for @tutorialNotificationButton.
  ///
  /// In ja, this message translates to:
  /// **'通知をオンにする'**
  String get tutorialNotificationButton;

  /// No description provided for @selectMapApp.
  ///
  /// In ja, this message translates to:
  /// **'地図アプリを選択'**
  String get selectMapApp;

  /// No description provided for @mapAppGoogle.
  ///
  /// In ja, this message translates to:
  /// **'Google Map'**
  String get mapAppGoogle;

  /// No description provided for @mapAppApple.
  ///
  /// In ja, this message translates to:
  /// **'Apple Map'**
  String get mapAppApple;

  /// No description provided for @mapAppBaidu.
  ///
  /// In ja, this message translates to:
  /// **'Baidu Map'**
  String get mapAppBaidu;

  /// No description provided for @mapAppMapsMe.
  ///
  /// In ja, this message translates to:
  /// **'Maps.me'**
  String get mapAppMapsMe;

  /// No description provided for @mapAppKakao.
  ///
  /// In ja, this message translates to:
  /// **'KakaoMap'**
  String get mapAppKakao;

  /// No description provided for @mapAppNaver.
  ///
  /// In ja, this message translates to:
  /// **'Naver Map'**
  String get mapAppNaver;

  /// No description provided for @streakDialogFirstTitle.
  ///
  /// In ja, this message translates to:
  /// **'投稿が完了しました'**
  String get streakDialogFirstTitle;

  /// No description provided for @streakDialogFirstContent.
  ///
  /// In ja, this message translates to:
  /// **'継続投稿すると\n記録が残ります!'**
  String get streakDialogFirstContent;

  /// No description provided for @streakDialogContinueTitle.
  ///
  /// In ja, this message translates to:
  /// **'投稿が完了しました'**
  String get streakDialogContinueTitle;

  /// No description provided for @streakDialogContinueContent.
  ///
  /// In ja, this message translates to:
  /// **'{weeks}週間連続で投稿できました！\n継続して投稿していこう!'**
  String streakDialogContinueContent(int weeks);

  /// No description provided for @translatableTranslate.
  ///
  /// In ja, this message translates to:
  /// **'翻訳する'**
  String get translatableTranslate;

  /// No description provided for @translatableShowOriginal.
  ///
  /// In ja, this message translates to:
  /// **'原文を表示'**
  String get translatableShowOriginal;

  /// No description provided for @translatableCopy.
  ///
  /// In ja, this message translates to:
  /// **'コピー'**
  String get translatableCopy;

  /// No description provided for @translatableCopied.
  ///
  /// In ja, this message translates to:
  /// **'コピーしました'**
  String get translatableCopied;

  /// No description provided for @translatableTranslateFailed.
  ///
  /// In ja, this message translates to:
  /// **'翻訳できませんでした'**
  String get translatableTranslateFailed;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'ja',
        'ko',
        'pt',
        'th',
        'vi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return L10nZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return L10nDe();
    case 'en':
      return L10nEn();
    case 'es':
      return L10nEs();
    case 'fr':
      return L10nFr();
    case 'ja':
      return L10nJa();
    case 'ko':
      return L10nKo();
    case 'pt':
      return L10nPt();
    case 'th':
      return L10nTh();
    case 'vi':
      return L10nVi();
    case 'zh':
      return L10nZh();
  }

  throw FlutterError(
      'L10n.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
