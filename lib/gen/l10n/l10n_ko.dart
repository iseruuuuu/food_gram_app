// ignore_for_file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class L10nKo extends L10n {
  L10nKo([String locale = 'ko']) : super(locale);

  @override
  String get maybeNotFoodDialogTitle => '잠깐 확인 🍽️';

  @override
  String get maybeNotFoodDialogText =>
      '이 사진은 음식이 아닐 수도 있어요… 🤔\\n\\n그래도 게시하시겠어요?';

  @override
  String get maybeNotFoodDialogConfirm => '계속하기';

  @override
  String get maybeNotFoodDialogDelete => '이미지 삭제';

  @override
  String get close => '닫기';

  @override
  String get cancel => '취소';

  @override
  String get editTitle => '편집';

  @override
  String get editPostButton => '게시물 편집';

  @override
  String get emailInputField => '이메일 주소를 입력하세요';

  @override
  String get settingIcon => '아이콘 선택';

  @override
  String get userName => '사용자명';

  @override
  String get userNameInputField => '사용자명 (예: iseryu)';

  @override
  String get userId => '사용자 ID';

  @override
  String get userIdInputField => '사용자 ID (예: iseryuuu)';

  @override
  String get registerButton => '등록';

  @override
  String get settingAppBar => '설정';

  @override
  String get settingCheckVersion => '최신 버전 확인';

  @override
  String get settingCheckVersionDialogTitle => '업데이트 정보';

  @override
  String get settingCheckVersionDialogText1 => '새로운 버전이 사용 가능합니다.';

  @override
  String get settingCheckVersionDialogText2 => '최신 버전으로 업데이트해 주세요.';

  @override
  String get settingDeveloper => '트위터';

  @override
  String get settingGithub => 'Github';

  @override
  String get settingReview => '리뷰로 지원하기';

  @override
  String get settingShareApp => '이 앱 공유하기';

  @override
  String get settingLicense => '라이선스';

  @override
  String get settingFaq => 'FAQ';

  @override
  String get settingPrivacyPolicy => '개인정보처리방침';

  @override
  String get settingTermsOfUse => '이용약관';

  @override
  String get settingContact => '문의';

  @override
  String get settingTutorial => '튜토리얼';

  @override
  String get settingCredit => '크레딧';

  @override
  String get unregistered => '미등록';

  @override
  String get settingBatteryLevel => '배터리 레벨';

  @override
  String get settingDeviceInfo => '기기 정보';

  @override
  String get settingIosVersion => 'iOS 버전';

  @override
  String get settingAndroidSdk => 'SDK';

  @override
  String get settingAppVersion => '앱 버전';

  @override
  String get settingAccount => '계정';

  @override
  String get settingLogoutButton => '로그아웃';

  @override
  String get settingDeleteAccountButton => '계정 삭제 요청';

  @override
  String get settingQuestion => '질문함';

  @override
  String get settingAccountManagement => '계정 관리';

  @override
  String get settingRestoreSuccessTitle => '복원 성공';

  @override
  String get settingRestoreSuccessSubtitle => '프리미엄 기능이 활성화되었습니다!';

  @override
  String get settingRestoreFailureTitle => '복원 실패';

  @override
  String get settingRestoreFailureSubtitle => '구매 기록이 없나요? 지원팀에 문의하세요';

  @override
  String get settingRestore => '구매 복원';

  @override
  String get settingPremiumMembership => '프리미엄 회원이 되어 특별한 경험을';

  @override
  String get shareButton => '공유';

  @override
  String get postFoodName => '음식 이름';

  @override
  String get postFoodNameInputField => '음식 이름 입력(필수)';

  @override
  String get postRestaurantNameInputField => '레스토랑 추가(필수)';

  @override
  String get postComment => '댓글 입력(선택사항)';

  @override
  String get postCommentInputField => '댓글';

  @override
  String get postError => '제출 실패';

  @override
  String get postCategoryTitle => '국가/요리 태그 선택 (선택사항)';

  @override
  String get postCountryCategory => '국가';

  @override
  String get postCuisineCategory => '요리';

  @override
  String get postTitle => '게시';

  @override
  String get postMissingInfo => '모든 필수 항목을 입력해 주세요';

  @override
  String get postMissingPhoto => '사진을 추가해 주세요';

  @override
  String get postMissingFoodName => '먹은 것을 입력해 주세요';

  @override
  String get postMissingRestaurant => '레스토랑 이름을 추가해 주세요';

  @override
  String get postPhotoSuccess => '사진이 성공적으로 추가되었습니다';

  @override
  String get postCameraPermission => '카메라 권한이 필요합니다';

  @override
  String get postAlbumPermission => '사진 라이브러리 권한이 필요합니다';

  @override
  String get postSuccess => '게시 성공';

  @override
  String get postSearchError => '장소 이름을 검색할 수 없습니다';

  @override
  String get editUpdateButton => '업데이트';

  @override
  String get editBio => '소개 (선택사항)';

  @override
  String get editBioInputField => '소개 입력';

  @override
  String get editFavoriteTagTitle => '즐겨찾기 태그 선택';

  @override
  String get emptyPosts => '게시물이 없습니다';

  @override
  String get searchEmptyResult => '검색 결과를 찾을 수 없습니다.';

  @override
  String get searchButton => '검색';

  @override
  String get searchTitle => '검색';

  @override
  String get searchRestaurantTitle => '레스토랑 검색';

  @override
  String get searchUserTitle => '사용자 검색';

  @override
  String get searchUserHeader => '사용자 검색 (게시물 수순)';

  @override
  String searchUserPostCount(Object count) {
    return '게시물: $count개';
  }

  @override
  String get searchUserLatestPosts => '최신 게시물';

  @override
  String get searchUserNoUsers => '게시물이 있는 사용자를 찾을 수 없습니다';

  @override
  String get unknown => '알 수 없음・검색 결과 없음';

  @override
  String get profilePostCount => '게시물';

  @override
  String get profilePointCount => '포인트';

  @override
  String get profileEditButton => '프로필 편집';

  @override
  String get profileExchangePointsButton => '포인트 교환';

  @override
  String get profileFavoriteGenre => '즐겨찾기 장르';

  @override
  String get likeButton => '좋아요';

  @override
  String get shareReviewPrefix => '먹은 것의 리뷰를 공유했습니다!';

  @override
  String get shareReviewSuffix => '더 자세한 내용은 foodGram에서 확인해보세요!';

  @override
  String get postDetailSheetTitle => '이 게시물에 대해';

  @override
  String get postDetailSheetShareButton => '이 게시물 공유';

  @override
  String get postDetailSheetReportButton => '이 게시물 신고';

  @override
  String get postDetailSheetBlockButton => '이 사용자 차단';

  @override
  String get dialogYesButton => '예';

  @override
  String get dialogNoButton => '아니오';

  @override
  String get dialogReportTitle => '게시물 신고';

  @override
  String get dialogReportDescription1 => '이 게시물을 신고합니다.';

  @override
  String get dialogReportDescription2 => 'Google 폼으로 이동합니다.';

  @override
  String get dialogBlockTitle => '차단 확인';

  @override
  String get dialogBlockDescription1 => '이 사용자를 차단하시겠습니까?';

  @override
  String get dialogBlockDescription2 => '이 사용자의 게시물이 숨겨집니다.';

  @override
  String get dialogBlockDescription3 => '차단된 사용자는 로컬에 저장됩니다.';

  @override
  String get dialogDeleteTitle => '게시물 삭제';

  @override
  String get heartLimitMessage => '오늘의 좋아요 10개 한도에 도달했습니다. 내일 다시 시도해 주세요.';

  @override
  String get dialogDeleteDescription1 => '이 게시물을 삭제하시겠습니까?';

  @override
  String get dialogDeleteDescription2 => '삭제하면 복원할 수 없습니다.';

  @override
  String get dialogDeleteError => '삭제에 실패했습니다.';

  @override
  String get dialogLogoutTitle => '로그아웃 확인';

  @override
  String get dialogLogoutDescription1 => '로그아웃하시겠습니까?';

  @override
  String get dialogLogoutDescription2 => '계정 상태는 서버에 저장됩니다.';

  @override
  String get dialogLogoutButton => '로그아웃';

  @override
  String get errorTitle => '통신 오류';

  @override
  String get errorDescription1 => '연결 오류가 발생했습니다.';

  @override
  String get errorDescription2 => '네트워크 연결을 확인하고 다시 시도해 주세요.';

  @override
  String get errorRefreshButton => '새로고침';

  @override
  String get error => '오류가 발생했습니다';

  @override
  String get mapLoadingError => '오류가 발생했습니다';

  @override
  String get mapLoadingRestaurant => '레스토랑 정보를 가져오는 중...';

  @override
  String get appShareTitle => '공유';

  @override
  String get appShareStoreButton => '이 가게 공유';

  @override
  String get appShareInstagramButton => 'Instagram에서 공유';

  @override
  String get appShareGoButton => '이 가게로 가기';

  @override
  String get appShareCloseButton => '닫기';

  @override
  String get shareInviteMessage => '맛있는 음식을 FoodGram에서 공유해요!';

  @override
  String get appRestaurantLabel => '레스토랑 검색';

  @override
  String get appRequestTitle => '🙇 현재 위치를 켜주세요 🙇';

  @override
  String get appRequestReason => '레스토랑 선택에는 현재 위치 데이터가 필요합니다';

  @override
  String get appRequestInduction => '다음 버튼으로 설정 화면으로 이동합니다';

  @override
  String get appRequestOpenSetting => '설정 화면 열기';

  @override
  String get appTitle => 'FoodGram';

  @override
  String get appSubtitle => '먹기 × 찍기 × 공유';

  @override
  String get agreeToTheTermsOfUse => '이용약관에 동의해 주세요';

  @override
  String get restaurantCategoryList => '국가별 요리 선택';

  @override
  String get cookingCategoryList => '음식 태그 선택';

  @override
  String get restaurantReviewNew => '신규';

  @override
  String get restaurantReviewViewDetails => '자세히 보기';

  @override
  String get restaurantReviewOtherPosts => '다른 게시물';

  @override
  String get restaurantReviewReviewList => '리뷰 목록';

  @override
  String get restaurantReviewError => '오류가 발생했습니다';

  @override
  String get nearbyRestaurants => '📍주변 레스토랑';

  @override
  String get seeMore => '더 보기';

  @override
  String get selectCountryTag => '국가 태그 선택';

  @override
  String get selectFavoriteTag => '즐겨찾기 태그 선택';

  @override
  String get favoriteTagPlaceholder => '즐겨찾기 태그 선택';

  @override
  String get selectFoodTag => '음식 태그 선택';

  @override
  String get tabHome => '음식';

  @override
  String get tabMap => '지도';

  @override
  String get tabMyMap => '내 지도';

  @override
  String get tabSearch => '검색';

  @override
  String get tabMyPage => '마이페이지';

  @override
  String get tabSetting => '설정';

  @override
  String get mapStatsVisitedArea => '방문 지역';

  @override
  String get mapStatsPosts => '게시물';

  @override
  String get mapStatsActivityDays => '활동 일수';

  @override
  String get dayUnit => '일';

  @override
  String get mapStatsPrefectures => '도도부현';

  @override
  String get mapStatsAchievementRate => '달성률';

  @override
  String get mapStatsVisitedCountries => '방문 국가';

  @override
  String get mapViewTypeRecord => '기록';

  @override
  String get mapViewTypeJapan => '일본';

  @override
  String get mapViewTypeWorld => '세계';

  @override
  String get logoutFailure => '로그아웃 실패';

  @override
  String get accountDeletionFailure => '계정 삭제 실패';

  @override
  String get appleLoginFailure => 'Apple 로그인을 사용할 수 없습니다';

  @override
  String get emailAuthenticationFailure => '이메일 인증 실패';

  @override
  String get loginError => '로그인 오류';

  @override
  String get loginSuccessful => '로그인 성공';

  @override
  String get emailAuthentication => '이메일 앱으로 인증하세요';

  @override
  String get emailEmpty => '이메일 주소가 입력되지 않았습니다';

  @override
  String get email => '이메일 주소';

  @override
  String get enterTheCorrectFormat => '올바른 형식으로 입력해 주세요';

  @override
  String get authInvalidFormat => '이메일 주소 형식이 잘못되었습니다.';

  @override
  String get authSocketException => '네트워크에 문제가 있습니다. 연결을 확인해 주세요.';

  @override
  String get camera => '카메라';

  @override
  String get album => '앨범';

  @override
  String get snsLogin => 'SNS 로그인';

  @override
  String get tutorialFirstPageTitle => '맛있는 순간을 공유하세요';

  @override
  String get tutorialFirstPageSubTitle =>
      'FoodGram으로 매 식사가 더욱 특별해집니다.\n새로운 맛을 발견하는 즐거움을 경험하세요!';

  @override
  String get tutorialDiscoverTitle => '다음 최애 한 접시를 찾아보세요!';

  @override
  String get tutorialDiscoverSubTitle => '스크롤할 때마다 새로운 맛 발견.\n지금 맛있는 음식을 탐험해요.';

  @override
  String get tutorialSecondPageTitle => '이 앱만의 독특한 음식 지도';

  @override
  String get tutorialSecondPageSubTitle =>
      '이 앱만의 독특한 지도를 만들어보세요.\n여러분의 게시물이 지도를 발전시킵니다.';

  @override
  String get tutorialThirdPageTitle => '이용약관';

  @override
  String get tutorialThirdPageSubTitle =>
      '・이름, 주소, 전화번호, 위치 등 개인정보 공유에 주의하세요.\n\n・공격적이거나 부적절하거나 유해한 콘텐츠 게시를 피하고, 허가 없이 타인의 작품을 사용하지 마세요.\n\n・음식과 관련 없는 게시물은 삭제될 수 있습니다.\n\n・규칙을 반복적으로 위반하거나 불쾌한 콘텐츠를 게시하는 사용자는 관리팀에 의해 제거될 수 있습니다.\n\n・모든 분과 함께 이 앱을 개선해 나갈 수 있기를 기대합니다. 개발자';

  @override
  String get tutorialThirdPageButton => '이용약관에 동의';

  @override
  String get tutorialThirdPageClose => '닫기';

  @override
  String get detailMenuShare => '공유';

  @override
  String get detailMenuVisit => '방문';

  @override
  String get detailMenuPost => '게시';

  @override
  String get detailMenuSearch => '검색';

  @override
  String get forceUpdateTitle => '업데이트 알림';

  @override
  String get forceUpdateText =>
      '이 앱의 새 버전이 출시되었습니다. 최신 기능과 안전한 환경을 위해 앱을 업데이트해 주세요.';

  @override
  String get forceUpdateButtonTitle => '업데이트';

  @override
  String get newAccountImportantTitle => '중요한 참고사항';

  @override
  String get newAccountImportant =>
      '계정을 만들 때 사용자명이나 사용자 ID에 이메일 주소나 전화번호와 같은 개인정보를 포함하지 마세요. 안전한 온라인 경험을 위해 개인정보가 드러나지 않는 이름을 선택하세요.';

  @override
  String get accountRegistrationSuccess => '계정 등록이 완료되었습니다';

  @override
  String get accountRegistrationError => '오류가 발생했습니다';

  @override
  String get requiredInfoMissing => '필수 정보가 누락되었습니다';

  @override
  String get shareTextAndImage => '텍스트와 이미지로 공유';

  @override
  String get shareImageOnly => '이미지만 공유';

  @override
  String get foodCategoryNoodles => '면류';

  @override
  String get foodCategoryMeat => '고기';

  @override
  String get foodCategoryFastFood => '패스트푸드';

  @override
  String get foodCategoryRiceDishes => '밥 요리';

  @override
  String get foodCategorySeafood => '해산물';

  @override
  String get foodCategoryBread => '빵';

  @override
  String get foodCategorySweetsAndSnacks => '간식';

  @override
  String get foodCategoryFruits => '과일';

  @override
  String get foodCategoryVegetables => '채소';

  @override
  String get foodCategoryBeverages => '음료';

  @override
  String get foodCategoryOthers => '기타';

  @override
  String get foodCategoryAll => '전체';

  @override
  String get rankEmerald => '에메랄드';

  @override
  String get rankDiamond => '다이아몬드';

  @override
  String get rankGold => '골드';

  @override
  String get rankSilver => '실버';

  @override
  String get rankBronze => '브론즈';

  @override
  String get rank => '랭크';

  @override
  String get promoteDialogTitle => '✨프리미엄 회원이 되세요✨';

  @override
  String get promoteDialogTrophyTitle => '트로피 기능';

  @override
  String get promoteDialogTrophyDesc => '활동에 따라 트로피를 표시합니다.';

  @override
  String get promoteDialogTagTitle => '커스텀 태그';

  @override
  String get promoteDialogTagDesc => '즐겨찾기 음식에 커스텀 태그를 설정할 수 있습니다.';

  @override
  String get promoteDialogIconTitle => '커스텀 아이콘';

  @override
  String get promoteDialogIconDesc => '프로필 아이콘을 원하는 이미지로 설정할 수 있습니다!!';

  @override
  String get promoteDialogAdTitle => '광고 없음';

  @override
  String get promoteDialogAdDesc => '모든 광고가 제거됩니다!!';

  @override
  String get promoteDialogButton => '프리미엄 회원 되기';

  @override
  String get promoteDialogLater => '나중에';

  @override
  String get paywallTitle => 'FoodGram 프리미엄';

  @override
  String get paywallPremiumTitle => '✨ 프리미엄 혜택 ✨';

  @override
  String get paywallTrophyTitle => '게시물이 늘수록 칭호 획득';

  @override
  String get paywallTrophyDesc => '게시물 수에 따라 칭호가 업그레이드';

  @override
  String get paywallTagTitle => '좋아하는 장르 설정';

  @override
  String get paywallTagDesc => '프로필을 더 세련되게 꾸미기';

  @override
  String get paywallIconTitle => '원하는 이미지를 아이콘으로';

  @override
  String get paywallIconDesc => '다른 게시자보다 눈에 띄어요';

  @override
  String get paywallAdTitle => '광고 없음';

  @override
  String get paywallAdDesc => '모든 광고 제거';

  @override
  String get paywallComingSoon => 'Coming Soon...';

  @override
  String get paywallNewFeatures => '프리미엄 전용 신기능이\n곧 출시됩니다!';

  @override
  String get paywallSubscribeButton => '프리미엄 회원 되기';

  @override
  String get paywallPrice => '월 \$3 / 월';

  @override
  String get paywallCancelNote => '언제든지 취소 가능';

  @override
  String get paywallWelcomeTitle => 'FoodGram 멤버에\n오신 것을 환영합니다!';

  @override
  String get paywallSkip => '건너뛰기';

  @override
  String get purchaseError => '구매 중 오류가 발생했습니다';

  @override
  String get paywallTagline => '✨ 음식 경험을 업그레이드 ✨';

  @override
  String get paywallMapTitle => '지도로 찾기';

  @override
  String get paywallMapDesc => '식당을 더 빠르고 쉽게 찾기';

  @override
  String get paywallRankTitle => '게시물이 늘수록 칭호 획득';

  @override
  String get paywallRankDesc => '게시물 수에 따라 칭호가 업그레이드';

  @override
  String get paywallGenreTitle => '좋아하는 장르 설정';

  @override
  String get paywallGenreDesc => '프로필을 더 세련되게 꾸미기';

  @override
  String get paywallCustomIconTitle => '원하는 이미지를 아이콘으로';

  @override
  String get paywallCustomIconDesc => '다른 게시자보다 눈에 띄어요';

  @override
  String get anonymousPost => '익명으로 게시';

  @override
  String get anonymousPostDescription => '사용자명이 숨겨집니다';

  @override
  String get anonymousShare => '익명으로 공유';

  @override
  String get anonymousUpdate => '익명으로 업데이트';

  @override
  String get anonymousPoster => '익명 게시자';

  @override
  String get anonymousUsername => 'foodgramer';

  @override
  String get tagOtherCuisine => '기타 요리';

  @override
  String get tagOtherFood => '기타 음식';

  @override
  String get tagJapaneseCuisine => '일본 요리';

  @override
  String get tagItalianCuisine => '이탈리아 요리';

  @override
  String get tagFrenchCuisine => '프랑스 요리';

  @override
  String get tagChineseCuisine => '중국 요리';

  @override
  String get tagIndianCuisine => '인도 요리';

  @override
  String get tagMexicanCuisine => '멕시코 요리';

  @override
  String get tagHongKongCuisine => '홍콩 요리';

  @override
  String get tagAmericanCuisine => '미국 요리';

  @override
  String get tagMediterraneanCuisine => '지중해 요리';

  @override
  String get tagThaiCuisine => '태국 요리';

  @override
  String get tagGreekCuisine => '그리스 요리';

  @override
  String get tagTurkishCuisine => '터키 요리';

  @override
  String get tagKoreanCuisine => '한국 요리';

  @override
  String get tagRussianCuisine => '러시아 요리';

  @override
  String get tagSpanishCuisine => '스페인 요리';

  @override
  String get tagVietnameseCuisine => '베트남 요리';

  @override
  String get tagPortugueseCuisine => '포르투갈 요리';

  @override
  String get tagAustrianCuisine => '오스트리아 요리';

  @override
  String get tagBelgianCuisine => '벨기에 요리';

  @override
  String get tagSwedishCuisine => '스웨덴 요리';

  @override
  String get tagGermanCuisine => '독일 요리';

  @override
  String get tagBritishCuisine => '영국 요리';

  @override
  String get tagDutchCuisine => '네덜란드 요리';

  @override
  String get tagAustralianCuisine => '호주 요리';

  @override
  String get tagBrazilianCuisine => '브라질 요리';

  @override
  String get tagArgentineCuisine => '아르헨티나 요리';

  @override
  String get tagColombianCuisine => '콜롬비아 요리';

  @override
  String get tagPeruvianCuisine => '페루 요리';

  @override
  String get tagNorwegianCuisine => '노르웨이 요리';

  @override
  String get tagDanishCuisine => '덴마크 요리';

  @override
  String get tagPolishCuisine => '폴란드 요리';

  @override
  String get tagCzechCuisine => '체코 요리';

  @override
  String get tagHungarianCuisine => '헝가리 요리';

  @override
  String get tagSouthAfricanCuisine => '남아프리카 요리';

  @override
  String get tagEgyptianCuisine => '이집트 요리';

  @override
  String get tagMoroccanCuisine => '모로코 요리';

  @override
  String get tagNewZealandCuisine => '뉴질랜드 요리';

  @override
  String get tagFilipinoCuisine => '필리핀 요리';

  @override
  String get tagMalaysianCuisine => '말레이시아 요리';

  @override
  String get tagSingaporeanCuisine => '싱가포르 요리';

  @override
  String get tagIndonesianCuisine => '인도네시아 요리';

  @override
  String get tagIranianCuisine => '이란 요리';

  @override
  String get tagSaudiArabianCuisine => '사우디아라비아 요리';

  @override
  String get tagMongolianCuisine => '몽골 요리';

  @override
  String get tagCambodianCuisine => '캄보디아 요리';

  @override
  String get tagLaotianCuisine => '라오스 요리';

  @override
  String get tagCubanCuisine => '쿠바 요리';

  @override
  String get tagJamaicanCuisine => '자메이카 요리';

  @override
  String get tagChileanCuisine => '칠레 요리';

  @override
  String get tagVenezuelanCuisine => '베네수엘라 요리';

  @override
  String get tagPanamanianCuisine => '파나마 요리';

  @override
  String get tagBolivianCuisine => '볼리비아 요리';

  @override
  String get tagIcelandicCuisine => '아이슬란드 요리';

  @override
  String get tagLithuanianCuisine => '리투아니아 요리';

  @override
  String get tagEstonianCuisine => '에스토니아 요리';

  @override
  String get tagLatvianCuisine => '라트비아 요리';

  @override
  String get tagFinnishCuisine => '핀란드 요리';

  @override
  String get tagCroatianCuisine => '크로아티아 요리';

  @override
  String get tagSlovenianCuisine => '슬로베니아 요리';

  @override
  String get tagSlovakCuisine => '슬로바키아 요리';

  @override
  String get tagRomanianCuisine => '루마니아 요리';

  @override
  String get tagBulgarianCuisine => '불가리아 요리';

  @override
  String get tagSerbianCuisine => '세르비아 요리';

  @override
  String get tagAlbanianCuisine => '알바니아 요리';

  @override
  String get tagGeorgianCuisine => '조지아 요리';

  @override
  String get tagArmenianCuisine => '아르메니아 요리';

  @override
  String get tagAzerbaijaniCuisine => '아제르바이잔 요리';

  @override
  String get tagUkrainianCuisine => '우크라이나 요리';

  @override
  String get tagBelarusianCuisine => '벨라루스 요리';

  @override
  String get tagKazakhCuisine => '카자흐스탄 요리';

  @override
  String get tagUzbekCuisine => '우즈베키스탄 요리';

  @override
  String get tagKyrgyzCuisine => '키르기스스탄 요리';

  @override
  String get tagTurkmenCuisine => '투르크메니스탄 요리';

  @override
  String get tagTajikCuisine => '타지키스탄 요리';

  @override
  String get tagMaldivianCuisine => '몰디브 요리';

  @override
  String get tagNepaleseCuisine => '네팔 요리';

  @override
  String get tagBangladeshiCuisine => '방글라데시 요리';

  @override
  String get tagMyanmarCuisine => '미얀마 요리';

  @override
  String get tagBruneianCuisine => '브루나이 요리';

  @override
  String get tagTaiwaneseCuisine => '대만 요리';

  @override
  String get tagNigerianCuisine => '나이지리아 요리';

  @override
  String get tagKenyanCuisine => '케냐 요리';

  @override
  String get tagGhanaianCuisine => '가나 요리';

  @override
  String get tagEthiopianCuisine => '에티오피아 요리';

  @override
  String get tagSudaneseCuisine => '수단 요리';

  @override
  String get tagTunisianCuisine => '튀니지 요리';

  @override
  String get tagAngolanCuisine => '앙골라 요리';

  @override
  String get tagCongoleseCuisine => '콩고 요리';

  @override
  String get tagZimbabweanCuisine => '짐바브웨 요리';

  @override
  String get tagMalagasyCuisine => '마다가스카르 요리';

  @override
  String get tagPapuaNewGuineanCuisine => '파푸아뉴기니 요리';

  @override
  String get tagSamoanCuisine => '사모아 요리';

  @override
  String get tagTuvaluanCuisine => '투발루 요리';

  @override
  String get tagFijianCuisine => '피지 요리';

  @override
  String get tagPalauanCuisine => '팔라우 요리';

  @override
  String get tagKiribatiCuisine => '키리바시 요리';

  @override
  String get tagVanuatuanCuisine => '바누아투 요리';

  @override
  String get tagBahrainiCuisine => '바레인 요리';

  @override
  String get tagQatariCuisine => '카타르 요리';

  @override
  String get tagKuwaitiCuisine => '쿠웨이트 요리';

  @override
  String get tagOmaniCuisine => '오만 요리';

  @override
  String get tagYemeniCuisine => '예멘 요리';

  @override
  String get tagLebaneseCuisine => '레바논 요리';

  @override
  String get tagSyrianCuisine => '시리아 요리';

  @override
  String get tagJordanianCuisine => '요르단 요리';

  @override
  String get tagNoodles => '면류';

  @override
  String get tagMeatDishes => '고기 요리';

  @override
  String get tagFastFood => '패스트푸드';

  @override
  String get tagRiceDishes => '밥 요리';

  @override
  String get tagSeafood => '해산물';

  @override
  String get tagBread => '빵';

  @override
  String get tagSweetsAndSnacks => '간식';

  @override
  String get tagFruits => '과일';

  @override
  String get tagVegetables => '채소';

  @override
  String get tagBeverages => '음료';

  @override
  String get tagOthers => '기타';

  @override
  String get tagPasta => '파스타';

  @override
  String get tagRamen => '라멘';

  @override
  String get tagSteak => '스테이크';

  @override
  String get tagYakiniku => '야키니쿠';

  @override
  String get tagChicken => '치킨';

  @override
  String get tagBacon => '베이컨';

  @override
  String get tagHamburger => '햄버거';

  @override
  String get tagFrenchFries => '프렌치프라이';

  @override
  String get tagPizza => '피자';

  @override
  String get tagTacos => '타코';

  @override
  String get tagTamales => '타말레';

  @override
  String get tagGyoza => '교자';

  @override
  String get tagFriedShrimp => '새우튀김';

  @override
  String get tagHotPot => '훠궈';

  @override
  String get tagCurry => '카레';

  @override
  String get tagPaella => '파에야';

  @override
  String get tagFondue => '퐁듀';

  @override
  String get tagOnigiri => '오니기리';

  @override
  String get tagRice => '밥';

  @override
  String get tagBento => '도시락';

  @override
  String get tagSushi => '스시';

  @override
  String get tagFish => '생선';

  @override
  String get tagOctopus => '문어';

  @override
  String get tagSquid => '오징어';

  @override
  String get tagShrimp => '새우';

  @override
  String get tagCrab => '게';

  @override
  String get tagShellfish => '조개';

  @override
  String get tagOyster => '굴';

  @override
  String get tagSandwich => '샌드위치';

  @override
  String get tagHotDog => '핫도그';

  @override
  String get tagDonut => '도넛';

  @override
  String get tagPancake => '팬케이크';

  @override
  String get tagCroissant => '크루아상';

  @override
  String get tagBagel => '베이글';

  @override
  String get tagBaguette => '바게트';

  @override
  String get tagPretzel => '프레첼';

  @override
  String get tagBurrito => '부리토';

  @override
  String get tagIceCream => '아이스크림';

  @override
  String get tagPudding => '푸딩';

  @override
  String get tagRiceCracker => '과자';

  @override
  String get tagDango => '단고';

  @override
  String get tagShavedIce => '빙수';

  @override
  String get tagPie => '파이';

  @override
  String get tagCupcake => '컵케이크';

  @override
  String get tagCake => '케이크';

  @override
  String get tagCandy => '사탕';

  @override
  String get tagLollipop => '롤리팝';

  @override
  String get tagChocolate => '초콜릿';

  @override
  String get tagPopcorn => '팝콘';

  @override
  String get tagCookie => '쿠키';

  @override
  String get tagPeanuts => '땅콩';

  @override
  String get tagBeans => '콩';

  @override
  String get tagChestnut => '밤';

  @override
  String get tagFortuneCookie => '포춘쿠키';

  @override
  String get tagMooncake => '월병';

  @override
  String get tagHoney => '꿀';

  @override
  String get tagWaffle => '와플';

  @override
  String get tagApple => '사과';

  @override
  String get tagPear => '배';

  @override
  String get tagOrange => '오렌지';

  @override
  String get tagLemon => '레몬';

  @override
  String get tagLime => '라임';

  @override
  String get tagBanana => '바나나';

  @override
  String get tagWatermelon => '수박';

  @override
  String get tagGrapes => '포도';

  @override
  String get tagStrawberry => '딸기';

  @override
  String get tagBlueberry => '블루베리';

  @override
  String get tagMelon => '멜론';

  @override
  String get tagCherry => '체리';

  @override
  String get tagPeach => '복숭아';

  @override
  String get tagMango => '망고';

  @override
  String get tagPineapple => '파인애플';

  @override
  String get tagCoconut => '코코넛';

  @override
  String get tagKiwi => '키위';

  @override
  String get tagSalad => '샐러드';

  @override
  String get tagTomato => '토마토';

  @override
  String get tagEggplant => '가지';

  @override
  String get tagAvocado => '아보카도';

  @override
  String get tagGreenBeans => '강낭콩';

  @override
  String get tagBroccoli => '브로콜리';

  @override
  String get tagLettuce => '상추';

  @override
  String get tagCucumber => '오이';

  @override
  String get tagChili => '고추';

  @override
  String get tagBellPepper => '파프리카';

  @override
  String get tagCorn => '옥수수';

  @override
  String get tagCarrot => '당근';

  @override
  String get tagOlive => '올리브';

  @override
  String get tagGarlic => '마늘';

  @override
  String get tagOnion => '양파';

  @override
  String get tagPotato => '감자';

  @override
  String get tagSweetPotato => '고구마';

  @override
  String get tagGinger => '생강';

  @override
  String get tagShiitake => '표고버섯';

  @override
  String get tagTeapot => '찻주전자';

  @override
  String get tagCoffee => '커피';

  @override
  String get tagTea => '차';

  @override
  String get tagJuice => '주스';

  @override
  String get tagSoftDrink => '탄산음료';

  @override
  String get tagBubbleTea => '버블티';

  @override
  String get tagSake => '사케';

  @override
  String get tagBeer => '맥주';

  @override
  String get tagChampagne => '샴페인';

  @override
  String get tagWine => '와인';

  @override
  String get tagWhiskey => '위스키';

  @override
  String get tagCocktail => '칵테일';

  @override
  String get tagTropicalCocktail => '트로피컬 칵테일';

  @override
  String get tagMateTea => '마테차';

  @override
  String get tagMilk => '우유';

  @override
  String get tagKamaboko => '가마보코';

  @override
  String get tagOden => '오뎅';

  @override
  String get tagCheese => '치즈';

  @override
  String get tagEgg => '계란';

  @override
  String get tagFriedEgg => '계란프라이';

  @override
  String get tagButter => '버터';

  @override
  String get done => '완료';

  @override
  String get save => '저장';

  @override
  String get searchFood => '음식 검색';

  @override
  String get noResultsFound => '검색 결과를 찾을 수 없습니다';

  @override
  String get searchCountry => '국가 검색';

  @override
  String get searchEmptyTitle => '레스토랑 이름을 입력하여 검색하세요';

  @override
  String get searchEmptyHintTitle => '검색 팁';

  @override
  String get searchEmptyHintLocation => '위치를 켜면 가까운 결과가 먼저 표시됩니다';

  @override
  String get searchEmptyHintSearch => '레스토랑 이름이나 요리 유형으로 검색하세요';

  @override
  String get postErrorPickImage => '사진 촬영에 실패했습니다';

  @override
  String get favoritePostEmptyTitle => '저장된 게시물이 없습니다';

  @override
  String get favoritePostEmptySubtitle => '관심 있는 게시물을 저장해보세요!';

  @override
  String get userInfoFetchError => '사용자 정보를 가져오는데 실패했습니다';

  @override
  String get saved => '저장됨';

  @override
  String get savedPosts => '저장된 게시물';

  @override
  String get postSaved => '게시물이 저장되었습니다';

  @override
  String get postSavedMessage => '마이페이지에서 저장된 게시물을 확인할 수 있습니다';

  @override
  String get noMapAppAvailable => '지도 앱을 사용할 수 없습니다';

  @override
  String get notificationLunchTitle => '#오늘의 식사, 이미 올렸나요? 🍜';

  @override
  String get notificationLunchBody => '오늘의 점심, 맛을 까먹기 전에 기록해볼까요?';

  @override
  String get notificationDinnerTitle => '#오늘의 식사, 이미 올렸나요? 🍛';

  @override
  String get notificationDinnerBody => '오늘의 식사를 올리고 하루를 편안하게 마무리해보세요 📷';

  @override
  String get posted => '에 게시';

  @override
  String get tutorialLocationTitle => '위치를 켜세요!';

  @override
  String get tutorialLocationSubTitle => '주변의 멋진 장소를 찾기 위해,\n레스토랑 탐색을 더 쉽게';

  @override
  String get tutorialLocationButton => '위치 활성화';

  @override
  String get tutorialNotificationTitle => '알림을 켜세요!';

  @override
  String get tutorialNotificationSubTitle => '점심/저녁 시간에 알림을 보냅니다';

  @override
  String get tutorialNotificationButton => '알림 활성화';

  @override
  String get selectMapApp => '지도 앱 선택';

  @override
  String get mapAppGoogle => '구글 맵';

  @override
  String get mapAppApple => '애플 맵';

  @override
  String get mapAppBaidu => '바이두 맵';

  @override
  String get mapAppMapsMe => 'Maps.me';

  @override
  String get mapAppKakao => '카카오맵';

  @override
  String get mapAppNaver => '네이버 지도';

  @override
  String get streakDialogFirstTitle => '게시 완료';

  @override
  String get streakDialogFirstContent => '계속 게시하면\n연속 게시 가능';

  @override
  String get streakDialogContinueTitle => '게시 완료';

  @override
  String streakDialogContinueContent(int weeks) {
    return '$weeks주 연속!\n계속 게시하면\n연속 게시 가능';
  }

  @override
  String get translatableTranslate => '번역하기';

  @override
  String get translatableShowOriginal => '원문 보기';

  @override
  String get translatableCopy => '복사';

  @override
  String get translatableCopied => '클립보드에 복사됨';

  @override
  String get translatableTranslateFailed => '번역에 실패했습니다';

  @override
  String get likeNotificationsTitle => '좋아요 알림';

  @override
  String get loadFailed => '불러오기에 실패했어요';

  @override
  String get someoneLikedYourPost => '누군가가 당신의 게시글을 좋아합니다.';

  @override
  String userLikedYourPost(String name) {
    return '$name님이 당신의 게시글을 좋아합니다.';
  }
}
