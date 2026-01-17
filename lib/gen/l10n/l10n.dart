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
    Locale('en'),
    Locale('ja'),
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

  /// No description provided for @maybeNotFoodDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Just a quick check 🍽️'**
  String get maybeNotFoodDialogTitle;

  /// No description provided for @maybeNotFoodDialogText.
  ///
  /// In en, this message translates to:
  /// **'This photo might not be food… 🤔\n\nDo you want to post it anyway?'**
  String get maybeNotFoodDialogText;

  /// No description provided for @maybeNotFoodDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get maybeNotFoodDialogConfirm;

  /// No description provided for @maybeNotFoodDialogDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete image'**
  String get maybeNotFoodDialogDelete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editTitle;

  /// No description provided for @editPostButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get editPostButton;

  /// No description provided for @emailInputField.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get emailInputField;

  /// No description provided for @settingIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get settingIcon;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get userName;

  /// No description provided for @userNameInputField.
  ///
  /// In en, this message translates to:
  /// **'Username (e.g., iseryu)'**
  String get userNameInputField;

  /// No description provided for @userId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// No description provided for @userIdInputField.
  ///
  /// In en, this message translates to:
  /// **'User ID (e.g., iseryuuu)'**
  String get userIdInputField;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @settingAppBar.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingAppBar;

  /// No description provided for @settingCheckVersion.
  ///
  /// In en, this message translates to:
  /// **'Check version'**
  String get settingCheckVersion;

  /// No description provided for @settingCheckVersionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Information'**
  String get settingCheckVersionDialogTitle;

  /// No description provided for @settingCheckVersionDialogText1.
  ///
  /// In en, this message translates to:
  /// **'A newer version is available.'**
  String get settingCheckVersionDialogText1;

  /// No description provided for @settingCheckVersionDialogText2.
  ///
  /// In en, this message translates to:
  /// **'Please update to the latest version.'**
  String get settingCheckVersionDialogText2;

  /// No description provided for @settingDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Twitter'**
  String get settingDeveloper;

  /// No description provided for @settingGithub.
  ///
  /// In en, this message translates to:
  /// **'Github'**
  String get settingGithub;

  /// No description provided for @settingReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get settingReview;

  /// No description provided for @settingShareApp.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get settingShareApp;

  /// No description provided for @settingLicense.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get settingLicense;

  /// No description provided for @settingFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get settingFaq;

  /// No description provided for @settingPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingPrivacyPolicy;

  /// No description provided for @settingTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get settingTermsOfUse;

  /// No description provided for @settingContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get settingContact;

  /// No description provided for @settingTutorial.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get settingTutorial;

  /// No description provided for @settingCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get settingCredit;

  /// No description provided for @unregistered.
  ///
  /// In en, this message translates to:
  /// **'Unregistered'**
  String get unregistered;

  /// No description provided for @settingBatteryLevel.
  ///
  /// In en, this message translates to:
  /// **'Battery Level'**
  String get settingBatteryLevel;

  /// No description provided for @settingDeviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Device Info'**
  String get settingDeviceInfo;

  /// No description provided for @settingIosVersion.
  ///
  /// In en, this message translates to:
  /// **'iOS Version'**
  String get settingIosVersion;

  /// No description provided for @settingAndroidSdk.
  ///
  /// In en, this message translates to:
  /// **'SDK'**
  String get settingAndroidSdk;

  /// No description provided for @settingAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settingAppVersion;

  /// No description provided for @settingAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingAccount;

  /// No description provided for @settingLogoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingLogoutButton;

  /// No description provided for @settingDeleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Request Deletion'**
  String get settingDeleteAccountButton;

  /// No description provided for @settingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question Box'**
  String get settingQuestion;

  /// No description provided for @settingAccountManagement.
  ///
  /// In en, this message translates to:
  /// **'Account Management'**
  String get settingAccountManagement;

  /// No description provided for @settingRestoreSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore successful'**
  String get settingRestoreSuccessTitle;

  /// No description provided for @settingRestoreSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Premium features enabled!'**
  String get settingRestoreSuccessSubtitle;

  /// No description provided for @settingRestoreFailureTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get settingRestoreFailureTitle;

  /// No description provided for @settingRestoreFailureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No purchase history? Contact support'**
  String get settingRestoreFailureSubtitle;

  /// No description provided for @settingRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get settingRestore;

  /// No description provided for @settingPremiumMembership.
  ///
  /// In en, this message translates to:
  /// **'Become Premium Member Ship'**
  String get settingPremiumMembership;

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;

  /// No description provided for @postFoodName.
  ///
  /// In en, this message translates to:
  /// **'Food Name'**
  String get postFoodName;

  /// No description provided for @postFoodNameInputField.
  ///
  /// In en, this message translates to:
  /// **'Enter food name(Required)'**
  String get postFoodNameInputField;

  /// No description provided for @postRestaurantNameInputField.
  ///
  /// In en, this message translates to:
  /// **'Add restaurant(Required)'**
  String get postRestaurantNameInputField;

  /// No description provided for @postComment.
  ///
  /// In en, this message translates to:
  /// **'Enter Comment(Optional)'**
  String get postComment;

  /// No description provided for @postCommentInputField.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get postCommentInputField;

  /// No description provided for @postRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get postRatingLabel;

  /// No description provided for @postError.
  ///
  /// In en, this message translates to:
  /// **'Submission failure'**
  String get postError;

  /// No description provided for @postCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Select cuisine tag (optional)'**
  String get postCategoryTitle;

  /// No description provided for @postCountryCategory.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get postCountryCategory;

  /// No description provided for @postCuisineCategory.
  ///
  /// In en, this message translates to:
  /// **'Cuisine'**
  String get postCuisineCategory;

  /// No description provided for @postTitle.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postTitle;

  /// No description provided for @postMissingInfo.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get postMissingInfo;

  /// No description provided for @postMissingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Please add a photo'**
  String get postMissingPhoto;

  /// No description provided for @postMissingFoodName.
  ///
  /// In en, this message translates to:
  /// **'Please enter what you ate'**
  String get postMissingFoodName;

  /// No description provided for @postMissingRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Please add restaurant name'**
  String get postMissingRestaurant;

  /// No description provided for @postPhotoSuccess.
  ///
  /// In en, this message translates to:
  /// **'Photo added successfully'**
  String get postPhotoSuccess;

  /// No description provided for @postCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required'**
  String get postCameraPermission;

  /// No description provided for @postAlbumPermission.
  ///
  /// In en, this message translates to:
  /// **'Photo library permission is required'**
  String get postAlbumPermission;

  /// No description provided for @postSuccess.
  ///
  /// In en, this message translates to:
  /// **'Post successful'**
  String get postSuccess;

  /// No description provided for @postSearchError.
  ///
  /// In en, this message translates to:
  /// **'Unable to search for place names'**
  String get postSearchError;

  /// No description provided for @editUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get editUpdateButton;

  /// No description provided for @editBio.
  ///
  /// In en, this message translates to:
  /// **'Bio (optional)'**
  String get editBio;

  /// No description provided for @editBioInputField.
  ///
  /// In en, this message translates to:
  /// **'Enter bio'**
  String get editBioInputField;

  /// No description provided for @editFavoriteTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Favorite Tag'**
  String get editFavoriteTagTitle;

  /// No description provided for @emptyPosts.
  ///
  /// In en, this message translates to:
  /// **'There are no posts'**
  String get emptyPosts;

  /// No description provided for @searchEmptyResult.
  ///
  /// In en, this message translates to:
  /// **'No results found for your search.'**
  String get searchEmptyResult;

  /// No description provided for @searchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButton;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchRestaurantTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Restaurants'**
  String get searchRestaurantTitle;

  /// No description provided for @searchUserTitle.
  ///
  /// In en, this message translates to:
  /// **'User Search'**
  String get searchUserTitle;

  /// No description provided for @searchUserHeader.
  ///
  /// In en, this message translates to:
  /// **'User Search (by Post Count)'**
  String get searchUserHeader;

  /// No description provided for @searchUserPostCount.
  ///
  /// In en, this message translates to:
  /// **'Posts: {count}'**
  String searchUserPostCount(Object count);

  /// No description provided for @searchUserLatestPosts.
  ///
  /// In en, this message translates to:
  /// **'Latest Posts'**
  String get searchUserLatestPosts;

  /// No description provided for @searchUserNoUsers.
  ///
  /// In en, this message translates to:
  /// **'No users with posts found'**
  String get searchUserNoUsers;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown・No Hits'**
  String get unknown;

  /// No description provided for @profilePostCount.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get profilePostCount;

  /// No description provided for @profilePointCount.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get profilePointCount;

  /// No description provided for @profileEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditButton;

  /// No description provided for @profileExchangePointsButton.
  ///
  /// In en, this message translates to:
  /// **'Exchange Points'**
  String get profileExchangePointsButton;

  /// No description provided for @profileFavoriteGenre.
  ///
  /// In en, this message translates to:
  /// **'Favorite Genre'**
  String get profileFavoriteGenre;

  /// No description provided for @likeButton.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get likeButton;

  /// No description provided for @shareReviewPrefix.
  ///
  /// In en, this message translates to:
  /// **'Just shared my review of what I ate!'**
  String get shareReviewPrefix;

  /// No description provided for @shareReviewSuffix.
  ///
  /// In en, this message translates to:
  /// **'For more, take a look at foodGram!'**
  String get shareReviewSuffix;

  /// No description provided for @postDetailSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'About this post'**
  String get postDetailSheetTitle;

  /// No description provided for @postDetailSheetShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share this post'**
  String get postDetailSheetShareButton;

  /// No description provided for @postDetailSheetReportButton.
  ///
  /// In en, this message translates to:
  /// **'Report this post'**
  String get postDetailSheetReportButton;

  /// No description provided for @postDetailSheetBlockButton.
  ///
  /// In en, this message translates to:
  /// **'Block this user'**
  String get postDetailSheetBlockButton;

  /// No description provided for @dialogYesButton.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get dialogYesButton;

  /// No description provided for @dialogNoButton.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get dialogNoButton;

  /// No description provided for @dialogReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a Post'**
  String get dialogReportTitle;

  /// No description provided for @dialogReportDescription1.
  ///
  /// In en, this message translates to:
  /// **'You will report this post.'**
  String get dialogReportDescription1;

  /// No description provided for @dialogReportDescription2.
  ///
  /// In en, this message translates to:
  /// **'You will proceed to a Google Form.'**
  String get dialogReportDescription2;

  /// No description provided for @dialogBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block Confirmation'**
  String get dialogBlockTitle;

  /// No description provided for @dialogBlockDescription1.
  ///
  /// In en, this message translates to:
  /// **'Do you want to block this user?'**
  String get dialogBlockDescription1;

  /// No description provided for @dialogBlockDescription2.
  ///
  /// In en, this message translates to:
  /// **'This will hide the user\'s posts.'**
  String get dialogBlockDescription2;

  /// No description provided for @dialogBlockDescription3.
  ///
  /// In en, this message translates to:
  /// **'Blocked users will be saved locally.'**
  String get dialogBlockDescription3;

  /// No description provided for @dialogDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get dialogDeleteTitle;

  /// No description provided for @heartLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached today\'s limit of 10 likes. Please try again tomorrow.'**
  String get heartLimitMessage;

  /// No description provided for @dialogDeleteDescription1.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this post?'**
  String get dialogDeleteDescription1;

  /// No description provided for @dialogDeleteDescription2.
  ///
  /// In en, this message translates to:
  /// **'Once deleted, it cannot be restored.'**
  String get dialogDeleteDescription2;

  /// No description provided for @dialogDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Deletion failed.'**
  String get dialogDeleteError;

  /// No description provided for @dialogLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get dialogLogoutTitle;

  /// No description provided for @dialogLogoutDescription1.
  ///
  /// In en, this message translates to:
  /// **'Would you like to log out?'**
  String get dialogLogoutDescription1;

  /// No description provided for @dialogLogoutDescription2.
  ///
  /// In en, this message translates to:
  /// **'Account status is stored on the server.'**
  String get dialogLogoutDescription2;

  /// No description provided for @dialogLogoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get dialogLogoutButton;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Communication Error'**
  String get errorTitle;

  /// No description provided for @errorDescription1.
  ///
  /// In en, this message translates to:
  /// **'A connection error has occurred.'**
  String get errorDescription1;

  /// No description provided for @errorDescription2.
  ///
  /// In en, this message translates to:
  /// **'Check your network connection and try again.'**
  String get errorDescription2;

  /// No description provided for @errorRefreshButton.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get errorRefreshButton;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Errors have occurred'**
  String get error;

  /// No description provided for @mapLoadingError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get mapLoadingError;

  /// No description provided for @mapLoadingRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Getting restaurant information...'**
  String get mapLoadingRestaurant;

  /// No description provided for @mapVisibleAreaMeals.
  ///
  /// In en, this message translates to:
  /// **'📍 This area has {count} meals'**
  String mapVisibleAreaMeals(int count);

  /// No description provided for @mapVisibleAreaLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get mapVisibleAreaLoading;

  /// No description provided for @appShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get appShareTitle;

  /// No description provided for @appShareStoreButton.
  ///
  /// In en, this message translates to:
  /// **'Share this store'**
  String get appShareStoreButton;

  /// No description provided for @appShareInstagramButton.
  ///
  /// In en, this message translates to:
  /// **'Share on Instagram'**
  String get appShareInstagramButton;

  /// No description provided for @appShareGoButton.
  ///
  /// In en, this message translates to:
  /// **'Go to this store'**
  String get appShareGoButton;

  /// No description provided for @appShareCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get appShareCloseButton;

  /// No description provided for @shareInviteMessage.
  ///
  /// In en, this message translates to:
  /// **'Share delicious food on FoodGram!'**
  String get shareInviteMessage;

  /// No description provided for @appRestaurantLabel.
  ///
  /// In en, this message translates to:
  /// **'Search Restaurant'**
  String get appRestaurantLabel;

  /// No description provided for @appRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on Location!'**
  String get appRequestTitle;

  /// No description provided for @appRequestReason.
  ///
  /// In en, this message translates to:
  /// **'To find great places nearby,\nmake restaurant discovery easier'**
  String get appRequestReason;

  /// No description provided for @appRequestInduction.
  ///
  /// In en, this message translates to:
  /// **'The following buttons take you to the settings screen'**
  String get appRequestInduction;

  /// No description provided for @appRequestOpenSetting.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get appRequestOpenSetting;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FoodGram'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Eat × Snap × Share'**
  String get appSubtitle;

  /// No description provided for @agreeToTheTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms of Use'**
  String get agreeToTheTermsOfUse;

  /// No description provided for @restaurantCategoryList.
  ///
  /// In en, this message translates to:
  /// **'Select a Cuisine by Country'**
  String get restaurantCategoryList;

  /// No description provided for @cookingCategoryList.
  ///
  /// In en, this message translates to:
  /// **'Select a food tag'**
  String get cookingCategoryList;

  /// No description provided for @restaurantReviewNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get restaurantReviewNew;

  /// No description provided for @restaurantReviewViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get restaurantReviewViewDetails;

  /// No description provided for @restaurantReviewOtherPosts.
  ///
  /// In en, this message translates to:
  /// **'Other Posts'**
  String get restaurantReviewOtherPosts;

  /// No description provided for @restaurantReviewReviewList.
  ///
  /// In en, this message translates to:
  /// **'Review List'**
  String get restaurantReviewReviewList;

  /// No description provided for @restaurantReviewError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get restaurantReviewError;

  /// No description provided for @nearbyRestaurants.
  ///
  /// In en, this message translates to:
  /// **'📍Nearby Restaurants'**
  String get nearbyRestaurants;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @selectCountryTag.
  ///
  /// In en, this message translates to:
  /// **'Select a Country Tag'**
  String get selectCountryTag;

  /// No description provided for @selectFavoriteTag.
  ///
  /// In en, this message translates to:
  /// **'Select Favorite Tag'**
  String get selectFavoriteTag;

  /// No description provided for @favoriteTagPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select your favorite tag'**
  String get favoriteTagPlaceholder;

  /// No description provided for @selectFoodTag.
  ///
  /// In en, this message translates to:
  /// **'Select Food Tag'**
  String get selectFoodTag;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get tabHome;

  /// No description provided for @tabMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get tabMap;

  /// No description provided for @tabMyMap.
  ///
  /// In en, this message translates to:
  /// **'My Map'**
  String get tabMyMap;

  /// No description provided for @tabSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tabSearch;

  /// No description provided for @tabMyPage.
  ///
  /// In en, this message translates to:
  /// **'My Page'**
  String get tabMyPage;

  /// No description provided for @tabSetting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get tabSetting;

  /// No description provided for @mapStatsVisitedArea.
  ///
  /// In en, this message translates to:
  /// **'Areas'**
  String get mapStatsVisitedArea;

  /// No description provided for @mapStatsPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get mapStatsPosts;

  /// No description provided for @mapStatsActivityDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get mapStatsActivityDays;

  /// No description provided for @dayUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get dayUnit;

  /// No description provided for @mapStatsPrefectures.
  ///
  /// In en, this message translates to:
  /// **'Prefectures'**
  String get mapStatsPrefectures;

  /// No description provided for @mapStatsAchievementRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get mapStatsAchievementRate;

  /// No description provided for @mapStatsVisitedCountries.
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get mapStatsVisitedCountries;

  /// No description provided for @mapViewTypeRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get mapViewTypeRecord;

  /// No description provided for @mapViewTypeJapan.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get mapViewTypeJapan;

  /// No description provided for @mapViewTypeWorld.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get mapViewTypeWorld;

  /// No description provided for @logoutFailure.
  ///
  /// In en, this message translates to:
  /// **'Logout failure'**
  String get logoutFailure;

  /// No description provided for @accountDeletionFailure.
  ///
  /// In en, this message translates to:
  /// **'Account deletion failure'**
  String get accountDeletionFailure;

  /// No description provided for @appleLoginFailure.
  ///
  /// In en, this message translates to:
  /// **'Apple login not available'**
  String get appleLoginFailure;

  /// No description provided for @emailAuthenticationFailure.
  ///
  /// In en, this message translates to:
  /// **'Email authentication failure'**
  String get emailAuthenticationFailure;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login Error'**
  String get loginError;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Successful login'**
  String get loginSuccessful;

  /// No description provided for @emailAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Authenticate with your email application'**
  String get emailAuthentication;

  /// No description provided for @emailEmpty.
  ///
  /// In en, this message translates to:
  /// **'No email address has been entered'**
  String get emailEmpty;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @enterTheCorrectFormat.
  ///
  /// In en, this message translates to:
  /// **'Please enter the correct format'**
  String get enterTheCorrectFormat;

  /// No description provided for @authInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Email address format is incorrect.'**
  String get authInvalidFormat;

  /// No description provided for @authSocketException.
  ///
  /// In en, this message translates to:
  /// **'There is a problem with the network. Please check the connection.'**
  String get authSocketException;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @album.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get album;

  /// No description provided for @snsLogin.
  ///
  /// In en, this message translates to:
  /// **'SNS login'**
  String get snsLogin;

  /// No description provided for @tutorialFirstPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your delicious moments'**
  String get tutorialFirstPageTitle;

  /// No description provided for @tutorialFirstPageSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Make every meal special with FoodGram.\nEnjoy discovering new flavors!'**
  String get tutorialFirstPageSubTitle;

  /// No description provided for @tutorialDiscoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your next favorite dish!'**
  String get tutorialDiscoverTitle;

  /// No description provided for @tutorialDiscoverSubTitle.
  ///
  /// In en, this message translates to:
  /// **'With every scroll, new tasty finds.\nExplore delicious food now.'**
  String get tutorialDiscoverSubTitle;

  /// No description provided for @tutorialSecondPageTitle.
  ///
  /// In en, this message translates to:
  /// **'A unique food map for this app'**
  String get tutorialSecondPageTitle;

  /// No description provided for @tutorialSecondPageSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s create a unique map for this app.\nYour posts will help evolve the map.'**
  String get tutorialSecondPageSubTitle;

  /// No description provided for @tutorialThirdPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get tutorialThirdPageTitle;

  /// No description provided for @tutorialThirdPageSubTitle.
  ///
  /// In en, this message translates to:
  /// **'・Be cautious about sharing personal information, such as your name, address, phone number, or location.\n\n・Avoid posting offensive, inappropriate, or harmful content, and do not use others\' works without permission.\n\n・Non-food-related posts may be removed.\n\n・Users who repeatedly violate the rules or post objectionable content may be removed by the management team.\n\n・We look forward to improving this app together with everyone. by the developers'**
  String get tutorialThirdPageSubTitle;

  /// No description provided for @tutorialThirdPageButton.
  ///
  /// In en, this message translates to:
  /// **'Agree to the terms of use'**
  String get tutorialThirdPageButton;

  /// No description provided for @tutorialThirdPageClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get tutorialThirdPageClose;

  /// No description provided for @detailMenuShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get detailMenuShare;

  /// No description provided for @detailMenuVisit.
  ///
  /// In en, this message translates to:
  /// **'Visit'**
  String get detailMenuVisit;

  /// No description provided for @detailMenuPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get detailMenuPost;

  /// No description provided for @detailMenuSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get detailMenuSearch;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Notification'**
  String get forceUpdateTitle;

  /// No description provided for @forceUpdateText.
  ///
  /// In en, this message translates to:
  /// **'A new version of this app has been released. Please update the app to ensure the latest features and a secure environment.'**
  String get forceUpdateText;

  /// No description provided for @forceUpdateButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get forceUpdateButtonTitle;

  /// No description provided for @newAccountImportantTitle.
  ///
  /// In en, this message translates to:
  /// **'Important Note'**
  String get newAccountImportantTitle;

  /// No description provided for @newAccountImportant.
  ///
  /// In en, this message translates to:
  /// **'When creating an account, please do not include personal information such as your email address or phone number in your username or user ID. To ensure a safe online experience, choose a name that does not reveal your personal details.'**
  String get newAccountImportant;

  /// No description provided for @accountRegistrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account registration completed'**
  String get accountRegistrationSuccess;

  /// No description provided for @accountRegistrationError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get accountRegistrationError;

  /// No description provided for @requiredInfoMissing.
  ///
  /// In en, this message translates to:
  /// **'Required information is missing'**
  String get requiredInfoMissing;

  /// No description provided for @shareTextAndImage.
  ///
  /// In en, this message translates to:
  /// **'Share with text and image'**
  String get shareTextAndImage;

  /// No description provided for @shareImageOnly.
  ///
  /// In en, this message translates to:
  /// **'Share image only'**
  String get shareImageOnly;

  /// No description provided for @foodCategoryNoodles.
  ///
  /// In en, this message translates to:
  /// **'Noodles'**
  String get foodCategoryNoodles;

  /// No description provided for @foodCategoryMeat.
  ///
  /// In en, this message translates to:
  /// **'Meat'**
  String get foodCategoryMeat;

  /// No description provided for @foodCategoryFastFood.
  ///
  /// In en, this message translates to:
  /// **'Fast Food'**
  String get foodCategoryFastFood;

  /// No description provided for @foodCategoryRiceDishes.
  ///
  /// In en, this message translates to:
  /// **'Rice Dishes'**
  String get foodCategoryRiceDishes;

  /// No description provided for @foodCategorySeafood.
  ///
  /// In en, this message translates to:
  /// **'Seafood'**
  String get foodCategorySeafood;

  /// No description provided for @foodCategoryBread.
  ///
  /// In en, this message translates to:
  /// **'Bread'**
  String get foodCategoryBread;

  /// No description provided for @foodCategorySweetsAndSnacks.
  ///
  /// In en, this message translates to:
  /// **'Sweets & Snacks'**
  String get foodCategorySweetsAndSnacks;

  /// No description provided for @foodCategoryFruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get foodCategoryFruits;

  /// No description provided for @foodCategoryVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get foodCategoryVegetables;

  /// No description provided for @foodCategoryBeverages.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get foodCategoryBeverages;

  /// No description provided for @foodCategoryOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get foodCategoryOthers;

  /// No description provided for @foodCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get foodCategoryAll;

  /// No description provided for @rankEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get rankEmerald;

  /// No description provided for @rankDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get rankDiamond;

  /// No description provided for @rankGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get rankGold;

  /// No description provided for @rankSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get rankSilver;

  /// No description provided for @rankBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get rankBronze;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @promoteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'✨Become a Premium Member✨'**
  String get promoteDialogTitle;

  /// No description provided for @promoteDialogTrophyTitle.
  ///
  /// In en, this message translates to:
  /// **'Trophy Feature'**
  String get promoteDialogTrophyTitle;

  /// No description provided for @promoteDialogTrophyDesc.
  ///
  /// In en, this message translates to:
  /// **'Display trophies based on your activities.'**
  String get promoteDialogTrophyDesc;

  /// No description provided for @promoteDialogTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Tags'**
  String get promoteDialogTagTitle;

  /// No description provided for @promoteDialogTagDesc.
  ///
  /// In en, this message translates to:
  /// **'Set custom tags for your favorite foods.'**
  String get promoteDialogTagDesc;

  /// No description provided for @promoteDialogIconTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Icon'**
  String get promoteDialogIconTitle;

  /// No description provided for @promoteDialogIconDesc.
  ///
  /// In en, this message translates to:
  /// **'Set your profile icon to any image you like!!'**
  String get promoteDialogIconDesc;

  /// No description provided for @promoteDialogAdTitle.
  ///
  /// In en, this message translates to:
  /// **'Ad-Free'**
  String get promoteDialogAdTitle;

  /// No description provided for @promoteDialogAdDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove all advertisements!!'**
  String get promoteDialogAdDesc;

  /// No description provided for @promoteDialogButton.
  ///
  /// In en, this message translates to:
  /// **'Become Premium'**
  String get promoteDialogButton;

  /// No description provided for @promoteDialogLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get promoteDialogLater;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'FoodGram Premium'**
  String get paywallTitle;

  /// No description provided for @paywallPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'✨ Premium Benefits ✨'**
  String get paywallPremiumTitle;

  /// No description provided for @paywallTrophyTitle.
  ///
  /// In en, this message translates to:
  /// **'Earn titles as you post more'**
  String get paywallTrophyTitle;

  /// No description provided for @paywallTrophyDesc.
  ///
  /// In en, this message translates to:
  /// **'Titles upgrade with your post count'**
  String get paywallTrophyDesc;

  /// No description provided for @paywallTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your favorite genres'**
  String get paywallTagTitle;

  /// No description provided for @paywallTagDesc.
  ///
  /// In en, this message translates to:
  /// **'Personalize your profile style'**
  String get paywallTagDesc;

  /// No description provided for @paywallIconTitle.
  ///
  /// In en, this message translates to:
  /// **'Use any image as your icon'**
  String get paywallIconTitle;

  /// No description provided for @paywallIconDesc.
  ///
  /// In en, this message translates to:
  /// **'Stand out from other posters'**
  String get paywallIconDesc;

  /// No description provided for @paywallAdTitle.
  ///
  /// In en, this message translates to:
  /// **'Ad-Free'**
  String get paywallAdTitle;

  /// No description provided for @paywallAdDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove all advertisements'**
  String get paywallAdDesc;

  /// No description provided for @paywallComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon...'**
  String get paywallComingSoon;

  /// No description provided for @paywallNewFeatures.
  ///
  /// In en, this message translates to:
  /// **'New premium-exclusive features\ncoming soon!'**
  String get paywallNewFeatures;

  /// No description provided for @paywallSubscribeButton.
  ///
  /// In en, this message translates to:
  /// **'Become a Premium Member'**
  String get paywallSubscribeButton;

  /// No description provided for @paywallPrice.
  ///
  /// In en, this message translates to:
  /// **'monthly  \$3 / month'**
  String get paywallPrice;

  /// No description provided for @paywallCancelNote.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get paywallCancelNote;

  /// No description provided for @paywallWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nFoodGram Members!'**
  String get paywallWelcomeTitle;

  /// No description provided for @paywallSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get paywallSkip;

  /// No description provided for @purchaseError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during purchase'**
  String get purchaseError;

  /// No description provided for @paywallTagline.
  ///
  /// In en, this message translates to:
  /// **'✨ Upgrade your food experience ✨'**
  String get paywallTagline;

  /// No description provided for @paywallMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Find with map'**
  String get paywallMapTitle;

  /// No description provided for @paywallMapDesc.
  ///
  /// In en, this message translates to:
  /// **'Find restaurants faster and easier'**
  String get paywallMapDesc;

  /// No description provided for @paywallRankTitle.
  ///
  /// In en, this message translates to:
  /// **'Earn titles as you post more'**
  String get paywallRankTitle;

  /// No description provided for @paywallRankDesc.
  ///
  /// In en, this message translates to:
  /// **'Titles upgrade with your post count'**
  String get paywallRankDesc;

  /// No description provided for @paywallGenreTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your favorite genres'**
  String get paywallGenreTitle;

  /// No description provided for @paywallGenreDesc.
  ///
  /// In en, this message translates to:
  /// **'Personalize your profile style'**
  String get paywallGenreDesc;

  /// No description provided for @paywallCustomIconTitle.
  ///
  /// In en, this message translates to:
  /// **'Use any image as your icon'**
  String get paywallCustomIconTitle;

  /// No description provided for @paywallCustomIconDesc.
  ///
  /// In en, this message translates to:
  /// **'Stand out from other posters'**
  String get paywallCustomIconDesc;

  /// No description provided for @anonymousPost.
  ///
  /// In en, this message translates to:
  /// **'Post Anonymously'**
  String get anonymousPost;

  /// No description provided for @anonymousPostDescription.
  ///
  /// In en, this message translates to:
  /// **'Username will be hidden'**
  String get anonymousPostDescription;

  /// No description provided for @anonymousShare.
  ///
  /// In en, this message translates to:
  /// **'Share Anonymously'**
  String get anonymousShare;

  /// No description provided for @anonymousUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Anonymously'**
  String get anonymousUpdate;

  /// No description provided for @anonymousPoster.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Poster'**
  String get anonymousPoster;

  /// No description provided for @anonymousUsername.
  ///
  /// In en, this message translates to:
  /// **'foodgramer'**
  String get anonymousUsername;

  /// No description provided for @tagOtherCuisine.
  ///
  /// In en, this message translates to:
  /// **'Other Cuisine'**
  String get tagOtherCuisine;

  /// No description provided for @tagOtherFood.
  ///
  /// In en, this message translates to:
  /// **'Other Food'**
  String get tagOtherFood;

  /// No description provided for @tagJapaneseCuisine.
  ///
  /// In en, this message translates to:
  /// **'Japanese Cuisine'**
  String get tagJapaneseCuisine;

  /// No description provided for @tagItalianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Italian Cuisine'**
  String get tagItalianCuisine;

  /// No description provided for @tagFrenchCuisine.
  ///
  /// In en, this message translates to:
  /// **'French Cuisine'**
  String get tagFrenchCuisine;

  /// No description provided for @tagChineseCuisine.
  ///
  /// In en, this message translates to:
  /// **'Chinese Cuisine'**
  String get tagChineseCuisine;

  /// No description provided for @tagIndianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Indian Cuisine'**
  String get tagIndianCuisine;

  /// No description provided for @tagMexicanCuisine.
  ///
  /// In en, this message translates to:
  /// **'Mexican Cuisine'**
  String get tagMexicanCuisine;

  /// No description provided for @tagHongKongCuisine.
  ///
  /// In en, this message translates to:
  /// **'Hong Kong Cuisine'**
  String get tagHongKongCuisine;

  /// No description provided for @tagAmericanCuisine.
  ///
  /// In en, this message translates to:
  /// **'American Cuisine'**
  String get tagAmericanCuisine;

  /// No description provided for @tagMediterraneanCuisine.
  ///
  /// In en, this message translates to:
  /// **'Mediterranean Cuisine'**
  String get tagMediterraneanCuisine;

  /// No description provided for @tagThaiCuisine.
  ///
  /// In en, this message translates to:
  /// **'Thai Cuisine'**
  String get tagThaiCuisine;

  /// No description provided for @tagGreekCuisine.
  ///
  /// In en, this message translates to:
  /// **'Greek Cuisine'**
  String get tagGreekCuisine;

  /// No description provided for @tagTurkishCuisine.
  ///
  /// In en, this message translates to:
  /// **'Turkish Cuisine'**
  String get tagTurkishCuisine;

  /// No description provided for @tagKoreanCuisine.
  ///
  /// In en, this message translates to:
  /// **'Korean Cuisine'**
  String get tagKoreanCuisine;

  /// No description provided for @tagRussianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Russian Cuisine'**
  String get tagRussianCuisine;

  /// No description provided for @tagSpanishCuisine.
  ///
  /// In en, this message translates to:
  /// **'Spanish Cuisine'**
  String get tagSpanishCuisine;

  /// No description provided for @tagVietnameseCuisine.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese Cuisine'**
  String get tagVietnameseCuisine;

  /// No description provided for @tagPortugueseCuisine.
  ///
  /// In en, this message translates to:
  /// **'Portuguese Cuisine'**
  String get tagPortugueseCuisine;

  /// No description provided for @tagAustrianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Austrian Cuisine'**
  String get tagAustrianCuisine;

  /// No description provided for @tagBelgianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Belgian Cuisine'**
  String get tagBelgianCuisine;

  /// No description provided for @tagSwedishCuisine.
  ///
  /// In en, this message translates to:
  /// **'Swedish Cuisine'**
  String get tagSwedishCuisine;

  /// No description provided for @tagGermanCuisine.
  ///
  /// In en, this message translates to:
  /// **'German Cuisine'**
  String get tagGermanCuisine;

  /// No description provided for @tagBritishCuisine.
  ///
  /// In en, this message translates to:
  /// **'British Cuisine'**
  String get tagBritishCuisine;

  /// No description provided for @tagDutchCuisine.
  ///
  /// In en, this message translates to:
  /// **'Dutch Cuisine'**
  String get tagDutchCuisine;

  /// No description provided for @tagAustralianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Australian Cuisine'**
  String get tagAustralianCuisine;

  /// No description provided for @tagBrazilianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Brazilian Cuisine'**
  String get tagBrazilianCuisine;

  /// No description provided for @tagArgentineCuisine.
  ///
  /// In en, this message translates to:
  /// **'Argentine Cuisine'**
  String get tagArgentineCuisine;

  /// No description provided for @tagColombianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Colombian Cuisine'**
  String get tagColombianCuisine;

  /// No description provided for @tagPeruvianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Peruvian Cuisine'**
  String get tagPeruvianCuisine;

  /// No description provided for @tagNorwegianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Norwegian Cuisine'**
  String get tagNorwegianCuisine;

  /// No description provided for @tagDanishCuisine.
  ///
  /// In en, this message translates to:
  /// **'Danish Cuisine'**
  String get tagDanishCuisine;

  /// No description provided for @tagPolishCuisine.
  ///
  /// In en, this message translates to:
  /// **'Polish Cuisine'**
  String get tagPolishCuisine;

  /// No description provided for @tagCzechCuisine.
  ///
  /// In en, this message translates to:
  /// **'Czech Cuisine'**
  String get tagCzechCuisine;

  /// No description provided for @tagHungarianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Hungarian Cuisine'**
  String get tagHungarianCuisine;

  /// No description provided for @tagSouthAfricanCuisine.
  ///
  /// In en, this message translates to:
  /// **'South African Cuisine'**
  String get tagSouthAfricanCuisine;

  /// No description provided for @tagEgyptianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Egyptian Cuisine'**
  String get tagEgyptianCuisine;

  /// No description provided for @tagMoroccanCuisine.
  ///
  /// In en, this message translates to:
  /// **'Moroccan Cuisine'**
  String get tagMoroccanCuisine;

  /// No description provided for @tagNewZealandCuisine.
  ///
  /// In en, this message translates to:
  /// **'New Zealand Cuisine'**
  String get tagNewZealandCuisine;

  /// No description provided for @tagFilipinoCuisine.
  ///
  /// In en, this message translates to:
  /// **'Filipino Cuisine'**
  String get tagFilipinoCuisine;

  /// No description provided for @tagMalaysianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Malaysian Cuisine'**
  String get tagMalaysianCuisine;

  /// No description provided for @tagSingaporeanCuisine.
  ///
  /// In en, this message translates to:
  /// **'Singaporean Cuisine'**
  String get tagSingaporeanCuisine;

  /// No description provided for @tagIndonesianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Indonesian Cuisine'**
  String get tagIndonesianCuisine;

  /// No description provided for @tagIranianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Iranian Cuisine'**
  String get tagIranianCuisine;

  /// No description provided for @tagSaudiArabianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Saudi Arabian Cuisine'**
  String get tagSaudiArabianCuisine;

  /// No description provided for @tagMongolianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Mongolian Cuisine'**
  String get tagMongolianCuisine;

  /// No description provided for @tagCambodianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Cambodian Cuisine'**
  String get tagCambodianCuisine;

  /// No description provided for @tagLaotianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Laotian Cuisine'**
  String get tagLaotianCuisine;

  /// No description provided for @tagCubanCuisine.
  ///
  /// In en, this message translates to:
  /// **'Cuban Cuisine'**
  String get tagCubanCuisine;

  /// No description provided for @tagJamaicanCuisine.
  ///
  /// In en, this message translates to:
  /// **'Jamaican Cuisine'**
  String get tagJamaicanCuisine;

  /// No description provided for @tagChileanCuisine.
  ///
  /// In en, this message translates to:
  /// **'Chilean Cuisine'**
  String get tagChileanCuisine;

  /// No description provided for @tagVenezuelanCuisine.
  ///
  /// In en, this message translates to:
  /// **'Venezuelan Cuisine'**
  String get tagVenezuelanCuisine;

  /// No description provided for @tagPanamanianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Panamanian Cuisine'**
  String get tagPanamanianCuisine;

  /// No description provided for @tagBolivianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Bolivian Cuisine'**
  String get tagBolivianCuisine;

  /// No description provided for @tagIcelandicCuisine.
  ///
  /// In en, this message translates to:
  /// **'Icelandic Cuisine'**
  String get tagIcelandicCuisine;

  /// No description provided for @tagLithuanianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Lithuanian Cuisine'**
  String get tagLithuanianCuisine;

  /// No description provided for @tagEstonianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Estonian Cuisine'**
  String get tagEstonianCuisine;

  /// No description provided for @tagLatvianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Latvian Cuisine'**
  String get tagLatvianCuisine;

  /// No description provided for @tagFinnishCuisine.
  ///
  /// In en, this message translates to:
  /// **'Finnish Cuisine'**
  String get tagFinnishCuisine;

  /// No description provided for @tagCroatianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Croatian Cuisine'**
  String get tagCroatianCuisine;

  /// No description provided for @tagSlovenianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Slovenian Cuisine'**
  String get tagSlovenianCuisine;

  /// No description provided for @tagSlovakCuisine.
  ///
  /// In en, this message translates to:
  /// **'Slovak Cuisine'**
  String get tagSlovakCuisine;

  /// No description provided for @tagRomanianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Romanian Cuisine'**
  String get tagRomanianCuisine;

  /// No description provided for @tagBulgarianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Bulgarian Cuisine'**
  String get tagBulgarianCuisine;

  /// No description provided for @tagSerbianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Serbian Cuisine'**
  String get tagSerbianCuisine;

  /// No description provided for @tagAlbanianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Albanian Cuisine'**
  String get tagAlbanianCuisine;

  /// No description provided for @tagGeorgianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Georgian Cuisine'**
  String get tagGeorgianCuisine;

  /// No description provided for @tagArmenianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Armenian Cuisine'**
  String get tagArmenianCuisine;

  /// No description provided for @tagAzerbaijaniCuisine.
  ///
  /// In en, this message translates to:
  /// **'Azerbaijani Cuisine'**
  String get tagAzerbaijaniCuisine;

  /// No description provided for @tagUkrainianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian Cuisine'**
  String get tagUkrainianCuisine;

  /// No description provided for @tagBelarusianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Belarusian Cuisine'**
  String get tagBelarusianCuisine;

  /// No description provided for @tagKazakhCuisine.
  ///
  /// In en, this message translates to:
  /// **'Kazakh Cuisine'**
  String get tagKazakhCuisine;

  /// No description provided for @tagUzbekCuisine.
  ///
  /// In en, this message translates to:
  /// **'Uzbek Cuisine'**
  String get tagUzbekCuisine;

  /// No description provided for @tagKyrgyzCuisine.
  ///
  /// In en, this message translates to:
  /// **'Kyrgyz Cuisine'**
  String get tagKyrgyzCuisine;

  /// No description provided for @tagTurkmenCuisine.
  ///
  /// In en, this message translates to:
  /// **'Turkmen Cuisine'**
  String get tagTurkmenCuisine;

  /// No description provided for @tagTajikCuisine.
  ///
  /// In en, this message translates to:
  /// **'Tajik Cuisine'**
  String get tagTajikCuisine;

  /// No description provided for @tagMaldivianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Maldivian Cuisine'**
  String get tagMaldivianCuisine;

  /// No description provided for @tagNepaleseCuisine.
  ///
  /// In en, this message translates to:
  /// **'Nepalese Cuisine'**
  String get tagNepaleseCuisine;

  /// No description provided for @tagBangladeshiCuisine.
  ///
  /// In en, this message translates to:
  /// **'Bangladeshi Cuisine'**
  String get tagBangladeshiCuisine;

  /// No description provided for @tagMyanmarCuisine.
  ///
  /// In en, this message translates to:
  /// **'Myanmar Cuisine'**
  String get tagMyanmarCuisine;

  /// No description provided for @tagBruneianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Bruneian Cuisine'**
  String get tagBruneianCuisine;

  /// No description provided for @tagTaiwaneseCuisine.
  ///
  /// In en, this message translates to:
  /// **'Taiwanese Cuisine'**
  String get tagTaiwaneseCuisine;

  /// No description provided for @tagNigerianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Nigerian Cuisine'**
  String get tagNigerianCuisine;

  /// No description provided for @tagKenyanCuisine.
  ///
  /// In en, this message translates to:
  /// **'Kenyan Cuisine'**
  String get tagKenyanCuisine;

  /// No description provided for @tagGhanaianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Ghanaian Cuisine'**
  String get tagGhanaianCuisine;

  /// No description provided for @tagEthiopianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Ethiopian Cuisine'**
  String get tagEthiopianCuisine;

  /// No description provided for @tagSudaneseCuisine.
  ///
  /// In en, this message translates to:
  /// **'Sudanese Cuisine'**
  String get tagSudaneseCuisine;

  /// No description provided for @tagTunisianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Tunisian Cuisine'**
  String get tagTunisianCuisine;

  /// No description provided for @tagAngolanCuisine.
  ///
  /// In en, this message translates to:
  /// **'Angolan Cuisine'**
  String get tagAngolanCuisine;

  /// No description provided for @tagCongoleseCuisine.
  ///
  /// In en, this message translates to:
  /// **'Congolese Cuisine'**
  String get tagCongoleseCuisine;

  /// No description provided for @tagZimbabweanCuisine.
  ///
  /// In en, this message translates to:
  /// **'Zimbabwean Cuisine'**
  String get tagZimbabweanCuisine;

  /// No description provided for @tagMalagasyCuisine.
  ///
  /// In en, this message translates to:
  /// **'Malagasy Cuisine'**
  String get tagMalagasyCuisine;

  /// No description provided for @tagPapuaNewGuineanCuisine.
  ///
  /// In en, this message translates to:
  /// **'Papua New Guinean Cuisine'**
  String get tagPapuaNewGuineanCuisine;

  /// No description provided for @tagSamoanCuisine.
  ///
  /// In en, this message translates to:
  /// **'Samoan Cuisine'**
  String get tagSamoanCuisine;

  /// No description provided for @tagTuvaluanCuisine.
  ///
  /// In en, this message translates to:
  /// **'Tuvaluan Cuisine'**
  String get tagTuvaluanCuisine;

  /// No description provided for @tagFijianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Fijian Cuisine'**
  String get tagFijianCuisine;

  /// No description provided for @tagPalauanCuisine.
  ///
  /// In en, this message translates to:
  /// **'Palauan Cuisine'**
  String get tagPalauanCuisine;

  /// No description provided for @tagKiribatiCuisine.
  ///
  /// In en, this message translates to:
  /// **'Kiribati Cuisine'**
  String get tagKiribatiCuisine;

  /// No description provided for @tagVanuatuanCuisine.
  ///
  /// In en, this message translates to:
  /// **'Vanuatuan Cuisine'**
  String get tagVanuatuanCuisine;

  /// No description provided for @tagBahrainiCuisine.
  ///
  /// In en, this message translates to:
  /// **'Bahraini Cuisine'**
  String get tagBahrainiCuisine;

  /// No description provided for @tagQatariCuisine.
  ///
  /// In en, this message translates to:
  /// **'Qatari Cuisine'**
  String get tagQatariCuisine;

  /// No description provided for @tagKuwaitiCuisine.
  ///
  /// In en, this message translates to:
  /// **'Kuwaiti Cuisine'**
  String get tagKuwaitiCuisine;

  /// No description provided for @tagOmaniCuisine.
  ///
  /// In en, this message translates to:
  /// **'Omani Cuisine'**
  String get tagOmaniCuisine;

  /// No description provided for @tagYemeniCuisine.
  ///
  /// In en, this message translates to:
  /// **'Yemeni Cuisine'**
  String get tagYemeniCuisine;

  /// No description provided for @tagLebaneseCuisine.
  ///
  /// In en, this message translates to:
  /// **'Lebanese Cuisine'**
  String get tagLebaneseCuisine;

  /// No description provided for @tagSyrianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Syrian Cuisine'**
  String get tagSyrianCuisine;

  /// No description provided for @tagJordanianCuisine.
  ///
  /// In en, this message translates to:
  /// **'Jordanian Cuisine'**
  String get tagJordanianCuisine;

  /// No description provided for @tagNoodles.
  ///
  /// In en, this message translates to:
  /// **'Noodles'**
  String get tagNoodles;

  /// No description provided for @tagMeatDishes.
  ///
  /// In en, this message translates to:
  /// **'Meat Dishes'**
  String get tagMeatDishes;

  /// No description provided for @tagFastFood.
  ///
  /// In en, this message translates to:
  /// **'Fast Food'**
  String get tagFastFood;

  /// No description provided for @tagRiceDishes.
  ///
  /// In en, this message translates to:
  /// **'Rice Dishes'**
  String get tagRiceDishes;

  /// No description provided for @tagSeafood.
  ///
  /// In en, this message translates to:
  /// **'Seafood'**
  String get tagSeafood;

  /// No description provided for @tagBread.
  ///
  /// In en, this message translates to:
  /// **'Bread'**
  String get tagBread;

  /// No description provided for @tagSweetsAndSnacks.
  ///
  /// In en, this message translates to:
  /// **'Sweets & Snacks'**
  String get tagSweetsAndSnacks;

  /// No description provided for @tagFruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get tagFruits;

  /// No description provided for @tagVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get tagVegetables;

  /// No description provided for @tagBeverages.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get tagBeverages;

  /// No description provided for @tagOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get tagOthers;

  /// No description provided for @tagPasta.
  ///
  /// In en, this message translates to:
  /// **'Pasta'**
  String get tagPasta;

  /// No description provided for @tagRamen.
  ///
  /// In en, this message translates to:
  /// **'Ramen'**
  String get tagRamen;

  /// No description provided for @tagSteak.
  ///
  /// In en, this message translates to:
  /// **'Steak'**
  String get tagSteak;

  /// No description provided for @tagYakiniku.
  ///
  /// In en, this message translates to:
  /// **'Yakiniku'**
  String get tagYakiniku;

  /// No description provided for @tagChicken.
  ///
  /// In en, this message translates to:
  /// **'Chicken'**
  String get tagChicken;

  /// No description provided for @tagBacon.
  ///
  /// In en, this message translates to:
  /// **'Bacon'**
  String get tagBacon;

  /// No description provided for @tagHamburger.
  ///
  /// In en, this message translates to:
  /// **'Hamburger'**
  String get tagHamburger;

  /// No description provided for @tagFrenchFries.
  ///
  /// In en, this message translates to:
  /// **'French Fries'**
  String get tagFrenchFries;

  /// No description provided for @tagPizza.
  ///
  /// In en, this message translates to:
  /// **'Pizza'**
  String get tagPizza;

  /// No description provided for @tagTacos.
  ///
  /// In en, this message translates to:
  /// **'Tacos'**
  String get tagTacos;

  /// No description provided for @tagTamales.
  ///
  /// In en, this message translates to:
  /// **'Tamales'**
  String get tagTamales;

  /// No description provided for @tagGyoza.
  ///
  /// In en, this message translates to:
  /// **'Gyoza'**
  String get tagGyoza;

  /// No description provided for @tagFriedShrimp.
  ///
  /// In en, this message translates to:
  /// **'Fried Shrimp'**
  String get tagFriedShrimp;

  /// No description provided for @tagHotPot.
  ///
  /// In en, this message translates to:
  /// **'Hot Pot'**
  String get tagHotPot;

  /// No description provided for @tagCurry.
  ///
  /// In en, this message translates to:
  /// **'Curry'**
  String get tagCurry;

  /// No description provided for @tagPaella.
  ///
  /// In en, this message translates to:
  /// **'Paella'**
  String get tagPaella;

  /// No description provided for @tagFondue.
  ///
  /// In en, this message translates to:
  /// **'Fondue'**
  String get tagFondue;

  /// No description provided for @tagOnigiri.
  ///
  /// In en, this message translates to:
  /// **'Onigiri'**
  String get tagOnigiri;

  /// No description provided for @tagRice.
  ///
  /// In en, this message translates to:
  /// **'Rice'**
  String get tagRice;

  /// No description provided for @tagBento.
  ///
  /// In en, this message translates to:
  /// **'Bento'**
  String get tagBento;

  /// No description provided for @tagSushi.
  ///
  /// In en, this message translates to:
  /// **'Sushi'**
  String get tagSushi;

  /// No description provided for @tagFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get tagFish;

  /// No description provided for @tagOctopus.
  ///
  /// In en, this message translates to:
  /// **'Octopus'**
  String get tagOctopus;

  /// No description provided for @tagSquid.
  ///
  /// In en, this message translates to:
  /// **'Squid'**
  String get tagSquid;

  /// No description provided for @tagShrimp.
  ///
  /// In en, this message translates to:
  /// **'Shrimp'**
  String get tagShrimp;

  /// No description provided for @tagCrab.
  ///
  /// In en, this message translates to:
  /// **'Crab'**
  String get tagCrab;

  /// No description provided for @tagShellfish.
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get tagShellfish;

  /// No description provided for @tagOyster.
  ///
  /// In en, this message translates to:
  /// **'Oyster'**
  String get tagOyster;

  /// No description provided for @tagSandwich.
  ///
  /// In en, this message translates to:
  /// **'Sandwich'**
  String get tagSandwich;

  /// No description provided for @tagHotDog.
  ///
  /// In en, this message translates to:
  /// **'Hot Dog'**
  String get tagHotDog;

  /// No description provided for @tagDonut.
  ///
  /// In en, this message translates to:
  /// **'Donut'**
  String get tagDonut;

  /// No description provided for @tagPancake.
  ///
  /// In en, this message translates to:
  /// **'Pancake'**
  String get tagPancake;

  /// No description provided for @tagCroissant.
  ///
  /// In en, this message translates to:
  /// **'Croissant'**
  String get tagCroissant;

  /// No description provided for @tagBagel.
  ///
  /// In en, this message translates to:
  /// **'Bagel'**
  String get tagBagel;

  /// No description provided for @tagBaguette.
  ///
  /// In en, this message translates to:
  /// **'Baguette'**
  String get tagBaguette;

  /// No description provided for @tagPretzel.
  ///
  /// In en, this message translates to:
  /// **'Pretzel'**
  String get tagPretzel;

  /// No description provided for @tagBurrito.
  ///
  /// In en, this message translates to:
  /// **'Burrito'**
  String get tagBurrito;

  /// No description provided for @tagIceCream.
  ///
  /// In en, this message translates to:
  /// **'Ice Cream'**
  String get tagIceCream;

  /// No description provided for @tagPudding.
  ///
  /// In en, this message translates to:
  /// **'Pudding'**
  String get tagPudding;

  /// No description provided for @tagRiceCracker.
  ///
  /// In en, this message translates to:
  /// **'Rice Cracker'**
  String get tagRiceCracker;

  /// No description provided for @tagDango.
  ///
  /// In en, this message translates to:
  /// **'Dango'**
  String get tagDango;

  /// No description provided for @tagShavedIce.
  ///
  /// In en, this message translates to:
  /// **'Shaved Ice'**
  String get tagShavedIce;

  /// No description provided for @tagPie.
  ///
  /// In en, this message translates to:
  /// **'Pie'**
  String get tagPie;

  /// No description provided for @tagCupcake.
  ///
  /// In en, this message translates to:
  /// **'Cupcake'**
  String get tagCupcake;

  /// No description provided for @tagCake.
  ///
  /// In en, this message translates to:
  /// **'Cake'**
  String get tagCake;

  /// No description provided for @tagCandy.
  ///
  /// In en, this message translates to:
  /// **'Candy'**
  String get tagCandy;

  /// No description provided for @tagLollipop.
  ///
  /// In en, this message translates to:
  /// **'Lollipop'**
  String get tagLollipop;

  /// No description provided for @tagChocolate.
  ///
  /// In en, this message translates to:
  /// **'Chocolate'**
  String get tagChocolate;

  /// No description provided for @tagPopcorn.
  ///
  /// In en, this message translates to:
  /// **'Popcorn'**
  String get tagPopcorn;

  /// No description provided for @tagCookie.
  ///
  /// In en, this message translates to:
  /// **'Cookie'**
  String get tagCookie;

  /// No description provided for @tagPeanuts.
  ///
  /// In en, this message translates to:
  /// **'Peanuts'**
  String get tagPeanuts;

  /// No description provided for @tagBeans.
  ///
  /// In en, this message translates to:
  /// **'Beans'**
  String get tagBeans;

  /// No description provided for @tagChestnut.
  ///
  /// In en, this message translates to:
  /// **'Chestnut'**
  String get tagChestnut;

  /// No description provided for @tagFortuneCookie.
  ///
  /// In en, this message translates to:
  /// **'Fortune Cookie'**
  String get tagFortuneCookie;

  /// No description provided for @tagMooncake.
  ///
  /// In en, this message translates to:
  /// **'Mooncake'**
  String get tagMooncake;

  /// No description provided for @tagHoney.
  ///
  /// In en, this message translates to:
  /// **'Honey'**
  String get tagHoney;

  /// No description provided for @tagWaffle.
  ///
  /// In en, this message translates to:
  /// **'Waffle'**
  String get tagWaffle;

  /// No description provided for @tagApple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get tagApple;

  /// No description provided for @tagPear.
  ///
  /// In en, this message translates to:
  /// **'Pear'**
  String get tagPear;

  /// No description provided for @tagOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get tagOrange;

  /// No description provided for @tagLemon.
  ///
  /// In en, this message translates to:
  /// **'Lemon'**
  String get tagLemon;

  /// No description provided for @tagLime.
  ///
  /// In en, this message translates to:
  /// **'Lime'**
  String get tagLime;

  /// No description provided for @tagBanana.
  ///
  /// In en, this message translates to:
  /// **'Banana'**
  String get tagBanana;

  /// No description provided for @tagWatermelon.
  ///
  /// In en, this message translates to:
  /// **'Watermelon'**
  String get tagWatermelon;

  /// No description provided for @tagGrapes.
  ///
  /// In en, this message translates to:
  /// **'Grapes'**
  String get tagGrapes;

  /// No description provided for @tagStrawberry.
  ///
  /// In en, this message translates to:
  /// **'Strawberry'**
  String get tagStrawberry;

  /// No description provided for @tagBlueberry.
  ///
  /// In en, this message translates to:
  /// **'Blueberry'**
  String get tagBlueberry;

  /// No description provided for @tagMelon.
  ///
  /// In en, this message translates to:
  /// **'Melon'**
  String get tagMelon;

  /// No description provided for @tagCherry.
  ///
  /// In en, this message translates to:
  /// **'Cherry'**
  String get tagCherry;

  /// No description provided for @tagPeach.
  ///
  /// In en, this message translates to:
  /// **'Peach'**
  String get tagPeach;

  /// No description provided for @tagMango.
  ///
  /// In en, this message translates to:
  /// **'Mango'**
  String get tagMango;

  /// No description provided for @tagPineapple.
  ///
  /// In en, this message translates to:
  /// **'Pineapple'**
  String get tagPineapple;

  /// No description provided for @tagCoconut.
  ///
  /// In en, this message translates to:
  /// **'Coconut'**
  String get tagCoconut;

  /// No description provided for @tagKiwi.
  ///
  /// In en, this message translates to:
  /// **'Kiwi'**
  String get tagKiwi;

  /// No description provided for @tagSalad.
  ///
  /// In en, this message translates to:
  /// **'Salad'**
  String get tagSalad;

  /// No description provided for @tagTomato.
  ///
  /// In en, this message translates to:
  /// **'Tomato'**
  String get tagTomato;

  /// No description provided for @tagEggplant.
  ///
  /// In en, this message translates to:
  /// **'Eggplant'**
  String get tagEggplant;

  /// No description provided for @tagAvocado.
  ///
  /// In en, this message translates to:
  /// **'Avocado'**
  String get tagAvocado;

  /// No description provided for @tagGreenBeans.
  ///
  /// In en, this message translates to:
  /// **'Green Beans'**
  String get tagGreenBeans;

  /// No description provided for @tagBroccoli.
  ///
  /// In en, this message translates to:
  /// **'Broccoli'**
  String get tagBroccoli;

  /// No description provided for @tagLettuce.
  ///
  /// In en, this message translates to:
  /// **'Lettuce'**
  String get tagLettuce;

  /// No description provided for @tagCucumber.
  ///
  /// In en, this message translates to:
  /// **'Cucumber'**
  String get tagCucumber;

  /// No description provided for @tagChili.
  ///
  /// In en, this message translates to:
  /// **'Chili'**
  String get tagChili;

  /// No description provided for @tagBellPepper.
  ///
  /// In en, this message translates to:
  /// **'Bell Pepper'**
  String get tagBellPepper;

  /// No description provided for @tagCorn.
  ///
  /// In en, this message translates to:
  /// **'Corn'**
  String get tagCorn;

  /// No description provided for @tagCarrot.
  ///
  /// In en, this message translates to:
  /// **'Carrot'**
  String get tagCarrot;

  /// No description provided for @tagOlive.
  ///
  /// In en, this message translates to:
  /// **'Olive'**
  String get tagOlive;

  /// No description provided for @tagGarlic.
  ///
  /// In en, this message translates to:
  /// **'Garlic'**
  String get tagGarlic;

  /// No description provided for @tagOnion.
  ///
  /// In en, this message translates to:
  /// **'Onion'**
  String get tagOnion;

  /// No description provided for @tagPotato.
  ///
  /// In en, this message translates to:
  /// **'Potato'**
  String get tagPotato;

  /// No description provided for @tagSweetPotato.
  ///
  /// In en, this message translates to:
  /// **'Sweet Potato'**
  String get tagSweetPotato;

  /// No description provided for @tagGinger.
  ///
  /// In en, this message translates to:
  /// **'Ginger'**
  String get tagGinger;

  /// No description provided for @tagShiitake.
  ///
  /// In en, this message translates to:
  /// **'Shiitake'**
  String get tagShiitake;

  /// No description provided for @tagTeapot.
  ///
  /// In en, this message translates to:
  /// **'Teapot'**
  String get tagTeapot;

  /// No description provided for @tagCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get tagCoffee;

  /// No description provided for @tagTea.
  ///
  /// In en, this message translates to:
  /// **'Tea'**
  String get tagTea;

  /// No description provided for @tagJuice.
  ///
  /// In en, this message translates to:
  /// **'Juice'**
  String get tagJuice;

  /// No description provided for @tagSoftDrink.
  ///
  /// In en, this message translates to:
  /// **'Soft Drink'**
  String get tagSoftDrink;

  /// No description provided for @tagBubbleTea.
  ///
  /// In en, this message translates to:
  /// **'Bubble Tea'**
  String get tagBubbleTea;

  /// No description provided for @tagSake.
  ///
  /// In en, this message translates to:
  /// **'Sake'**
  String get tagSake;

  /// No description provided for @tagBeer.
  ///
  /// In en, this message translates to:
  /// **'Beer'**
  String get tagBeer;

  /// No description provided for @tagChampagne.
  ///
  /// In en, this message translates to:
  /// **'Champagne'**
  String get tagChampagne;

  /// No description provided for @tagWine.
  ///
  /// In en, this message translates to:
  /// **'Wine'**
  String get tagWine;

  /// No description provided for @tagWhiskey.
  ///
  /// In en, this message translates to:
  /// **'Whiskey'**
  String get tagWhiskey;

  /// No description provided for @tagCocktail.
  ///
  /// In en, this message translates to:
  /// **'Cocktail'**
  String get tagCocktail;

  /// No description provided for @tagTropicalCocktail.
  ///
  /// In en, this message translates to:
  /// **'Tropical Cocktail'**
  String get tagTropicalCocktail;

  /// No description provided for @tagMateTea.
  ///
  /// In en, this message translates to:
  /// **'Mate Tea'**
  String get tagMateTea;

  /// No description provided for @tagMilk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get tagMilk;

  /// No description provided for @tagKamaboko.
  ///
  /// In en, this message translates to:
  /// **'Kamaboko'**
  String get tagKamaboko;

  /// No description provided for @tagOden.
  ///
  /// In en, this message translates to:
  /// **'Oden'**
  String get tagOden;

  /// No description provided for @tagCheese.
  ///
  /// In en, this message translates to:
  /// **'Cheese'**
  String get tagCheese;

  /// No description provided for @tagEgg.
  ///
  /// In en, this message translates to:
  /// **'Egg'**
  String get tagEgg;

  /// No description provided for @tagFriedEgg.
  ///
  /// In en, this message translates to:
  /// **'Fried Egg'**
  String get tagFriedEgg;

  /// No description provided for @tagButter.
  ///
  /// In en, this message translates to:
  /// **'Butter'**
  String get tagButter;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @searchFood.
  ///
  /// In en, this message translates to:
  /// **'Search food'**
  String get searchFood;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get searchCountry;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter restaurant name to search'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptyHintTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Tips'**
  String get searchEmptyHintTitle;

  /// No description provided for @searchEmptyHintLocation.
  ///
  /// In en, this message translates to:
  /// **'Turn on location to show nearby results first'**
  String get searchEmptyHintLocation;

  /// No description provided for @searchEmptyHintSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by restaurant name or cuisine type'**
  String get searchEmptyHintSearch;

  /// No description provided for @postErrorPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to take photo'**
  String get postErrorPickImage;

  /// No description provided for @favoritePostEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved posts'**
  String get favoritePostEmptyTitle;

  /// No description provided for @favoritePostEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save posts that interest you!'**
  String get favoritePostEmptySubtitle;

  /// No description provided for @userInfoFetchError.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch user information'**
  String get userInfoFetchError;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @savedPosts.
  ///
  /// In en, this message translates to:
  /// **'Saved Posts'**
  String get savedPosts;

  /// No description provided for @postSaved.
  ///
  /// In en, this message translates to:
  /// **'Post saved'**
  String get postSaved;

  /// No description provided for @postSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'You can view saved posts in My Page'**
  String get postSavedMessage;

  /// No description provided for @noMapAppAvailable.
  ///
  /// In en, this message translates to:
  /// **'No map app available'**
  String get noMapAppAvailable;

  /// No description provided for @notificationLunchTitle.
  ///
  /// In en, this message translates to:
  /// **'#Did you post today\'s meal? 🍜'**
  String get notificationLunchTitle;

  /// No description provided for @notificationLunchBody.
  ///
  /// In en, this message translates to:
  /// **'Why not record today\'s lunch while you still remember it?'**
  String get notificationLunchBody;

  /// No description provided for @notificationDinnerTitle.
  ///
  /// In en, this message translates to:
  /// **'#Did you post today\'s meal? 🍛'**
  String get notificationDinnerTitle;

  /// No description provided for @notificationDinnerBody.
  ///
  /// In en, this message translates to:
  /// **'Post today\'s meal and wrap up your day gently 📷'**
  String get notificationDinnerBody;

  /// No description provided for @posted.
  ///
  /// In en, this message translates to:
  /// **'posted'**
  String get posted;

  /// No description provided for @tutorialLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on Location!'**
  String get tutorialLocationTitle;

  /// No description provided for @tutorialLocationSubTitle.
  ///
  /// In en, this message translates to:
  /// **'To find great places nearby,\nmake restaurant discovery easier'**
  String get tutorialLocationSubTitle;

  /// No description provided for @tutorialLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get tutorialLocationButton;

  /// No description provided for @tutorialNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on Notifications!'**
  String get tutorialNotificationTitle;

  /// No description provided for @tutorialNotificationSubTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send reminders at lunch and dinner'**
  String get tutorialNotificationSubTitle;

  /// No description provided for @tutorialNotificationButton.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get tutorialNotificationButton;

  /// No description provided for @selectMapApp.
  ///
  /// In en, this message translates to:
  /// **'Select Map App'**
  String get selectMapApp;

  /// No description provided for @mapAppGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get mapAppGoogle;

  /// No description provided for @mapAppApple.
  ///
  /// In en, this message translates to:
  /// **'Apple Maps'**
  String get mapAppApple;

  /// No description provided for @mapAppBaidu.
  ///
  /// In en, this message translates to:
  /// **'Baidu Maps'**
  String get mapAppBaidu;

  /// No description provided for @mapAppMapsMe.
  ///
  /// In en, this message translates to:
  /// **'Maps.me'**
  String get mapAppMapsMe;

  /// No description provided for @mapAppKakao.
  ///
  /// In en, this message translates to:
  /// **'KakaoMap'**
  String get mapAppKakao;

  /// No description provided for @mapAppNaver.
  ///
  /// In en, this message translates to:
  /// **'Naver Map'**
  String get mapAppNaver;

  /// No description provided for @streakDialogFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Post completed'**
  String get streakDialogFirstTitle;

  /// No description provided for @streakDialogFirstContent.
  ///
  /// In en, this message translates to:
  /// **'Keep posting\nto continue streak'**
  String get streakDialogFirstContent;

  /// No description provided for @streakDialogContinueTitle.
  ///
  /// In en, this message translates to:
  /// **'Post completed'**
  String get streakDialogContinueTitle;

  /// No description provided for @streakDialogContinueContent.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks streak!\nKeep posting\nto continue streak'**
  String streakDialogContinueContent(int weeks);

  /// No description provided for @translatableTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translatableTranslate;

  /// No description provided for @translatableShowOriginal.
  ///
  /// In en, this message translates to:
  /// **'Show original'**
  String get translatableShowOriginal;

  /// No description provided for @translatableCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get translatableCopy;

  /// No description provided for @translatableCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get translatableCopied;

  /// No description provided for @translatableTranslateFailed.
  ///
  /// In en, this message translates to:
  /// **'Translation failed'**
  String get translatableTranslateFailed;

  /// No description provided for @likeNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likeNotificationsTitle;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get loadFailed;

  /// No description provided for @someoneLikedYourPost.
  ///
  /// In en, this message translates to:
  /// **'Someone liked your post.'**
  String get someoneLikedYourPost;

  /// No description provided for @userLikedYourPost.
  ///
  /// In en, this message translates to:
  /// **'{name} liked your post.'**
  String userLikedYourPost(String name);
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
