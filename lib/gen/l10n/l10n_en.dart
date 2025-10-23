// ignore_for_file

import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get editTitle => 'Edit';

  @override
  String get editPostButton => 'Edit Post';

  @override
  String get emailInputField => 'Enter your email address';

  @override
  String get settingIcon => 'Select Icon';

  @override
  String get userName => 'Username';

  @override
  String get userNameInputField => 'Username (e.g., iseryu)';

  @override
  String get userId => 'User ID';

  @override
  String get userIdInputField => 'User ID (e.g., iseryuuu)';

  @override
  String get registerButton => 'Register';

  @override
  String get settingAppBar => 'Settings';

  @override
  String get settingCheckVersion => 'Check version';

  @override
  String get settingCheckVersionDialogTitle => 'Update Information';

  @override
  String get settingCheckVersionDialogText1 => 'A newer version is available.';

  @override
  String get settingCheckVersionDialogText2 => 'Please update to the latest version.';

  @override
  String get settingDeveloper => 'Twitter';

  @override
  String get settingGithub => 'Github';

  @override
  String get settingReview => 'Review';

  @override
  String get settingLicense => 'License';

  @override
  String get settingShareApp => 'Share';

  @override
  String get settingFaq => 'FAQ';

  @override
  String get settingPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingTermsOfUse => 'Terms of Use';

  @override
  String get settingContact => 'Contact';

  @override
  String get settingTutorial => 'Tutorial';

  @override
  String get settingCredit => 'Credit';

  @override
  String get unregistered => 'Unregistered';

  @override
  String get settingBatteryLevel => 'Battery Level';

  @override
  String get settingDeviceInfo => 'Device Info';

  @override
  String get settingIosVersion => 'iOS Version';

  @override
  String get settingAndroidSdk => 'SDK';

  @override
  String get settingAppVersion => 'App Version';

  @override
  String get settingAccount => 'Account';

  @override
  String get settingLogoutButton => 'Logout';

  @override
  String get settingDeleteAccountButton => 'Request Deletion';

  @override
  String get settingQuestion => 'Question Box';

  @override
  String get settingAccountManagement => 'Account Management';

  @override
  String get settingRestoreSuccessTitle => 'Restore successful';

  @override
  String get settingRestoreSuccessSubtitle => 'Premium features enabled!';

  @override
  String get settingRestoreFailureTitle => 'Restore failed';

  @override
  String get settingRestoreFailureSubtitle => 'No purchase history? Contact support';

  @override
  String get settingRestore => 'Restore';

  @override
  String get shareButton => 'Share';

  @override
  String get postFoodName => 'Food Name';

  @override
  String get postFoodNameInputField => 'Enter food name(Required)';

  @override
  String get postRestaurantNameInputField => 'Add restaurant(Required)';

  @override
  String get postComment => 'Enter Comment(Optional)';

  @override
  String get postCommentInputField => 'Comment';

  @override
  String get postError => 'Submission failure';

  @override
  String get postCategoryTitle => 'Select country/cuisine tag (optional)';

  @override
  String get postCountryCategory => 'Country';

  @override
  String get postCuisineCategory => 'Cuisine';

  @override
  String get postTitle => 'Post';

  @override
  String get postMissingInfo => 'Please fill in all required fields';

  @override
  String get postMissingPhoto => 'Please add a photo';

  @override
  String get postMissingFoodName => 'Please enter what you ate';

  @override
  String get postMissingRestaurant => 'Please add restaurant name';

  @override
  String get postPhotoSuccess => 'Photo added successfully';

  @override
  String get postCameraPermission => 'Camera permission is required';

  @override
  String get postAlbumPermission => 'Photo library permission is required';

  @override
  String get postSuccess => 'Post successful';

  @override
  String get postSearchError => 'Unable to search for place names';

  @override
  String get editUpdateButton => 'Update';

  @override
  String get editBio => 'Bio (optional)';

  @override
  String get editBioInputField => 'Enter bio';

  @override
  String get editFavoriteTagTitle => 'Select Favorite Tag';

  @override
  String get emptyPosts => 'There are no posts';

  @override
  String get searchEmptyResult => 'No results found for your search.';

  @override
  String get searchButton => 'Search';

  @override
  String get searchRestaurantTitle => 'Search Restaurants';

  @override
  String get searchUserTitle => 'User Search';

  @override
  String get searchUserHeader => 'User Search (by Post Count)';

  @override
  String searchUserPostCount(Object count) {
    return 'Posts: $count';
  }

  @override
  String get searchUserLatestPosts => 'Latest Posts';

  @override
  String get searchUserNoUsers => 'No users with posts found';

  @override
  String get unknown => 'Unknown・No Hits';

  @override
  String get profilePostCount => 'Posts';

  @override
  String get profilePointCount => 'Points';

  @override
  String get profileEditButton => 'Edit Profile';

  @override
  String get profileExchangePointsButton => 'Exchange Points';

  @override
  String get profileFavoriteGenre => 'Favorite Genre';

  @override
  String get likeButton => 'Like';

  @override
  String get shareReviewPrefix => 'Just shared my review of what I ate!';

  @override
  String get shareReviewSuffix => 'For more, take a look at foodGram!';

  @override
  String get postDetailSheetTitle => 'About this post';

  @override
  String get postDetailSheetShareButton => 'Share this post';

  @override
  String get postDetailSheetReportButton => 'Report this post';

  @override
  String get postDetailSheetBlockButton => 'Block this user';

  @override
  String get dialogYesButton => 'Yes';

  @override
  String get dialogNoButton => 'No';

  @override
  String get dialogReportTitle => 'Report a Post';

  @override
  String get dialogReportDescription1 => 'You will report this post.';

  @override
  String get dialogReportDescription2 => 'You will proceed to a Google Form.';

  @override
  String get dialogBlockTitle => 'Block Confirmation';

  @override
  String get dialogBlockDescription1 => 'Do you want to block this user?';

  @override
  String get dialogBlockDescription2 => 'This will hide the user\'s posts.';

  @override
  String get dialogBlockDescription3 => 'Blocked users will be saved locally.';

  @override
  String get dialogDeleteTitle => 'Delete Post';

  @override
  String get heartLimitMessage => 'You\'ve reached today\'s limit of 10 likes. Please try again tomorrow.';

  @override
  String get dialogDeleteDescription1 => 'Do you want to delete this post?';

  @override
  String get dialogDeleteDescription2 => 'Once deleted, it cannot be restored.';

  @override
  String get dialogDeleteError => 'Deletion failed.';

  @override
  String get dialogLogoutTitle => 'Confirm Logout';

  @override
  String get dialogLogoutDescription1 => 'Would you like to log out?';

  @override
  String get dialogLogoutDescription2 => 'Account status is stored on the server.';

  @override
  String get dialogLogoutButton => 'Logout';

  @override
  String get errorTitle => 'Communication Error';

  @override
  String get errorDescription1 => 'A connection error has occurred.';

  @override
  String get errorDescription2 => 'Check your network connection and try again.';

  @override
  String get errorRefreshButton => 'Reload';

  @override
  String get error => 'Errors have occurred';

  @override
  String get mapLoadingError => 'An error occurred';

  @override
  String get mapLoadingRestaurant => 'Getting restaurant information...';

  @override
  String get appShareTitle => 'Share';

  @override
  String get appShareStoreButton => 'Share this store';

  @override
  String get appShareInstagramButton => 'Share on Instagram';

  @override
  String get appShareGoButton => 'Go to this store';

  @override
  String get appShareCloseButton => 'Close';

  @override
  String get appRestaurantLabel => 'Search Restaurant';

  @override
  String get appRequestTitle => '🙇 Turn on the current location 🙇';

  @override
  String get appRequestReason => 'Current location data is required for restaurant selection';

  @override
  String get appRequestInduction => 'The following buttons take you to the settings screen';

  @override
  String get appRequestOpenSetting => 'Open the settings screen';

  @override
  String get appTitle => 'FoodGram';

  @override
  String get appSubtitle => 'Eat × Snap × Share';

  @override
  String get agreeToTheTermsOfUse => 'Please agree to the Terms of Use';

  @override
  String get restaurantCategoryList => 'Select a Cuisine by Country';

  @override
  String get cookingCategoryList => 'Select a food tag';

  @override
  String get restaurantReviewNew => 'New';

  @override
  String get restaurantReviewViewDetails => 'View Details';

  @override
  String get restaurantReviewOtherPosts => 'Other Posts';

  @override
  String get restaurantReviewReviewList => 'Review List';

  @override
  String get restaurantReviewError => 'An error occurred';

  @override
  String get nearbyRestaurants => '📍Nearby Restaurants';

  @override
  String get seeMore => 'See More';

  @override
  String get selectCountryTag => 'Select a Country Tag';

  @override
  String get selectFavoriteTag => 'Select Favorite Tag';

  @override
  String get favoriteTagPlaceholder => 'Select your favorite tag';

  @override
  String get selectFoodTag => 'Select Food Tag';

  @override
  String get tabHome => 'Food';

  @override
  String get tabMap => 'Map';

  @override
  String get tabSearch => 'Search';

  @override
  String get tabMyPage => 'My Page';

  @override
  String get tabSetting => 'Setting';

  @override
  String get logoutFailure => 'Logout failure';

  @override
  String get accountDeletionFailure => 'Account deletion failure';

  @override
  String get appleLoginFailure => 'Apple login not available';

  @override
  String get emailAuthenticationFailure => 'Email authentication failure';

  @override
  String get loginError => 'Login Error';

  @override
  String get loginSuccessful => 'Successful login';

  @override
  String get emailAuthentication => 'Authenticate with your email application';

  @override
  String get emailEmpty => 'No email address has been entered';

  @override
  String get email => 'Email Address';

  @override
  String get enterTheCorrectFormat => 'Please enter the correct format';

  @override
  String get authInvalidFormat => 'Email address format is incorrect.';

  @override
  String get authSocketException => 'There is a problem with the network. Please check the connection.';

  @override
  String get camera => 'Camera';

  @override
  String get album => 'Album';

  @override
  String get snsLogin => 'SNS login';

  @override
  String get tutorialFirstPageTitle => 'Share your delicious moments';

  @override
  String get tutorialFirstPageSubTitle => 'With FoodGram, make every meal more special.\nEnjoy discovering new flavors!';

  @override
  String get tutorialSecondPageTitle => 'A unique food map for this app';

  @override
  String get tutorialSecondPageSubTitle => 'Let\'s create a unique map for this app.\nYour posts will help evolve the map.';

  @override
  String get tutorialThirdPageTitle => 'Terms of Use';

  @override
  String get tutorialThirdPageSubTitle => '・Be cautious about sharing personal information, such as your name, address, phone number, or location.\n\n・Avoid posting offensive, inappropriate, or harmful content, and do not use others\' works without permission.\n\n・Non-food-related posts may be removed.\n\n・Users who repeatedly violate the rules or post objectionable content may be removed by the management team.\n\n・We look forward to improving this app together with everyone. by the developers';

  @override
  String get tutorialThirdPageButton => 'Agree to the terms of use';

  @override
  String get tutorialThirdPageClose => 'Close';

  @override
  String get detailMenuShare => 'Share';

  @override
  String get detailMenuVisit => 'Visit';

  @override
  String get detailMenuPost => 'Post';

  @override
  String get detailMenuSearch => 'Search';

  @override
  String get forceUpdateTitle => 'Update Notification';

  @override
  String get forceUpdateText => 'A new version of this app has been released. Please update the app to ensure the latest features and a secure environment.';

  @override
  String get forceUpdateButtonTitle => 'Update';

  @override
  String get newAccountImportantTitle => 'Important Note';

  @override
  String get newAccountImportant => 'When creating an account, please do not include personal information such as your email address or phone number in your username or user ID. To ensure a safe online experience, choose a name that does not reveal your personal details.';

  @override
  String get accountRegistrationSuccess => 'Account registration completed';

  @override
  String get accountRegistrationError => 'An error occurred';

  @override
  String get requiredInfoMissing => 'Required information is missing';

  @override
  String get shareTextAndImage => 'Share with text and image';

  @override
  String get shareImageOnly => 'Share image only';

  @override
  String get foodCategoryNoodles => 'Noodles';

  @override
  String get foodCategoryMeat => 'Meat';

  @override
  String get foodCategoryFastFood => 'Fast Food';

  @override
  String get foodCategoryRiceDishes => 'Rice Dishes';

  @override
  String get foodCategorySeafood => 'Seafood';

  @override
  String get foodCategoryBread => 'Bread';

  @override
  String get foodCategorySweetsAndSnacks => 'Sweets & Snacks';

  @override
  String get foodCategoryFruits => 'Fruits';

  @override
  String get foodCategoryVegetables => 'Vegetables';

  @override
  String get foodCategoryBeverages => 'Beverages';

  @override
  String get foodCategoryOthers => 'Others';

  @override
  String get foodCategoryAll => 'ALL';

  @override
  String get rankEmerald => 'Emerald';

  @override
  String get rankDiamond => 'Diamond';

  @override
  String get rankGold => 'Gold';

  @override
  String get rankSilver => 'Silver';

  @override
  String get rankBronze => 'Bronze';

  @override
  String get rank => 'Rank';

  @override
  String get promoteDialogTitle => '✨Become a Premium Member✨';

  @override
  String get promoteDialogTrophyTitle => 'Trophy Feature';

  @override
  String get promoteDialogTrophyDesc => 'Display trophies based on your activities.';

  @override
  String get promoteDialogTagTitle => 'Custom Tags';

  @override
  String get promoteDialogTagDesc => 'Set custom tags for your favorite foods.';

  @override
  String get promoteDialogIconTitle => 'Custom Icon';

  @override
  String get promoteDialogIconDesc => 'Set your profile icon to any image you like!!';

  @override
  String get promoteDialogAdTitle => 'Ad-Free';

  @override
  String get promoteDialogAdDesc => 'Remove all advertisements!!';

  @override
  String get promoteDialogButton => 'Become Premium';

  @override
  String get promoteDialogLater => 'Maybe Later';

  @override
  String get paywallTitle => 'FoodGram Premium';

  @override
  String get paywallPremiumTitle => '✨ Premium Benefits ✨';

  @override
  String get paywallTrophyTitle => 'Trophy Feature';

  @override
  String get paywallTrophyDesc => 'Display trophies based on activities';

  @override
  String get paywallTagTitle => 'Custom Tags';

  @override
  String get paywallTagDesc => 'Create unique tags for favorite foods';

  @override
  String get paywallIconTitle => 'Custom Icon';

  @override
  String get paywallIconDesc => 'Set your own profile icon';

  @override
  String get paywallAdTitle => 'Ad-Free';

  @override
  String get paywallAdDesc => 'Remove all advertisements';

  @override
  String get paywallComingSoon => 'Coming Soon...';

  @override
  String get paywallNewFeatures => 'New premium-exclusive features\ncoming soon!';

  @override
  String get paywallSubscribeButton => 'Become a Premium Member';

  @override
  String get paywallPrice => 'monthly  \$3 / month';

  @override
  String get paywallCancelNote => 'Cancel anytime';

  @override
  String get paywallWelcomeTitle => 'Welcome to\nFoodGram Members!';

  @override
  String get paywallSkip => 'Skip';

  @override
  String get purchaseError => 'An error occurred during purchase';

  @override
  String get anonymousPost => 'Post Anonymously';

  @override
  String get anonymousPostDescription => 'Username will be hidden';

  @override
  String get anonymousShare => 'Share Anonymously';

  @override
  String get anonymousUpdate => 'Update Anonymously';

  @override
  String get anonymousPoster => 'Anonymous Poster';

  @override
  String get anonymousUsername => 'foodgramer';

  @override
  String get tagOtherCuisine => 'Other Cuisine';

  @override
  String get tagOtherFood => 'Other Food';

  @override
  String get tagJapaneseCuisine => 'Japanese Cuisine';

  @override
  String get tagItalianCuisine => 'Italian Cuisine';

  @override
  String get tagFrenchCuisine => 'French Cuisine';

  @override
  String get tagChineseCuisine => 'Chinese Cuisine';

  @override
  String get tagIndianCuisine => 'Indian Cuisine';

  @override
  String get tagMexicanCuisine => 'Mexican Cuisine';

  @override
  String get tagHongKongCuisine => 'Hong Kong Cuisine';

  @override
  String get tagAmericanCuisine => 'American Cuisine';

  @override
  String get tagMediterraneanCuisine => 'Mediterranean Cuisine';

  @override
  String get tagThaiCuisine => 'Thai Cuisine';

  @override
  String get tagGreekCuisine => 'Greek Cuisine';

  @override
  String get tagTurkishCuisine => 'Turkish Cuisine';

  @override
  String get tagKoreanCuisine => 'Korean Cuisine';

  @override
  String get tagRussianCuisine => 'Russian Cuisine';

  @override
  String get tagSpanishCuisine => 'Spanish Cuisine';

  @override
  String get tagVietnameseCuisine => 'Vietnamese Cuisine';

  @override
  String get tagPortugueseCuisine => 'Portuguese Cuisine';

  @override
  String get tagAustrianCuisine => 'Austrian Cuisine';

  @override
  String get tagBelgianCuisine => 'Belgian Cuisine';

  @override
  String get tagSwedishCuisine => 'Swedish Cuisine';

  @override
  String get tagGermanCuisine => 'German Cuisine';

  @override
  String get tagBritishCuisine => 'British Cuisine';

  @override
  String get tagDutchCuisine => 'Dutch Cuisine';

  @override
  String get tagAustralianCuisine => 'Australian Cuisine';

  @override
  String get tagBrazilianCuisine => 'Brazilian Cuisine';

  @override
  String get tagArgentineCuisine => 'Argentine Cuisine';

  @override
  String get tagColombianCuisine => 'Colombian Cuisine';

  @override
  String get tagPeruvianCuisine => 'Peruvian Cuisine';

  @override
  String get tagNorwegianCuisine => 'Norwegian Cuisine';

  @override
  String get tagDanishCuisine => 'Danish Cuisine';

  @override
  String get tagPolishCuisine => 'Polish Cuisine';

  @override
  String get tagCzechCuisine => 'Czech Cuisine';

  @override
  String get tagHungarianCuisine => 'Hungarian Cuisine';

  @override
  String get tagSouthAfricanCuisine => 'South African Cuisine';

  @override
  String get tagEgyptianCuisine => 'Egyptian Cuisine';

  @override
  String get tagMoroccanCuisine => 'Moroccan Cuisine';

  @override
  String get tagNewZealandCuisine => 'New Zealand Cuisine';

  @override
  String get tagFilipinoCuisine => 'Filipino Cuisine';

  @override
  String get tagMalaysianCuisine => 'Malaysian Cuisine';

  @override
  String get tagSingaporeanCuisine => 'Singaporean Cuisine';

  @override
  String get tagIndonesianCuisine => 'Indonesian Cuisine';

  @override
  String get tagIranianCuisine => 'Iranian Cuisine';

  @override
  String get tagSaudiArabianCuisine => 'Saudi Arabian Cuisine';

  @override
  String get tagMongolianCuisine => 'Mongolian Cuisine';

  @override
  String get tagCambodianCuisine => 'Cambodian Cuisine';

  @override
  String get tagLaotianCuisine => 'Laotian Cuisine';

  @override
  String get tagCubanCuisine => 'Cuban Cuisine';

  @override
  String get tagJamaicanCuisine => 'Jamaican Cuisine';

  @override
  String get tagChileanCuisine => 'Chilean Cuisine';

  @override
  String get tagVenezuelanCuisine => 'Venezuelan Cuisine';

  @override
  String get tagPanamanianCuisine => 'Panamanian Cuisine';

  @override
  String get tagBolivianCuisine => 'Bolivian Cuisine';

  @override
  String get tagIcelandicCuisine => 'Icelandic Cuisine';

  @override
  String get tagLithuanianCuisine => 'Lithuanian Cuisine';

  @override
  String get tagEstonianCuisine => 'Estonian Cuisine';

  @override
  String get tagLatvianCuisine => 'Latvian Cuisine';

  @override
  String get tagFinnishCuisine => 'Finnish Cuisine';

  @override
  String get tagCroatianCuisine => 'Croatian Cuisine';

  @override
  String get tagSlovenianCuisine => 'Slovenian Cuisine';

  @override
  String get tagSlovakCuisine => 'Slovak Cuisine';

  @override
  String get tagRomanianCuisine => 'Romanian Cuisine';

  @override
  String get tagBulgarianCuisine => 'Bulgarian Cuisine';

  @override
  String get tagSerbianCuisine => 'Serbian Cuisine';

  @override
  String get tagAlbanianCuisine => 'Albanian Cuisine';

  @override
  String get tagGeorgianCuisine => 'Georgian Cuisine';

  @override
  String get tagArmenianCuisine => 'Armenian Cuisine';

  @override
  String get tagAzerbaijaniCuisine => 'Azerbaijani Cuisine';

  @override
  String get tagUkrainianCuisine => 'Ukrainian Cuisine';

  @override
  String get tagBelarusianCuisine => 'Belarusian Cuisine';

  @override
  String get tagKazakhCuisine => 'Kazakh Cuisine';

  @override
  String get tagUzbekCuisine => 'Uzbek Cuisine';

  @override
  String get tagKyrgyzCuisine => 'Kyrgyz Cuisine';

  @override
  String get tagTurkmenCuisine => 'Turkmen Cuisine';

  @override
  String get tagTajikCuisine => 'Tajik Cuisine';

  @override
  String get tagMaldivianCuisine => 'Maldivian Cuisine';

  @override
  String get tagNepaleseCuisine => 'Nepalese Cuisine';

  @override
  String get tagBangladeshiCuisine => 'Bangladeshi Cuisine';

  @override
  String get tagMyanmarCuisine => 'Myanmar Cuisine';

  @override
  String get tagBruneianCuisine => 'Bruneian Cuisine';

  @override
  String get tagTaiwaneseCuisine => 'Taiwanese Cuisine';

  @override
  String get tagNigerianCuisine => 'Nigerian Cuisine';

  @override
  String get tagKenyanCuisine => 'Kenyan Cuisine';

  @override
  String get tagGhanaianCuisine => 'Ghanaian Cuisine';

  @override
  String get tagEthiopianCuisine => 'Ethiopian Cuisine';

  @override
  String get tagSudaneseCuisine => 'Sudanese Cuisine';

  @override
  String get tagTunisianCuisine => 'Tunisian Cuisine';

  @override
  String get tagAngolanCuisine => 'Angolan Cuisine';

  @override
  String get tagCongoleseCuisine => 'Congolese Cuisine';

  @override
  String get tagZimbabweanCuisine => 'Zimbabwean Cuisine';

  @override
  String get tagMalagasyCuisine => 'Malagasy Cuisine';

  @override
  String get tagPapuaNewGuineanCuisine => 'Papua New Guinean Cuisine';

  @override
  String get tagSamoanCuisine => 'Samoan Cuisine';

  @override
  String get tagTuvaluanCuisine => 'Tuvaluan Cuisine';

  @override
  String get tagFijianCuisine => 'Fijian Cuisine';

  @override
  String get tagPalauanCuisine => 'Palauan Cuisine';

  @override
  String get tagKiribatiCuisine => 'Kiribati Cuisine';

  @override
  String get tagVanuatuanCuisine => 'Vanuatuan Cuisine';

  @override
  String get tagBahrainiCuisine => 'Bahraini Cuisine';

  @override
  String get tagQatariCuisine => 'Qatari Cuisine';

  @override
  String get tagKuwaitiCuisine => 'Kuwaiti Cuisine';

  @override
  String get tagOmaniCuisine => 'Omani Cuisine';

  @override
  String get tagYemeniCuisine => 'Yemeni Cuisine';

  @override
  String get tagLebaneseCuisine => 'Lebanese Cuisine';

  @override
  String get tagSyrianCuisine => 'Syrian Cuisine';

  @override
  String get tagJordanianCuisine => 'Jordanian Cuisine';

  @override
  String get tagNoodles => 'Noodles';

  @override
  String get tagMeatDishes => 'Meat Dishes';

  @override
  String get tagFastFood => 'Fast Food';

  @override
  String get tagRiceDishes => 'Rice Dishes';

  @override
  String get tagSeafood => 'Seafood';

  @override
  String get tagBread => 'Bread';

  @override
  String get tagSweetsAndSnacks => 'Sweets & Snacks';

  @override
  String get tagFruits => 'Fruits';

  @override
  String get tagVegetables => 'Vegetables';

  @override
  String get tagBeverages => 'Beverages';

  @override
  String get tagOthers => 'Others';

  @override
  String get tagPasta => 'Pasta';

  @override
  String get tagRamen => 'Ramen';

  @override
  String get tagSteak => 'Steak';

  @override
  String get tagYakiniku => 'Yakiniku';

  @override
  String get tagChicken => 'Chicken';

  @override
  String get tagBacon => 'Bacon';

  @override
  String get tagHamburger => 'Hamburger';

  @override
  String get tagFrenchFries => 'French Fries';

  @override
  String get tagPizza => 'Pizza';

  @override
  String get tagTacos => 'Tacos';

  @override
  String get tagTamales => 'Tamales';

  @override
  String get tagGyoza => 'Gyoza';

  @override
  String get tagFriedShrimp => 'Fried Shrimp';

  @override
  String get tagHotPot => 'Hot Pot';

  @override
  String get tagCurry => 'Curry';

  @override
  String get tagPaella => 'Paella';

  @override
  String get tagFondue => 'Fondue';

  @override
  String get tagOnigiri => 'Onigiri';

  @override
  String get tagRice => 'Rice';

  @override
  String get tagBento => 'Bento';

  @override
  String get tagSushi => 'Sushi';

  @override
  String get tagFish => 'Fish';

  @override
  String get tagOctopus => 'Octopus';

  @override
  String get tagSquid => 'Squid';

  @override
  String get tagShrimp => 'Shrimp';

  @override
  String get tagCrab => 'Crab';

  @override
  String get tagShellfish => 'Shellfish';

  @override
  String get tagOyster => 'Oyster';

  @override
  String get tagSandwich => 'Sandwich';

  @override
  String get tagHotDog => 'Hot Dog';

  @override
  String get tagDonut => 'Donut';

  @override
  String get tagPancake => 'Pancake';

  @override
  String get tagCroissant => 'Croissant';

  @override
  String get tagBagel => 'Bagel';

  @override
  String get tagBaguette => 'Baguette';

  @override
  String get tagPretzel => 'Pretzel';

  @override
  String get tagBurrito => 'Burrito';

  @override
  String get tagIceCream => 'Ice Cream';

  @override
  String get tagPudding => 'Pudding';

  @override
  String get tagRiceCracker => 'Rice Cracker';

  @override
  String get tagDango => 'Dango';

  @override
  String get tagShavedIce => 'Shaved Ice';

  @override
  String get tagPie => 'Pie';

  @override
  String get tagCupcake => 'Cupcake';

  @override
  String get tagCake => 'Cake';

  @override
  String get tagCandy => 'Candy';

  @override
  String get tagLollipop => 'Lollipop';

  @override
  String get tagChocolate => 'Chocolate';

  @override
  String get tagPopcorn => 'Popcorn';

  @override
  String get tagCookie => 'Cookie';

  @override
  String get tagPeanuts => 'Peanuts';

  @override
  String get tagBeans => 'Beans';

  @override
  String get tagChestnut => 'Chestnut';

  @override
  String get tagFortuneCookie => 'Fortune Cookie';

  @override
  String get tagMooncake => 'Mooncake';

  @override
  String get tagHoney => 'Honey';

  @override
  String get tagWaffle => 'Waffle';

  @override
  String get tagApple => 'Apple';

  @override
  String get tagPear => 'Pear';

  @override
  String get tagOrange => 'Orange';

  @override
  String get tagLemon => 'Lemon';

  @override
  String get tagLime => 'Lime';

  @override
  String get tagBanana => 'Banana';

  @override
  String get tagWatermelon => 'Watermelon';

  @override
  String get tagGrapes => 'Grapes';

  @override
  String get tagStrawberry => 'Strawberry';

  @override
  String get tagBlueberry => 'Blueberry';

  @override
  String get tagMelon => 'Melon';

  @override
  String get tagCherry => 'Cherry';

  @override
  String get tagPeach => 'Peach';

  @override
  String get tagMango => 'Mango';

  @override
  String get tagPineapple => 'Pineapple';

  @override
  String get tagCoconut => 'Coconut';

  @override
  String get tagKiwi => 'Kiwi';

  @override
  String get tagSalad => 'Salad';

  @override
  String get tagTomato => 'Tomato';

  @override
  String get tagEggplant => 'Eggplant';

  @override
  String get tagAvocado => 'Avocado';

  @override
  String get tagGreenBeans => 'Green Beans';

  @override
  String get tagBroccoli => 'Broccoli';

  @override
  String get tagLettuce => 'Lettuce';

  @override
  String get tagCucumber => 'Cucumber';

  @override
  String get tagChili => 'Chili';

  @override
  String get tagBellPepper => 'Bell Pepper';

  @override
  String get tagCorn => 'Corn';

  @override
  String get tagCarrot => 'Carrot';

  @override
  String get tagOlive => 'Olive';

  @override
  String get tagGarlic => 'Garlic';

  @override
  String get tagOnion => 'Onion';

  @override
  String get tagPotato => 'Potato';

  @override
  String get tagSweetPotato => 'Sweet Potato';

  @override
  String get tagGinger => 'Ginger';

  @override
  String get tagShiitake => 'Shiitake';

  @override
  String get tagTeapot => 'Teapot';

  @override
  String get tagCoffee => 'Coffee';

  @override
  String get tagTea => 'Tea';

  @override
  String get tagJuice => 'Juice';

  @override
  String get tagSoftDrink => 'Soft Drink';

  @override
  String get tagBubbleTea => 'Bubble Tea';

  @override
  String get tagSake => 'Sake';

  @override
  String get tagBeer => 'Beer';

  @override
  String get tagChampagne => 'Champagne';

  @override
  String get tagWine => 'Wine';

  @override
  String get tagWhiskey => 'Whiskey';

  @override
  String get tagCocktail => 'Cocktail';

  @override
  String get tagTropicalCocktail => 'Tropical Cocktail';

  @override
  String get tagMateTea => 'Mate Tea';

  @override
  String get tagMilk => 'Milk';

  @override
  String get tagKamaboko => 'Kamaboko';

  @override
  String get tagOden => 'Oden';

  @override
  String get tagCheese => 'Cheese';

  @override
  String get tagEgg => 'Egg';

  @override
  String get tagFriedEgg => 'Fried Egg';

  @override
  String get tagButter => 'Butter';

  @override
  String get done => 'Done';

  @override
  String get save => 'Save';

  @override
  String get searchFood => 'Search food';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get searchCountry => 'Search country';

  @override
  String get searchEmptyTitle => 'Enter restaurant name to search';

  @override
  String get searchEmptyHintTitle => 'Search Tips';

  @override
  String get searchEmptyHintLocation => 'Turn on location to show nearby results first';

  @override
  String get searchEmptyHintSearch => 'Search by restaurant name or cuisine type';

  @override
  String get postErrorPickImage => 'Failed to take photo';

  @override
  String get favoritePostEmptyTitle => 'No saved posts';

  @override
  String get favoritePostEmptySubtitle => 'Save posts that interest you!';

  @override
  String get userInfoFetchError => 'Failed to fetch user information';

  @override
  String get saved => 'Saved';

  @override
  String get savedPosts => 'Saved Posts';

  @override
  String get postSaved => 'Post saved';

  @override
  String get postSavedMessage => 'You can view saved posts in My Page';

  @override
  String get noMapAppAvailable => 'No map app available';

  @override
  String get posted => 'posted';
}
