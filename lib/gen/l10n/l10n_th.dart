// ignore_for_file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class L10nTh extends L10n {
  L10nTh([String locale = 'th']) : super(locale);

  @override
  String get maybeNotFoodDialogTitle => 'ขอตรวจสอบสักครู่ 🍽️';

  @override
  String get maybeNotFoodDialogText =>
      'ภาพนี้อาจไม่ใช่อาหาร... 🤔\\n\\nต้องการโพสต์ต่อหรือไม่?';

  @override
  String get maybeNotFoodDialogConfirm => 'ดำเนินการต่อ';

  @override
  String get maybeNotFoodDialogDelete => 'ลบรูปภาพ';

  @override
  String get close => 'ปิด';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get editTitle => 'แก้ไข';

  @override
  String get editPostButton => 'แก้โพสต์';

  @override
  String get emailInputField => 'กรอกอีเมล';

  @override
  String get settingIcon => 'เลือกไอคอน';

  @override
  String get userName => 'ชื่อผู้ใช้';

  @override
  String get userNameInputField => 'ชื่อผู้ใช้ (เช่น iseryu)';

  @override
  String get userId => 'รหัสผู้ใช้';

  @override
  String get userIdInputField => 'รหัสผู้ใช้ (เช่น iseryuuu)';

  @override
  String get registerButton => 'ลงทะเบียน';

  @override
  String get settingAppBar => 'การตั้งค่า';

  @override
  String get settingCheckVersion => 'ตรวจสอบเวอร์ชัน';

  @override
  String get settingCheckVersionDialogTitle => 'ข้อมูลอัปเดต';

  @override
  String get settingCheckVersionDialogText1 => 'มีเวอร์ชันใหม่ให้ใช้งาน';

  @override
  String get settingCheckVersionDialogText2 => 'กรุณาอัปเดตเป็นเวอร์ชันล่าสุด';

  @override
  String get settingDeveloper => 'Twitter';

  @override
  String get settingGithub => 'Github';

  @override
  String get settingReview => 'รีวิว';

  @override
  String get settingLicense => 'ใบอนุญาต';

  @override
  String get settingShareApp => 'แชร์';

  @override
  String get settingFaq => 'FAQ';

  @override
  String get settingPrivacyPolicy => 'ความเป็นส่วนตัว';

  @override
  String get settingTermsOfUse => 'ข้อกำหนด';

  @override
  String get settingContact => 'ติดต่อ';

  @override
  String get settingTutorial => 'บทช่วยสอน';

  @override
  String get settingCredit => 'เครดิต';

  @override
  String get unregistered => 'ยังไม่ได้ลงทะเบียน';

  @override
  String get settingBatteryLevel => 'ระดับแบตเตอรี่';

  @override
  String get settingDeviceInfo => 'ข้อมูลอุปกรณ์';

  @override
  String get settingIosVersion => 'เวอร์ชัน iOS';

  @override
  String get settingAndroidSdk => 'SDK';

  @override
  String get settingAppVersion => 'เวอร์ชันแอป';

  @override
  String get settingAccount => 'บัญชี';

  @override
  String get settingLogoutButton => 'ออกจากระบบ';

  @override
  String get settingDeleteAccountButton => 'ขอลบบัญชี';

  @override
  String get settingQuestion => 'กล่องคำถาม';

  @override
  String get settingAccountManagement => 'จัดการบัญชี';

  @override
  String get settingRestoreSuccessTitle => 'กู้คืนสำเร็จ';

  @override
  String get settingRestoreSuccessSubtitle => 'ฟีเจอร์พรีเมียมเปิดใช้งานแล้ว!';

  @override
  String get settingRestoreFailureTitle => 'กู้คืนล้มเหลว';

  @override
  String get settingRestoreFailureSubtitle =>
      'ไม่มีประวัติซื้อ? ติดต่อสนับสนุน';

  @override
  String get settingRestore => 'กู้คืน';

  @override
  String get settingPremiumMembership => 'เป็นพรีเมียม';

  @override
  String get shareButton => 'แชร์';

  @override
  String get postFoodName => 'ชื่ออาหาร';

  @override
  String get postFoodNameInputField => 'กรอกชื่ออาหาร (จำเป็น)';

  @override
  String get postRestaurantNameInputField => 'เพิ่มชื่อร้าน (จำเป็น)';

  @override
  String get postComment => 'ความคิดเห็น (ไม่บังคับ)';

  @override
  String get postCommentInputField => 'ความคิดเห็น';

  @override
  String get postError => 'ส่งล้มเหลว';

  @override
  String get postCategoryTitle => 'เลือกแท็กประเทศ/อาหาร';

  @override
  String get postCountryCategory => 'ประเทศ';

  @override
  String get postCuisineCategory => 'อาหาร';

  @override
  String get postTitle => 'โพสต์';

  @override
  String get postMissingInfo => 'กรุณากรอกให้ครบ';

  @override
  String get postMissingPhoto => 'กรุณาเพิ่มรูปภาพ';

  @override
  String get postMissingFoodName => 'กรุณากรอกสิ่งที่คุณกิน';

  @override
  String get postMissingRestaurant => 'กรุณาเพิ่มชื่อร้านอาหาร';

  @override
  String get postPhotoSuccess => 'เพิ่มรูปภาพสำเร็จ';

  @override
  String get postCameraPermission => 'ต้องการสิทธิ์กล้อง';

  @override
  String get postAlbumPermission => 'ต้องการสิทธิ์รูปภาพ';

  @override
  String get postSuccess => 'โพสต์สำเร็จ';

  @override
  String get postSearchError => 'ไม่สามารถค้นหาชื่อสถานที่';

  @override
  String get editUpdateButton => 'อัปเดต';

  @override
  String get editBio => 'ประวัติ (ไม่บังคับ)';

  @override
  String get editBioInputField => 'กรอกประวัติ';

  @override
  String get editFavoriteTagTitle => 'เลือกแท็กที่ชื่นชอบ';

  @override
  String get emptyPosts => 'ไม่มีโพสต์';

  @override
  String get searchEmptyResult => 'ไม่พบผลลัพธ์';

  @override
  String get searchButton => 'ค้นหา';

  @override
  String get searchTitle => 'ค้นหา';

  @override
  String get searchRestaurantTitle => 'ค้นหาร้านอาหาร';

  @override
  String get searchUserTitle => 'ค้นหาผู้ใช้';

  @override
  String get searchUserHeader => 'ค้นหาผู้ใช้';

  @override
  String searchUserPostCount(Object count) {
    return 'โพสต์: $count';
  }

  @override
  String get searchUserLatestPosts => 'โพสต์ล่าสุด';

  @override
  String get searchUserNoUsers => 'ไม่พบผู้ใช้ที่มีโพสต์';

  @override
  String get unknown => 'ไม่ทราบ・ไม่พบ';

  @override
  String get profilePostCount => 'โพสต์';

  @override
  String get profilePointCount => 'คะแนน';

  @override
  String get profileEditButton => 'แก้ไขโปรไฟล์';

  @override
  String get profileExchangePointsButton => 'แลกคะแนน';

  @override
  String get profileFavoriteGenre => 'ประเภทที่ชื่นชอบ';

  @override
  String get likeButton => 'ถูกใจ';

  @override
  String get shareReviewPrefix => 'เพิ่งแชร์มื้อที่กิน!';

  @override
  String get shareReviewSuffix => 'ดูเพิ่มเติมที่ foodGram!';

  @override
  String get postDetailSheetTitle => 'เกี่ยวกับโพสต์นี้';

  @override
  String get postDetailSheetShareButton => 'แชร์โพสต์นี้';

  @override
  String get postDetailSheetReportButton => 'รายงานโพสต์นี้';

  @override
  String get postDetailSheetBlockButton => 'บล็อกผู้ใช้คนนี้';

  @override
  String get dialogYesButton => 'ใช่';

  @override
  String get dialogNoButton => 'ไม่';

  @override
  String get dialogReportTitle => 'รายงานโพสต์';

  @override
  String get dialogReportDescription1 => 'คุณจะรายงานโพสต์นี้';

  @override
  String get dialogReportDescription2 => 'จะนำไปยัง Google Form';

  @override
  String get dialogBlockTitle => 'ยืนยันการบล็อก';

  @override
  String get dialogBlockDescription1 => 'คุณต้องการบล็อกผู้ใช้คนนี้หรือไม่?';

  @override
  String get dialogBlockDescription2 => 'นี่จะซ่อนโพสต์ของผู้ใช้';

  @override
  String get dialogBlockDescription3 => 'ผู้ใช้ที่ถูกบล็อกจะถูกบันทึกในเครื่อง';

  @override
  String get dialogDeleteTitle => 'ลบโพสต์';

  @override
  String get heartLimitMessage =>
      'ถึงขีดจำกัด 10 ถูกใจวันนี้แล้ว ลองใหม่อีกครั้งพรุ่งนี้';

  @override
  String get dialogDeleteDescription1 => 'คุณต้องการลบโพสต์นี้หรือไม่?';

  @override
  String get dialogDeleteDescription2 => 'เมื่อลบแล้ว จะไม่สามารถกู้คืนได้';

  @override
  String get dialogDeleteError => 'ลบล้มเหลว';

  @override
  String get dialogLogoutTitle => 'ยืนยันการออกจากระบบ';

  @override
  String get dialogLogoutDescription1 => 'คุณต้องการออกจากระบบหรือไม่?';

  @override
  String get dialogLogoutDescription2 => 'สถานะบัญชีถูกเก็บไว้บนเซิร์ฟเวอร์';

  @override
  String get dialogLogoutButton => 'ออกจากระบบ';

  @override
  String get errorTitle => 'ข้อผิดพลาดในการเชื่อมต่อ';

  @override
  String get errorDescription1 => 'เกิดข้อผิดพลาดในการเชื่อมต่อ';

  @override
  String get errorDescription2 => 'ตรวจสอบการเชื่อมต่อเครือข่ายและลองอีกครั้ง';

  @override
  String get errorRefreshButton => 'โหลดใหม่';

  @override
  String get error => 'เกิดข้อผิดพลาด';

  @override
  String get mapLoadingError => 'เกิดข้อผิดพลาด';

  @override
  String get mapLoadingRestaurant => 'กำลังดึงข้อมูลร้านอาหาร...';

  @override
  String get appShareTitle => 'แชร์';

  @override
  String get appShareStoreButton => 'แชร์ร้านนี้';

  @override
  String get appShareInstagramButton => 'แชร์บน Instagram';

  @override
  String get appShareGoButton => 'ไปที่ร้านนี้';

  @override
  String get appShareCloseButton => 'ปิด';

  @override
  String get shareInviteMessage => 'แชร์อาหารอร่อยบน FoodGram!';

  @override
  String get appRestaurantLabel => 'ค้นหาร้านอาหาร';

  @override
  String get appRequestTitle => 'เปิดใช้งานตำแหน่ง!';

  @override
  String get appRequestReason => 'ค้นหาสถานที่ใกล้ๆ\nง่ายขึ้น';

  @override
  String get appRequestInduction => 'ปุ่มนี้จะเปิดการตั้งค่า';

  @override
  String get appRequestOpenSetting => 'เปิดใช้งานตำแหน่ง';

  @override
  String get appTitle => 'FoodGram';

  @override
  String get appSubtitle => 'กิน × ถ่าย × แชร์';

  @override
  String get agreeToTheTermsOfUse => 'กรุณาตกลงกับข้อกำหนดการใช้งาน';

  @override
  String get restaurantCategoryList => 'เลือกอาหารตามประเทศ';

  @override
  String get cookingCategoryList => 'เลือกแท็กอาหาร';

  @override
  String get restaurantReviewNew => 'ใหม่';

  @override
  String get restaurantReviewViewDetails => 'ดูรายละเอียด';

  @override
  String get restaurantReviewOtherPosts => 'โพสต์อื่นๆ';

  @override
  String get restaurantReviewReviewList => 'รายการรีวิว';

  @override
  String get restaurantReviewError => 'เกิดข้อผิดพลาด';

  @override
  String get nearbyRestaurants => '📍 ร้านอาหารใกล้ๆ';

  @override
  String get seeMore => 'ดูเพิ่มเติม';

  @override
  String get selectCountryTag => 'เลือกแท็กประเทศ';

  @override
  String get selectFavoriteTag => 'เลือกแท็กที่ชื่นชอบ';

  @override
  String get favoriteTagPlaceholder => 'เลือกแท็กที่ชื่นชอบของคุณ';

  @override
  String get selectFoodTag => 'เลือกแท็กอาหาร';

  @override
  String get tabHome => 'อาหาร';

  @override
  String get tabMap => 'แผนที่';

  @override
  String get tabMyMap => 'แผนที่ของฉัน';

  @override
  String get tabSearch => 'ค้นหา';

  @override
  String get tabMyPage => 'หน้าของฉัน';

  @override
  String get tabSetting => 'การตั้งค่า';

  @override
  String get mapStatsVisitedArea => 'พื้นที่';

  @override
  String get mapStatsPosts => 'โพสต์';

  @override
  String get mapStatsActivityDays => 'วัน';

  @override
  String get dayUnit => 'วัน';

  @override
  String get mapStatsPrefectures => 'จังหวัด';

  @override
  String get mapStatsAchievementRate => 'อัตรา';

  @override
  String get mapStatsVisitedCountries => 'ประเทศ';

  @override
  String get mapViewTypeRecord => 'บันทึก';

  @override
  String get mapViewTypeJapan => 'ญี่ปุ่น';

  @override
  String get mapViewTypeWorld => 'โลก';

  @override
  String get logoutFailure => 'ออกจากระบบล้มเหลว';

  @override
  String get accountDeletionFailure => 'ลบบัญชีล้มเหลว';

  @override
  String get appleLoginFailure => 'ไม่สามารถเข้าสู่ระบบด้วย Apple';

  @override
  String get emailAuthenticationFailure => 'การยืนยันอีเมลล้มเหลว';

  @override
  String get loginError => 'ข้อผิดพลาดในการเข้าสู่ระบบ';

  @override
  String get loginSuccessful => 'เข้าสู่ระบบสำเร็จ';

  @override
  String get emailAuthentication => 'ยืนยันด้วยอีเมล';

  @override
  String get emailEmpty => 'ยังไม่ได้กรอกที่อยู่อีเมล';

  @override
  String get email => 'ที่อยู่อีเมล';

  @override
  String get enterTheCorrectFormat => 'กรุณากรอกในรูปแบบที่ถูกต้อง';

  @override
  String get authInvalidFormat => 'รูปแบบที่อยู่อีเมลไม่ถูกต้อง';

  @override
  String get authSocketException =>
      'มีปัญหากับเครือข่าย กรุณาตรวจสอบการเชื่อมต่อ';

  @override
  String get camera => 'กล้อง';

  @override
  String get album => 'อัลบั้ม';

  @override
  String get snsLogin => 'เข้าสู่ระบบ SNS';

  @override
  String get tutorialFirstPageTitle => 'แชร์ช่วงเวลาอร่อยๆ ของคุณ';

  @override
  String get tutorialFirstPageSubTitle =>
      'ด้วย FoodGram ทำให้ทุกมื้อพิเศษขึ้น\nสนุกกับการค้นพบรสชาติใหม่!';

  @override
  String get tutorialDiscoverTitle => 'ค้นหาอาหารจานโปรดถัดไปของคุณ!';

  @override
  String get tutorialDiscoverSubTitle =>
      'ทุกครั้งที่เลื่อน จะพบของอร่อยใหม่ๆ\nสำรวจอาหารอร่อยตอนนี้';

  @override
  String get tutorialSecondPageTitle => 'แผนที่อาหารเฉพาะสำหรับแอปนี้';

  @override
  String get tutorialSecondPageSubTitle =>
      'มาสร้างแผนที่เฉพาะสำหรับแอปนี้กัน\nโพสต์ของคุณจะช่วยพัฒนาพื้นที่แผนที่';

  @override
  String get tutorialThirdPageTitle => 'ข้อกำหนดการใช้งาน';

  @override
  String get tutorialThirdPageSubTitle =>
      '・ระวังในการแชร์ข้อมูลส่วนตัว เช่น ชื่อ ที่อยู่ หมายเลขโทรศัพท์ หรือตำแหน่ง\n\n・หลีกเลี่ยงการโพสต์เนื้อหาที่ไม่เหมาะสม ไม่เหมาะสม หรือเป็นอันตราย และอย่าใช้ผลงานของผู้อื่นโดยไม่ได้รับอนุญาต\n\n・โพสต์ที่ไม่เกี่ยวข้องกับอาหารอาจถูกลบ\n\n・ผู้ใช้ที่ละเมิดกฎซ้ำๆ หรือโพสต์เนื้อหาที่ไม่เหมาะสมอาจถูกลบโดยทีมจัดการ\n\n・เราหวังว่าจะปรับปรุงแอปนี้ร่วมกับทุกคน โดยนักพัฒนา';

  @override
  String get tutorialThirdPageButton => 'ตกลงกับข้อกำหนดการใช้งาน';

  @override
  String get tutorialThirdPageClose => 'ปิด';

  @override
  String get detailMenuShare => 'แชร์';

  @override
  String get detailMenuVisit => 'เยี่ยมชม';

  @override
  String get detailMenuPost => 'โพสต์';

  @override
  String get detailMenuSearch => 'ค้นหา';

  @override
  String get forceUpdateTitle => 'แจ้งเตือนอัปเดต';

  @override
  String get forceUpdateText =>
      'มีการเปิดตัวเวอร์ชันใหม่ของแอปนี้ กรุณาอัปเดตแอปเพื่อให้แน่ใจว่ามีฟีเจอร์ล่าสุดและสภาพแวดล้อมที่ปลอดภัย';

  @override
  String get forceUpdateButtonTitle => 'อัปเดต';

  @override
  String get newAccountImportantTitle => 'หมายเหตุสำคัญ';

  @override
  String get newAccountImportant =>
      'เมื่อสร้างบัญชี กรุณาอย่ารวมข้อมูลส่วนตัว เช่น ที่อยู่อีเมลหรือหมายเลขโทรศัพท์ในชื่อผู้ใช้หรือรหัสผู้ใช้ของคุณ เพื่อให้แน่ใจว่ามีประสบการณ์ออนไลน์ที่ปลอดภัย เลือกชื่อที่ไม่เปิดเผยรายละเอียดส่วนตัวของคุณ';

  @override
  String get accountRegistrationSuccess => 'ลงทะเบียนบัญชีเสร็จสมบูรณ์';

  @override
  String get accountRegistrationError => 'เกิดข้อผิดพลาด';

  @override
  String get requiredInfoMissing => 'ข้อมูลที่จำเป็นขาดหายไป';

  @override
  String get shareTextAndImage => 'แชร์พร้อมข้อความและรูปภาพ';

  @override
  String get shareImageOnly => 'แชร์เฉพาะรูปภาพ';

  @override
  String get foodCategoryNoodles => 'ก๋วยเตี๋ยว';

  @override
  String get foodCategoryMeat => 'เนื้อ';

  @override
  String get foodCategoryFastFood => 'อาหารจานด่วน';

  @override
  String get foodCategoryRiceDishes => 'อาหารข้าว';

  @override
  String get foodCategorySeafood => 'อาหารทะเล';

  @override
  String get foodCategoryBread => 'ขนมปัง';

  @override
  String get foodCategorySweetsAndSnacks => 'ของหวาน & ของว่าง';

  @override
  String get foodCategoryFruits => 'ผลไม้';

  @override
  String get foodCategoryVegetables => 'ผัก';

  @override
  String get foodCategoryBeverages => 'เครื่องดื่ม';

  @override
  String get foodCategoryOthers => 'อื่นๆ';

  @override
  String get foodCategoryAll => 'ทั้งหมด';

  @override
  String get rankEmerald => 'มรกต';

  @override
  String get rankDiamond => 'เพชร';

  @override
  String get rankGold => 'ทอง';

  @override
  String get rankSilver => 'เงิน';

  @override
  String get rankBronze => 'ทองแดง';

  @override
  String get rank => 'อันดับ';

  @override
  String get promoteDialogTitle => '✨ เป็นสมาชิกพรีเมียม ✨';

  @override
  String get promoteDialogTrophyTitle => 'ฟีเจอร์ถ้วยรางวัล';

  @override
  String get promoteDialogTrophyDesc => 'แสดงถ้วยรางวัลตามกิจกรรมของคุณ';

  @override
  String get promoteDialogTagTitle => 'แท็กที่กำหนดเอง';

  @override
  String get promoteDialogTagDesc =>
      'ตั้งค่าแท็กที่กำหนดเองสำหรับอาหารที่คุณชื่นชอบ';

  @override
  String get promoteDialogIconTitle => 'ไอคอนที่กำหนดเอง';

  @override
  String get promoteDialogIconDesc =>
      'ตั้งค่าไอคอนโปรไฟล์ของคุณเป็นรูปภาพใดก็ได้ที่คุณชอบ!!';

  @override
  String get promoteDialogAdTitle => 'ไม่มีโฆษณา';

  @override
  String get promoteDialogAdDesc => 'ลบโฆษณาทั้งหมด!!';

  @override
  String get promoteDialogButton => 'อัปเกรดพรีเมียม';

  @override
  String get promoteDialogLater => 'ไว้ทีหลัง';

  @override
  String get paywallTitle => 'FoodGram Premium';

  @override
  String get paywallPremiumTitle => '✨ ประโยชน์พรีเมียม ✨';

  @override
  String get paywallTrophyTitle => 'รับตำแหน่งเมื่อคุณโพสต์มากขึ้น';

  @override
  String get paywallTrophyDesc => 'ตำแหน่งอัปเกรดตามจำนวนโพสต์ของคุณ';

  @override
  String get paywallTagTitle => 'ตั้งค่าประเภทที่คุณชื่นชอบ';

  @override
  String get paywallTagDesc => 'ปรับแต่งสไตล์โปรไฟล์ของคุณ';

  @override
  String get paywallIconTitle => 'ใช้รูปภาพใดก็ได้เป็นไอคอนของคุณ';

  @override
  String get paywallIconDesc => 'โดดเด่นจากผู้โพสต์คนอื่นๆ';

  @override
  String get paywallAdTitle => 'ไม่มีโฆษณา';

  @override
  String get paywallAdDesc => 'ลบโฆษณาทั้งหมด';

  @override
  String get paywallComingSoon => 'เร็วๆ นี้...';

  @override
  String get paywallNewFeatures => 'ฟีเจอร์พิเศษสำหรับพรีเมียมใหม่\nเร็วๆ นี้!';

  @override
  String get paywallSubscribeButton => 'เป็นพรีเมียม';

  @override
  String get paywallPrice => 'รายเดือน \$3 / เดือน';

  @override
  String get paywallCancelNote => 'ยกเลิกได้ตลอดเวลา';

  @override
  String get paywallWelcomeTitle => 'ยินดีต้อนรับสู่\nFoodGram Premium!';

  @override
  String get paywallSkip => 'ข้าม';

  @override
  String get purchaseError => 'เกิดข้อผิดพลาดระหว่างการซื้อ';

  @override
  String get paywallTagline => '✨ อัปเกรดประสบการณ์อาหารของคุณ ✨';

  @override
  String get paywallMapTitle => 'ค้นหาด้วยแผนที่';

  @override
  String get paywallMapDesc => 'ค้นหาร้านอาหารได้เร็วและง่ายขึ้น';

  @override
  String get paywallRankTitle => 'รับตำแหน่งเมื่อคุณโพสต์มากขึ้น';

  @override
  String get paywallRankDesc => 'ตำแหน่งอัปเกรดตามจำนวนโพสต์ของคุณ';

  @override
  String get paywallGenreTitle => 'ตั้งค่าประเภทที่คุณชื่นชอบ';

  @override
  String get paywallGenreDesc => 'ปรับแต่งสไตล์โปรไฟล์ของคุณ';

  @override
  String get paywallCustomIconTitle => 'ใช้รูปภาพใดก็ได้เป็นไอคอนของคุณ';

  @override
  String get paywallCustomIconDesc => 'โดดเด่นจากผู้โพสต์คนอื่นๆ';

  @override
  String get anonymousPost => 'โพสต์แบบไม่ระบุชื่อ';

  @override
  String get anonymousPostDescription => 'ชื่อผู้ใช้จะถูกซ่อน';

  @override
  String get anonymousShare => 'แชร์แบบไม่ระบุชื่อ';

  @override
  String get anonymousUpdate => 'อัปเดตแบบไม่ระบุชื่อ';

  @override
  String get anonymousPoster => 'ผู้โพสต์ไม่ระบุชื่อ';

  @override
  String get anonymousUsername => 'foodgramer';

  @override
  String get tagOtherCuisine => 'อาหารอื่นๆ';

  @override
  String get tagOtherFood => 'อาหารอื่นๆ';

  @override
  String get tagJapaneseCuisine => 'อาหารญี่ปุ่น';

  @override
  String get tagItalianCuisine => 'อาหารอิตาเลียน';

  @override
  String get tagFrenchCuisine => 'อาหารฝรั่งเศส';

  @override
  String get tagChineseCuisine => 'อาหารจีน';

  @override
  String get tagIndianCuisine => 'อาหารอินเดีย';

  @override
  String get tagMexicanCuisine => 'อาหารเม็กซิกัน';

  @override
  String get tagHongKongCuisine => 'อาหารฮ่องกง';

  @override
  String get tagAmericanCuisine => 'อาหารอเมริกัน';

  @override
  String get tagMediterraneanCuisine => 'อาหารเมดิเตอร์เรเนียน';

  @override
  String get tagThaiCuisine => 'อาหารไทย';

  @override
  String get tagGreekCuisine => 'อาหารกรีก';

  @override
  String get tagTurkishCuisine => 'อาหารตุรกี';

  @override
  String get tagKoreanCuisine => 'อาหารเกาหลี';

  @override
  String get tagRussianCuisine => 'อาหารรัสเซีย';

  @override
  String get tagSpanishCuisine => 'อาหารสเปน';

  @override
  String get tagVietnameseCuisine => 'อาหารเวียดนาม';

  @override
  String get tagPortugueseCuisine => 'อาหารโปรตุเกส';

  @override
  String get tagAustrianCuisine => 'อาหารออสเตรีย';

  @override
  String get tagBelgianCuisine => 'อาหารเบลเยียม';

  @override
  String get tagSwedishCuisine => 'อาหารสวีเดน';

  @override
  String get tagGermanCuisine => 'อาหารเยอรมัน';

  @override
  String get tagBritishCuisine => 'อาหารอังกฤษ';

  @override
  String get tagDutchCuisine => 'อาหารดัตช์';

  @override
  String get tagAustralianCuisine => 'อาหารออสเตรเลีย';

  @override
  String get tagBrazilianCuisine => 'อาหารบราซิล';

  @override
  String get tagArgentineCuisine => 'อาหารอาร์เจนตินา';

  @override
  String get tagColombianCuisine => 'อาหารโคลอมเบีย';

  @override
  String get tagPeruvianCuisine => 'อาหารเปรู';

  @override
  String get tagNorwegianCuisine => 'อาหารนอร์เวย์';

  @override
  String get tagDanishCuisine => 'อาหารเดนมาร์ก';

  @override
  String get tagPolishCuisine => 'อาหารโปแลนด์';

  @override
  String get tagCzechCuisine => 'อาหารเช็ก';

  @override
  String get tagHungarianCuisine => 'อาหารฮังการี';

  @override
  String get tagSouthAfricanCuisine => 'อาหารแอฟริกาใต้';

  @override
  String get tagEgyptianCuisine => 'อาหารอียิปต์';

  @override
  String get tagMoroccanCuisine => 'อาหารโมร็อกโก';

  @override
  String get tagNewZealandCuisine => 'อาหารนิวซีแลนด์';

  @override
  String get tagFilipinoCuisine => 'อาหารฟิลิปปินส์';

  @override
  String get tagMalaysianCuisine => 'อาหารมาเลเซีย';

  @override
  String get tagSingaporeanCuisine => 'อาหารสิงคโปร์';

  @override
  String get tagIndonesianCuisine => 'อาหารอินโดนีเซีย';

  @override
  String get tagIranianCuisine => 'อาหารอิหร่าน';

  @override
  String get tagSaudiArabianCuisine => 'อาหารซาอุดีอาระเบีย';

  @override
  String get tagMongolianCuisine => 'อาหารมองโกเลีย';

  @override
  String get tagCambodianCuisine => 'อาหารกัมพูชา';

  @override
  String get tagLaotianCuisine => 'อาหารลาว';

  @override
  String get tagCubanCuisine => 'อาหารคิวบา';

  @override
  String get tagJamaicanCuisine => 'อาหารจาเมกา';

  @override
  String get tagChileanCuisine => 'อาหารชิลี';

  @override
  String get tagVenezuelanCuisine => 'อาหารเวเนซุเอลา';

  @override
  String get tagPanamanianCuisine => 'อาหารปานามา';

  @override
  String get tagBolivianCuisine => 'อาหารโบลิเวีย';

  @override
  String get tagIcelandicCuisine => 'อาหารไอซ์แลนด์';

  @override
  String get tagLithuanianCuisine => 'อาหารลิทัวเนีย';

  @override
  String get tagEstonianCuisine => 'อาหารเอสโตเนีย';

  @override
  String get tagLatvianCuisine => 'อาหารลัตเวีย';

  @override
  String get tagFinnishCuisine => 'อาหารฟินแลนด์';

  @override
  String get tagCroatianCuisine => 'อาหารโครเอเชีย';

  @override
  String get tagSlovenianCuisine => 'อาหารสโลวีเนีย';

  @override
  String get tagSlovakCuisine => 'อาหารสโลวัก';

  @override
  String get tagRomanianCuisine => 'อาหารโรมาเนีย';

  @override
  String get tagBulgarianCuisine => 'อาหารบัลแกเรีย';

  @override
  String get tagSerbianCuisine => 'อาหารเซอร์เบีย';

  @override
  String get tagAlbanianCuisine => 'อาหารแอลเบเนีย';

  @override
  String get tagGeorgianCuisine => 'อาหารจอร์เจีย';

  @override
  String get tagArmenianCuisine => 'อาหารอาร์เมเนีย';

  @override
  String get tagAzerbaijaniCuisine => 'อาหารอาเซอร์ไบจาน';

  @override
  String get tagUkrainianCuisine => 'อาหารยูเครน';

  @override
  String get tagBelarusianCuisine => 'อาหารเบลารุส';

  @override
  String get tagKazakhCuisine => 'อาหารคาซัคสถาน';

  @override
  String get tagUzbekCuisine => 'อาหารอุซเบกิสถาน';

  @override
  String get tagKyrgyzCuisine => 'อาหารคีร์กีซสถาน';

  @override
  String get tagTurkmenCuisine => 'อาหารเติร์กเมนิสถาน';

  @override
  String get tagTajikCuisine => 'อาหารทาจิกิสถาน';

  @override
  String get tagMaldivianCuisine => 'อาหารมัลดีฟส์';

  @override
  String get tagNepaleseCuisine => 'อาหารเนปาล';

  @override
  String get tagBangladeshiCuisine => 'อาหารบังกลาเทศ';

  @override
  String get tagMyanmarCuisine => 'อาหารพม่า';

  @override
  String get tagBruneianCuisine => 'อาหารบรูไน';

  @override
  String get tagTaiwaneseCuisine => 'อาหารไต้หวัน';

  @override
  String get tagNigerianCuisine => 'อาหารไนจีเรีย';

  @override
  String get tagKenyanCuisine => 'อาหารเคนยา';

  @override
  String get tagGhanaianCuisine => 'อาหารกานา';

  @override
  String get tagEthiopianCuisine => 'อาหารเอธิโอเปีย';

  @override
  String get tagSudaneseCuisine => 'อาหารซูดาน';

  @override
  String get tagTunisianCuisine => 'อาหารตูนิเซีย';

  @override
  String get tagAngolanCuisine => 'อาหารแองโกลา';

  @override
  String get tagCongoleseCuisine => 'อาหารคองโก';

  @override
  String get tagZimbabweanCuisine => 'อาหารซิมบับเว';

  @override
  String get tagMalagasyCuisine => 'อาหารมาดากัสการ์';

  @override
  String get tagPapuaNewGuineanCuisine => 'อาหารปาปัวนิวกินี';

  @override
  String get tagSamoanCuisine => 'อาหารซามัว';

  @override
  String get tagTuvaluanCuisine => 'อาหารตูวาลู';

  @override
  String get tagFijianCuisine => 'อาหารฟิจิ';

  @override
  String get tagPalauanCuisine => 'อาหารปาเลา';

  @override
  String get tagKiribatiCuisine => 'อาหารคิริบาส';

  @override
  String get tagVanuatuanCuisine => 'อาหารวานูอาตู';

  @override
  String get tagBahrainiCuisine => 'อาหารบาห์เรน';

  @override
  String get tagQatariCuisine => 'อาหารกาตาร์';

  @override
  String get tagKuwaitiCuisine => 'อาหารคูเวต';

  @override
  String get tagOmaniCuisine => 'อาหารโอมาน';

  @override
  String get tagYemeniCuisine => 'อาหารเยเมน';

  @override
  String get tagLebaneseCuisine => 'อาหารเลบานอน';

  @override
  String get tagSyrianCuisine => 'อาหารซีเรีย';

  @override
  String get tagJordanianCuisine => 'อาหารจอร์แดน';

  @override
  String get tagNoodles => 'ก๋วยเตี๋ยว';

  @override
  String get tagMeatDishes => 'อาหารเนื้อ';

  @override
  String get tagFastFood => 'อาหารจานด่วน';

  @override
  String get tagRiceDishes => 'อาหารข้าว';

  @override
  String get tagSeafood => 'อาหารทะเล';

  @override
  String get tagBread => 'ขนมปัง';

  @override
  String get tagSweetsAndSnacks => 'ของหวาน & ของว่าง';

  @override
  String get tagFruits => 'ผลไม้';

  @override
  String get tagVegetables => 'ผัก';

  @override
  String get tagBeverages => 'เครื่องดื่ม';

  @override
  String get tagOthers => 'อื่นๆ';

  @override
  String get tagPasta => 'พาสต้า';

  @override
  String get tagRamen => 'ราเมน';

  @override
  String get tagSteak => 'สเต็ก';

  @override
  String get tagYakiniku => 'ยากินิกุ';

  @override
  String get tagChicken => 'ไก่';

  @override
  String get tagBacon => 'เบคอน';

  @override
  String get tagHamburger => 'แฮมเบอร์เกอร์';

  @override
  String get tagFrenchFries => 'เฟรนช์ฟรายส์';

  @override
  String get tagPizza => 'พิซซ่า';

  @override
  String get tagTacos => 'ทาโก้';

  @override
  String get tagTamales => 'ทามาเลส';

  @override
  String get tagGyoza => 'เกียวซ่า';

  @override
  String get tagFriedShrimp => 'กุ้งทอด';

  @override
  String get tagHotPot => 'หม้อไฟ';

  @override
  String get tagCurry => 'แกง';

  @override
  String get tagPaella => 'ปาเอยา';

  @override
  String get tagFondue => 'ฟองดู';

  @override
  String get tagOnigiri => 'โอนิกิริ';

  @override
  String get tagRice => 'ข้าว';

  @override
  String get tagBento => 'เบนโตะ';

  @override
  String get tagSushi => 'ซูชิ';

  @override
  String get tagFish => 'ปลา';

  @override
  String get tagOctopus => 'ปลาหมึก';

  @override
  String get tagSquid => 'ปลาหมึก';

  @override
  String get tagShrimp => 'กุ้ง';

  @override
  String get tagCrab => 'ปู';

  @override
  String get tagShellfish => 'หอย';

  @override
  String get tagOyster => 'หอยนางรม';

  @override
  String get tagSandwich => 'แซนด์วิช';

  @override
  String get tagHotDog => 'ฮอตด็อก';

  @override
  String get tagDonut => 'โดนัท';

  @override
  String get tagPancake => 'แพนเค้ก';

  @override
  String get tagCroissant => 'ครัวซองต์';

  @override
  String get tagBagel => 'เบเกิล';

  @override
  String get tagBaguette => 'บาแกตต์';

  @override
  String get tagPretzel => 'เพรตเซล';

  @override
  String get tagBurrito => 'บูร์ริโต';

  @override
  String get tagIceCream => 'ไอศกรีม';

  @override
  String get tagPudding => 'พุดดิ้ง';

  @override
  String get tagRiceCracker => 'ข้าวเกรียบ';

  @override
  String get tagDango => 'ดังโงะ';

  @override
  String get tagShavedIce => 'น้ำแข็งไส';

  @override
  String get tagPie => 'พาย';

  @override
  String get tagCupcake => 'คัพเค้ก';

  @override
  String get tagCake => 'เค้ก';

  @override
  String get tagCandy => 'ลูกอม';

  @override
  String get tagLollipop => 'อมยิ้ม';

  @override
  String get tagChocolate => 'ช็อกโกแลต';

  @override
  String get tagPopcorn => 'ป๊อปคอร์น';

  @override
  String get tagCookie => 'คุกกี้';

  @override
  String get tagPeanuts => 'ถั่วลิสง';

  @override
  String get tagBeans => 'ถั่ว';

  @override
  String get tagChestnut => 'เกาลัด';

  @override
  String get tagFortuneCookie => 'คุกกี้เสี่ยงทาย';

  @override
  String get tagMooncake => 'ขนมไหว้พระจันทร์';

  @override
  String get tagHoney => 'น้ำผึ้ง';

  @override
  String get tagWaffle => 'วาฟเฟิล';

  @override
  String get tagApple => 'แอปเปิล';

  @override
  String get tagPear => 'ลูกแพร์';

  @override
  String get tagOrange => 'ส้ม';

  @override
  String get tagLemon => 'เลมอน';

  @override
  String get tagLime => 'มะนาว';

  @override
  String get tagBanana => 'กล้วย';

  @override
  String get tagWatermelon => 'แตงโม';

  @override
  String get tagGrapes => 'องุ่น';

  @override
  String get tagStrawberry => 'สตรอว์เบอร์รี่';

  @override
  String get tagBlueberry => 'บลูเบอร์รี่';

  @override
  String get tagMelon => 'เมลอน';

  @override
  String get tagCherry => 'เชอร์รี่';

  @override
  String get tagPeach => 'ลูกพีช';

  @override
  String get tagMango => 'มะม่วง';

  @override
  String get tagPineapple => 'สับปะรด';

  @override
  String get tagCoconut => 'มะพร้าว';

  @override
  String get tagKiwi => 'กีวี';

  @override
  String get tagSalad => 'สลัด';

  @override
  String get tagTomato => 'มะเขือเทศ';

  @override
  String get tagEggplant => 'มะเขือยาว';

  @override
  String get tagAvocado => 'อะโวคาโด';

  @override
  String get tagGreenBeans => 'ถั่วเขียว';

  @override
  String get tagBroccoli => 'บรอกโคลี';

  @override
  String get tagLettuce => 'ผักกาด';

  @override
  String get tagCucumber => 'แตงกวา';

  @override
  String get tagChili => 'พริก';

  @override
  String get tagBellPepper => 'พริกหยวก';

  @override
  String get tagCorn => 'ข้าวโพด';

  @override
  String get tagCarrot => 'แครอท';

  @override
  String get tagOlive => 'มะกอก';

  @override
  String get tagGarlic => 'กระเทียม';

  @override
  String get tagOnion => 'หัวหอม';

  @override
  String get tagPotato => 'มันฝรั่ง';

  @override
  String get tagSweetPotato => 'มันเทศ';

  @override
  String get tagGinger => 'ขิง';

  @override
  String get tagShiitake => 'เห็ดหอม';

  @override
  String get tagTeapot => 'กาน้ำชา';

  @override
  String get tagCoffee => 'กาแฟ';

  @override
  String get tagTea => 'ชา';

  @override
  String get tagJuice => 'น้ำผลไม้';

  @override
  String get tagSoftDrink => 'น้ำอัดลม';

  @override
  String get tagBubbleTea => 'ชานมไข่มุก';

  @override
  String get tagSake => 'สาเก';

  @override
  String get tagBeer => 'เบียร์';

  @override
  String get tagChampagne => 'แชมเปญ';

  @override
  String get tagWine => 'ไวน์';

  @override
  String get tagWhiskey => 'วิสกี้';

  @override
  String get tagCocktail => 'ค็อกเทล';

  @override
  String get tagTropicalCocktail => 'ค็อกเทลเขตร้อน';

  @override
  String get tagMateTea => 'ชามาเต้';

  @override
  String get tagMilk => 'นม';

  @override
  String get tagKamaboko => 'คามาโบโกะ';

  @override
  String get tagOden => 'โอเด็ง';

  @override
  String get tagCheese => 'ชีส';

  @override
  String get tagEgg => 'ไข่';

  @override
  String get tagFriedEgg => 'ไข่ทอด';

  @override
  String get tagButter => 'เนย';

  @override
  String get done => 'เสร็จสิ้น';

  @override
  String get save => 'บันทึก';

  @override
  String get searchFood => 'ค้นหาอาหาร';

  @override
  String get noResultsFound => 'ไม่พบผลลัพธ์';

  @override
  String get searchCountry => 'ค้นหาประเทศ';

  @override
  String get searchEmptyTitle => 'กรอกชื่อร้านอาหารเพื่อค้นหา';

  @override
  String get searchEmptyHintTitle => 'เคล็ดลับการค้นหา';

  @override
  String get searchEmptyHintLocation =>
      'เปิดใช้งานตำแหน่งเพื่อแสดงผลลัพธ์ใกล้ๆ ก่อน';

  @override
  String get searchEmptyHintSearch => 'ค้นหาตามชื่อร้านอาหารหรือประเภทอาหาร';

  @override
  String get postErrorPickImage => 'ถ่ายรูปล้มเหลว';

  @override
  String get favoritePostEmptyTitle => 'ไม่มีโพสต์ที่บันทึกไว้';

  @override
  String get favoritePostEmptySubtitle => 'บันทึกโพสต์ที่คุณสนใจ!';

  @override
  String get userInfoFetchError => 'ดึงข้อมูลผู้ใช้ล้มเหลว';

  @override
  String get saved => 'บันทึกแล้ว';

  @override
  String get savedPosts => 'โพสต์ที่บันทึกไว้';

  @override
  String get postSaved => 'บันทึกโพสต์แล้ว';

  @override
  String get postSavedMessage => 'ดูโพสต์ที่บันทึกไว้ในหน้าของฉัน';

  @override
  String get noMapAppAvailable => 'ไม่มีแอปแผนที่ให้ใช้งาน';

  @override
  String get notificationLunchTitle => '#คุณโพสต์มื้ออาหารวันนี้หรือยัง? 🍜';

  @override
  String get notificationLunchBody => 'บันทึกมื้อกลางวันวันนี้กันเถอะ!';

  @override
  String get notificationDinnerTitle => '#คุณโพสต์มื้ออาหารวันนี้หรือยัง? 🍛';

  @override
  String get notificationDinnerBody =>
      'โพสต์มื้ออาหารวันนี้และปิดวันอย่างนุ่มนวล 📷';

  @override
  String get posted => 'โพสต์แล้ว';

  @override
  String get tutorialLocationTitle => 'เปิดใช้งานตำแหน่ง!';

  @override
  String get tutorialLocationSubTitle =>
      'เพื่อค้นหาสถานที่ยอดเยี่ยมใกล้ๆ\nทำให้การค้นหาร้านอาหารง่ายขึ้น';

  @override
  String get tutorialLocationButton => 'เปิดใช้งานตำแหน่ง';

  @override
  String get tutorialNotificationTitle => 'เปิดใช้งานการแจ้งเตือน!';

  @override
  String get tutorialNotificationSubTitle =>
      'เราจะส่งการแจ้งเตือนตอนมื้อกลางวันและมื้อเย็น';

  @override
  String get tutorialNotificationButton => 'เปิดใช้งานการแจ้งเตือน';

  @override
  String get selectMapApp => 'เลือกแอปแผนที่';

  @override
  String get mapAppGoogle => 'Google Maps';

  @override
  String get mapAppApple => 'Apple Maps';

  @override
  String get mapAppBaidu => 'Baidu Maps';

  @override
  String get mapAppMapsMe => 'Maps.me';

  @override
  String get mapAppKakao => 'KakaoMap';

  @override
  String get mapAppNaver => 'Naver Map';

  @override
  String get streakDialogFirstTitle => 'โพสต์เสร็จสมบูรณ์';

  @override
  String get streakDialogFirstContent => 'โพสต์ต่อเนื่อง\nเพื่อรักษา streak';

  @override
  String get streakDialogContinueTitle => 'โพสต์เสร็จสมบูรณ์';

  @override
  String streakDialogContinueContent(int weeks) {
    return 'ติดต่อกัน $weeks สัปดาห์!\nโพสต์ต่อเนื่อง\nเพื่อรักษา streak';
  }

  @override
  String get translatableTranslate => 'แปลภาษา';

  @override
  String get translatableShowOriginal => 'แสดงต้นฉบับ';

  @override
  String get translatableCopy => 'คัดลอก';

  @override
  String get translatableCopied => 'คัดลอกไปยังคลิปบอร์ดแล้ว';

  @override
  String get translatableTranslateFailed => 'ไม่สามารถแปลได้';
}
