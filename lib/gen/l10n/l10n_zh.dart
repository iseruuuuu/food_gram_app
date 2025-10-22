// ignore_for_file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class L10nZh extends L10n {
  L10nZh([String locale = 'zh']) : super(locale);

  @override
  String get close => '关闭';

  @override
  String get cancel => '取消';

  @override
  String get editTitle => '编辑';

  @override
  String get editPostButton => '编辑帖子';

  @override
  String get emailInputField => '请输入您的邮箱地址';

  @override
  String get settingIcon => '选择图标';

  @override
  String get userName => '用户名';

  @override
  String get userNameInputField => '用户名（例如：iseryu）';

  @override
  String get userId => '用户ID';

  @override
  String get userIdInputField => '用户ID（例如：iseryuuu）';

  @override
  String get registerButton => '注册';

  @override
  String get settingAppBar => '设置';

  @override
  String get settingCheckVersion => '检查最新版本';

  @override
  String get settingCheckVersionDialogTitle => '更新信息';

  @override
  String get settingCheckVersionDialogText1 => '有新版本可用。';

  @override
  String get settingCheckVersionDialogText2 => '请更新到最新版本。';

  @override
  String get settingDeveloper => '推特';

  @override
  String get settingGithub => 'Github';

  @override
  String get settingReview => '评价支持';

  @override
  String get settingLicense => '许可证';

  @override
  String get settingShareApp => '分享此应用';

  @override
  String get settingFaq => '常见问题';

  @override
  String get settingPrivacyPolicy => '隐私政策';

  @override
  String get settingTermsOfUse => '使用条款';

  @override
  String get settingContact => '联系我们';

  @override
  String get settingTutorial => '教程';

  @override
  String get settingCredit => '致谢';

  @override
  String get unregistered => '未注册';

  @override
  String get settingBatteryLevel => '电池电量';

  @override
  String get settingDeviceInfo => '设备信息';

  @override
  String get settingIosVersion => 'iOS版本';

  @override
  String get settingAndroidSdk => 'SDK';

  @override
  String get settingAppVersion => '应用版本';

  @override
  String get settingAccount => '账户';

  @override
  String get settingLogoutButton => '登出';

  @override
  String get settingDeleteAccountButton => '申请删除账户';

  @override
  String get settingQuestion => '问题箱';

  @override
  String get settingAccountManagement => '账户管理';

  @override
  String get settingRestoreSuccessTitle => '恢复成功';

  @override
  String get settingRestoreSuccessSubtitle => '高级功能已启用！';

  @override
  String get settingRestoreFailureTitle => '恢复失败';

  @override
  String get settingRestoreFailureSubtitle => '没有购买记录？请联系客服';

  @override
  String get settingRestore => '恢复购买';

  @override
  String get shareButton => '分享';

  @override
  String get postFoodName => '食物名称';

  @override
  String get postFoodNameInputField => '输入食物名称（必填）';

  @override
  String get postRestaurantNameInputField => '添加餐厅（必填）';

  @override
  String get postComment => '输入评论（可选）';

  @override
  String get postCommentInputField => '评论';

  @override
  String get postError => '提交失败';

  @override
  String get postCategoryTitle => '选择国家/菜系标签（可选）';

  @override
  String get postCountryCategory => '国家';

  @override
  String get postCuisineCategory => '菜系';

  @override
  String get postTitle => '发布';

  @override
  String get postMissingInfo => '请填写所有必填项';

  @override
  String get postMissingPhoto => '请添加照片';

  @override
  String get postMissingFoodName => '请输入您吃了什么';

  @override
  String get postMissingRestaurant => '请添加餐厅名称';

  @override
  String get postPhotoSuccess => '照片添加成功';

  @override
  String get postCameraPermission => '需要相机权限';

  @override
  String get postAlbumPermission => '需要照片库权限';

  @override
  String get postSuccess => '发布成功';

  @override
  String get postSearchError => '无法搜索地点名称';

  @override
  String get editUpdateButton => '更新';

  @override
  String get editBio => '个人简介（可选）';

  @override
  String get editBioInputField => '输入个人简介';

  @override
  String get editFavoriteTagTitle => '选择收藏标签';

  @override
  String get emptyPosts => '暂无帖子';

  @override
  String get searchEmptyResult => '未找到搜索结果。';

  @override
  String get searchButton => '搜索';

  @override
  String get searchRestaurantTitle => '搜索餐厅';

  @override
  String get searchUserTitle => '用户搜索';

  @override
  String get searchUserHeader => '用户搜索（按帖子数量）';

  @override
  String searchUserPostCount(Object count) {
    return '帖子数: $count';
  }

  @override
  String get searchUserLatestPosts => '最新帖子';

  @override
  String get searchUserNoUsers => '没有找到有帖子的用户';

  @override
  String get unknown => '未知・无结果';

  @override
  String get profilePostCount => '帖子';

  @override
  String get profilePointCount => '积分';

  @override
  String get profileEditButton => '编辑个人资料';

  @override
  String get profileExchangePointsButton => '兑换积分';

  @override
  String get profileFavoriteGenre => '收藏类型';

  @override
  String get likeButton => '点赞';

  @override
  String get shareReviewPrefix => '刚刚分享了我吃的美食评论！';

  @override
  String get shareReviewSuffix => '更多内容，请查看foodGram！';

  @override
  String get postDetailSheetTitle => '关于此帖子';

  @override
  String get postDetailSheetShareButton => '分享此帖子';

  @override
  String get postDetailSheetReportButton => '举报此帖子';

  @override
  String get postDetailSheetBlockButton => '屏蔽此用户';

  @override
  String get dialogYesButton => '是';

  @override
  String get dialogNoButton => '否';

  @override
  String get dialogReportTitle => '举报帖子';

  @override
  String get dialogReportDescription1 => '您将举报此帖子。';

  @override
  String get dialogReportDescription2 => '您将跳转到Google表单。';

  @override
  String get dialogBlockTitle => '屏蔽确认';

  @override
  String get dialogBlockDescription1 => '您要屏蔽此用户吗？';

  @override
  String get dialogBlockDescription2 => '这将隐藏该用户的帖子。';

  @override
  String get dialogBlockDescription3 => '被屏蔽的用户将保存在本地。';

  @override
  String get dialogDeleteTitle => '删除帖子';

  @override
  String get heartLimitMessage => '您已达到今天10个赞的限制。请明天再试。';

  @override
  String get dialogDeleteDescription1 => '您要删除此帖子吗？';

  @override
  String get dialogDeleteDescription2 => '删除后无法恢复。';

  @override
  String get dialogDeleteError => '删除失败。';

  @override
  String get dialogLogoutTitle => '确认登出';

  @override
  String get dialogLogoutDescription1 => '您要登出吗？';

  @override
  String get dialogLogoutDescription2 => '账户状态保存在服务器上。';

  @override
  String get dialogLogoutButton => '登出';

  @override
  String get errorTitle => '通信错误';

  @override
  String get errorDescription1 => '发生连接错误。';

  @override
  String get errorDescription2 => '请检查网络连接并重试。';

  @override
  String get errorRefreshButton => '重新加载';

  @override
  String get error => '发生错误';

  @override
  String get mapLoadingError => '发生错误';

  @override
  String get mapLoadingRestaurant => '正在获取餐厅信息...';

  @override
  String get appShareTitle => '分享';

  @override
  String get appShareStoreButton => '分享此店铺';

  @override
  String get appShareInstagramButton => '在Instagram上分享';

  @override
  String get appShareGoButton => '前往此店铺';

  @override
  String get appShareCloseButton => '关闭';

  @override
  String get appRestaurantLabel => '搜索餐厅';

  @override
  String get appRequestTitle => '🙇 请开启当前位置 🙇';

  @override
  String get appRequestReason => '餐厅选择需要当前位置数据';

  @override
  String get appRequestInduction => '以下按钮将带您到设置界面';

  @override
  String get appRequestOpenSetting => '打开设置界面';

  @override
  String get appTitle => 'FoodGram';

  @override
  String get appSubtitle => '分享您的美味时刻';

  @override
  String get agreeToTheTermsOfUse => '请同意使用条款';

  @override
  String get restaurantCategoryList => '按国家选择菜系';

  @override
  String get cookingCategoryList => '选择食物标签';

  @override
  String get restaurantReviewNew => '新';

  @override
  String get restaurantReviewViewDetails => '查看详情';

  @override
  String get restaurantReviewOtherPosts => '其他帖子';

  @override
  String get restaurantReviewReviewList => '评论列表';

  @override
  String get restaurantReviewError => '发生错误';

  @override
  String get nearbyRestaurants => '📍附近餐厅';

  @override
  String get seeMore => '查看更多';

  @override
  String get selectCountryTag => '选择国家标签';

  @override
  String get selectFavoriteTag => '选择收藏标签';

  @override
  String get favoriteTagPlaceholder => '选择您的收藏标签';

  @override
  String get selectFoodTag => '选择食物标签';

  @override
  String get tabHome => '美食';

  @override
  String get tabMap => '地图';

  @override
  String get tabSearch => '搜索';

  @override
  String get tabMyPage => '我的页面';

  @override
  String get tabSetting => '设置';

  @override
  String get logoutFailure => '登出失败';

  @override
  String get accountDeletionFailure => '账户删除失败';

  @override
  String get appleLoginFailure => 'Apple登录不可用';

  @override
  String get emailAuthenticationFailure => '邮箱认证失败';

  @override
  String get loginError => '登录错误';

  @override
  String get loginSuccessful => '登录成功';

  @override
  String get emailAuthentication => '请通过您的邮箱应用进行认证';

  @override
  String get emailEmpty => '未输入邮箱地址';

  @override
  String get email => '邮箱地址';

  @override
  String get enterTheCorrectFormat => '请输入正确格式';

  @override
  String get authInvalidFormat => '邮箱地址格式不正确。';

  @override
  String get authSocketException => '网络有问题。请检查连接。';

  @override
  String get camera => '相机';

  @override
  String get album => '相册';

  @override
  String get snsLogin => 'SNS登录';

  @override
  String get tutorialFirstPageTitle => '分享您的美味时刻';

  @override
  String get tutorialFirstPageSubTitle => '通过FoodGram，让每顿饭都更加特别。\n享受发现新口味的乐趣！';

  @override
  String get tutorialSecondPageTitle => '此应用独有的美食地图';

  @override
  String get tutorialSecondPageSubTitle => '让我们为此应用创建一个独特的地图。\n您的帖子将帮助地图发展。';

  @override
  String get tutorialThirdPageTitle => '使用条款';

  @override
  String get tutorialThirdPageSubTitle =>
      '・请注意分享个人信息，如姓名、地址、电话号码或位置。\n\n・避免发布攻击性、不当或有害内容，不要未经许可使用他人作品。\n\n・与食物无关的帖子可能会被删除。\n\n・反复违反规则或发布令人反感内容的用户可能会被管理团队删除。\n\n・我们期待与大家一起改进这个应用。开发者';

  @override
  String get tutorialThirdPageButton => '同意使用条款';

  @override
  String get tutorialThirdPageClose => '关闭';

  @override
  String get detailMenuShare => '分享';

  @override
  String get detailMenuVisit => '访问';

  @override
  String get detailMenuPost => '发布';

  @override
  String get detailMenuSearch => '搜索';

  @override
  String get forceUpdateTitle => '更新通知';

  @override
  String get forceUpdateText => '此应用的新版本已发布。请更新应用以确保最新功能和安全环境。';

  @override
  String get forceUpdateButtonTitle => '更新';

  @override
  String get newAccountImportantTitle => '重要提示';

  @override
  String get newAccountImportant =>
      '创建账户时，请不要在用户名或用户ID中包含邮箱地址或电话号码等个人信息。为确保安全的在线体验，请选择不会泄露个人信息的名称。';

  @override
  String get accountRegistrationSuccess => '账户注册完成';

  @override
  String get accountRegistrationError => '发生错误';

  @override
  String get requiredInfoMissing => '缺少必要信息';

  @override
  String get shareTextAndImage => '分享文字和图片';

  @override
  String get shareImageOnly => '仅分享图片';

  @override
  String get foodCategoryNoodles => '面条';

  @override
  String get foodCategoryMeat => '肉类';

  @override
  String get foodCategoryFastFood => '快餐';

  @override
  String get foodCategoryRiceDishes => '米饭类';

  @override
  String get foodCategorySeafood => '海鲜';

  @override
  String get foodCategoryBread => '面包';

  @override
  String get foodCategorySweetsAndSnacks => '甜点和零食';

  @override
  String get foodCategoryFruits => '水果';

  @override
  String get foodCategoryVegetables => '蔬菜';

  @override
  String get foodCategoryBeverages => '饮料';

  @override
  String get foodCategoryOthers => '其他';

  @override
  String get foodCategoryAll => '全部';

  @override
  String get rankEmerald => '翡翠';

  @override
  String get rankDiamond => '钻石';

  @override
  String get rankGold => '黄金';

  @override
  String get rankSilver => '白银';

  @override
  String get rankBronze => '青铜';

  @override
  String get rank => '等级';

  @override
  String get promoteDialogTitle => '✨成为高级会员✨';

  @override
  String get promoteDialogTrophyTitle => '奖杯功能';

  @override
  String get promoteDialogTrophyDesc => '根据您的活动显示奖杯。';

  @override
  String get promoteDialogTagTitle => '自定义标签';

  @override
  String get promoteDialogTagDesc => '为您喜爱的食物设置自定义标签。';

  @override
  String get promoteDialogIconTitle => '自定义图标';

  @override
  String get promoteDialogIconDesc => '将您的个人资料图标设置为任何您喜欢的图片！！';

  @override
  String get promoteDialogAdTitle => '无广告';

  @override
  String get promoteDialogAdDesc => '移除所有广告！！';

  @override
  String get promoteDialogButton => '成为高级会员';

  @override
  String get promoteDialogLater => '稍后再说';

  @override
  String get paywallTitle => 'FoodGram高级版';

  @override
  String get paywallPremiumTitle => '✨ 高级特权 ✨';

  @override
  String get paywallTrophyTitle => '奖杯功能';

  @override
  String get paywallTrophyDesc => '根据活动显示奖杯';

  @override
  String get paywallTagTitle => '自定义标签';

  @override
  String get paywallTagDesc => '为喜爱的食物创建独特标签';

  @override
  String get paywallIconTitle => '自定义图标';

  @override
  String get paywallIconDesc => '设置您自己的个人资料图标';

  @override
  String get paywallAdTitle => '无广告';

  @override
  String get paywallAdDesc => '移除所有广告';

  @override
  String get paywallComingSoon => '即将推出...';

  @override
  String get paywallNewFeatures => '高级会员专属新功能\n即将推出！';

  @override
  String get paywallSubscribeButton => '成为高级会员';

  @override
  String get paywallPrice => '每月 \$3 / 月';

  @override
  String get paywallCancelNote => '随时可取消';

  @override
  String get paywallWelcomeTitle => '欢迎加入\nFoodGram会员！';

  @override
  String get paywallSkip => '跳过';

  @override
  String get purchaseError => '购买过程中发生错误';

  @override
  String get anonymousPost => '匿名发布';

  @override
  String get anonymousPostDescription => '用户名将被隐藏';

  @override
  String get anonymousShare => '匿名分享';

  @override
  String get anonymousUpdate => '匿名更新';

  @override
  String get anonymousPoster => '匿名发布者';

  @override
  String get anonymousUsername => 'foodgramer';

  @override
  String get tagOtherCuisine => '其他菜系';

  @override
  String get tagOtherFood => '其他食物';

  @override
  String get tagJapaneseCuisine => '日本料理';

  @override
  String get tagItalianCuisine => '意大利料理';

  @override
  String get tagFrenchCuisine => '法国料理';

  @override
  String get tagChineseCuisine => '中国料理';

  @override
  String get tagIndianCuisine => '印度料理';

  @override
  String get tagMexicanCuisine => '墨西哥料理';

  @override
  String get tagHongKongCuisine => '香港料理';

  @override
  String get tagAmericanCuisine => '美国料理';

  @override
  String get tagMediterraneanCuisine => '地中海料理';

  @override
  String get tagThaiCuisine => '泰国料理';

  @override
  String get tagGreekCuisine => '希腊料理';

  @override
  String get tagTurkishCuisine => '土耳其料理';

  @override
  String get tagKoreanCuisine => '韩国料理';

  @override
  String get tagRussianCuisine => '俄罗斯料理';

  @override
  String get tagSpanishCuisine => '西班牙料理';

  @override
  String get tagVietnameseCuisine => '越南料理';

  @override
  String get tagPortugueseCuisine => '葡萄牙料理';

  @override
  String get tagAustrianCuisine => '奥地利料理';

  @override
  String get tagBelgianCuisine => '比利时料理';

  @override
  String get tagSwedishCuisine => '瑞典料理';

  @override
  String get tagGermanCuisine => '德国料理';

  @override
  String get tagBritishCuisine => '英国料理';

  @override
  String get tagDutchCuisine => '荷兰料理';

  @override
  String get tagAustralianCuisine => '澳大利亚料理';

  @override
  String get tagBrazilianCuisine => '巴西料理';

  @override
  String get tagArgentineCuisine => '阿根廷料理';

  @override
  String get tagColombianCuisine => '哥伦比亚料理';

  @override
  String get tagPeruvianCuisine => '秘鲁料理';

  @override
  String get tagNorwegianCuisine => '挪威料理';

  @override
  String get tagDanishCuisine => '丹麦料理';

  @override
  String get tagPolishCuisine => '波兰料理';

  @override
  String get tagCzechCuisine => '捷克料理';

  @override
  String get tagHungarianCuisine => '匈牙利料理';

  @override
  String get tagSouthAfricanCuisine => '南非料理';

  @override
  String get tagEgyptianCuisine => '埃及料理';

  @override
  String get tagMoroccanCuisine => '摩洛哥料理';

  @override
  String get tagNewZealandCuisine => '新西兰料理';

  @override
  String get tagFilipinoCuisine => '菲律宾料理';

  @override
  String get tagMalaysianCuisine => '马来西亚料理';

  @override
  String get tagSingaporeanCuisine => '新加坡料理';

  @override
  String get tagIndonesianCuisine => '印度尼西亚料理';

  @override
  String get tagIranianCuisine => '伊朗料理';

  @override
  String get tagSaudiArabianCuisine => '沙特阿拉伯料理';

  @override
  String get tagMongolianCuisine => '蒙古料理';

  @override
  String get tagCambodianCuisine => '柬埔寨料理';

  @override
  String get tagLaotianCuisine => '老挝料理';

  @override
  String get tagCubanCuisine => '古巴料理';

  @override
  String get tagJamaicanCuisine => '牙买加料理';

  @override
  String get tagChileanCuisine => '智利料理';

  @override
  String get tagVenezuelanCuisine => '委内瑞拉料理';

  @override
  String get tagPanamanianCuisine => '巴拿马料理';

  @override
  String get tagBolivianCuisine => '玻利维亚料理';

  @override
  String get tagIcelandicCuisine => '冰岛料理';

  @override
  String get tagLithuanianCuisine => '立陶宛料理';

  @override
  String get tagEstonianCuisine => '爱沙尼亚料理';

  @override
  String get tagLatvianCuisine => '拉脱维亚料理';

  @override
  String get tagFinnishCuisine => '芬兰料理';

  @override
  String get tagCroatianCuisine => '克罗地亚料理';

  @override
  String get tagSlovenianCuisine => '斯洛文尼亚料理';

  @override
  String get tagSlovakCuisine => '斯洛伐克料理';

  @override
  String get tagRomanianCuisine => '罗马尼亚料理';

  @override
  String get tagBulgarianCuisine => '保加利亚料理';

  @override
  String get tagSerbianCuisine => '塞尔维亚料理';

  @override
  String get tagAlbanianCuisine => '阿尔巴尼亚料理';

  @override
  String get tagGeorgianCuisine => '格鲁吉亚料理';

  @override
  String get tagArmenianCuisine => '亚美尼亚料理';

  @override
  String get tagAzerbaijaniCuisine => '阿塞拜疆料理';

  @override
  String get tagUkrainianCuisine => '乌克兰料理';

  @override
  String get tagBelarusianCuisine => '白俄罗斯料理';

  @override
  String get tagKazakhCuisine => '哈萨克斯坦料理';

  @override
  String get tagUzbekCuisine => '乌兹别克斯坦料理';

  @override
  String get tagKyrgyzCuisine => '吉尔吉斯斯坦料理';

  @override
  String get tagTurkmenCuisine => '土库曼斯坦料理';

  @override
  String get tagTajikCuisine => '塔吉克斯坦料理';

  @override
  String get tagMaldivianCuisine => '马尔代夫料理';

  @override
  String get tagNepaleseCuisine => '尼泊尔料理';

  @override
  String get tagBangladeshiCuisine => '孟加拉国料理';

  @override
  String get tagMyanmarCuisine => '缅甸料理';

  @override
  String get tagBruneianCuisine => '文莱料理';

  @override
  String get tagTaiwaneseCuisine => '台湾料理';

  @override
  String get tagNigerianCuisine => '尼日利亚料理';

  @override
  String get tagKenyanCuisine => '肯尼亚料理';

  @override
  String get tagGhanaianCuisine => '加纳料理';

  @override
  String get tagEthiopianCuisine => '埃塞俄比亚料理';

  @override
  String get tagSudaneseCuisine => '苏丹料理';

  @override
  String get tagTunisianCuisine => '突尼斯料理';

  @override
  String get tagAngolanCuisine => '安哥拉料理';

  @override
  String get tagCongoleseCuisine => '刚果料理';

  @override
  String get tagZimbabweanCuisine => '津巴布韦料理';

  @override
  String get tagMalagasyCuisine => '马达加斯加料理';

  @override
  String get tagPapuaNewGuineanCuisine => '巴布亚新几内亚料理';

  @override
  String get tagSamoanCuisine => '萨摩亚料理';

  @override
  String get tagTuvaluanCuisine => '图瓦卢料理';

  @override
  String get tagFijianCuisine => '斐济料理';

  @override
  String get tagPalauanCuisine => '帕劳料理';

  @override
  String get tagKiribatiCuisine => '基里巴斯料理';

  @override
  String get tagVanuatuanCuisine => '瓦努阿图料理';

  @override
  String get tagBahrainiCuisine => '巴林料理';

  @override
  String get tagQatariCuisine => '卡塔尔料理';

  @override
  String get tagKuwaitiCuisine => '科威特料理';

  @override
  String get tagOmaniCuisine => '阿曼料理';

  @override
  String get tagYemeniCuisine => '也门料理';

  @override
  String get tagLebaneseCuisine => '黎巴嫩料理';

  @override
  String get tagSyrianCuisine => '叙利亚料理';

  @override
  String get tagJordanianCuisine => '约旦料理';

  @override
  String get tagNoodles => '面条';

  @override
  String get tagMeatDishes => '肉类料理';

  @override
  String get tagFastFood => '快餐';

  @override
  String get tagRiceDishes => '米饭料理';

  @override
  String get tagSeafood => '海鲜';

  @override
  String get tagBread => '面包';

  @override
  String get tagSweetsAndSnacks => '甜点和零食';

  @override
  String get tagFruits => '水果';

  @override
  String get tagVegetables => '蔬菜';

  @override
  String get tagBeverages => '饮料';

  @override
  String get tagOthers => '其他';

  @override
  String get tagPasta => '意大利面';

  @override
  String get tagRamen => '拉面';

  @override
  String get tagSteak => '牛排';

  @override
  String get tagYakiniku => '烤肉';

  @override
  String get tagChicken => '鸡肉';

  @override
  String get tagBacon => '培根';

  @override
  String get tagHamburger => '汉堡包';

  @override
  String get tagFrenchFries => '薯条';

  @override
  String get tagPizza => '披萨';

  @override
  String get tagTacos => '墨西哥卷饼';

  @override
  String get tagTamales => '玉米粽子';

  @override
  String get tagGyoza => '饺子';

  @override
  String get tagFriedShrimp => '炸虾';

  @override
  String get tagHotPot => '火锅';

  @override
  String get tagCurry => '咖喱';

  @override
  String get tagPaella => '海鲜饭';

  @override
  String get tagFondue => '奶酪火锅';

  @override
  String get tagOnigiri => '饭团';

  @override
  String get tagRice => '米饭';

  @override
  String get tagBento => '便当';

  @override
  String get tagSushi => '寿司';

  @override
  String get tagFish => '鱼';

  @override
  String get tagOctopus => '章鱼';

  @override
  String get tagSquid => '鱿鱼';

  @override
  String get tagShrimp => '虾';

  @override
  String get tagCrab => '螃蟹';

  @override
  String get tagShellfish => '贝类';

  @override
  String get tagOyster => '牡蛎';

  @override
  String get tagSandwich => '三明治';

  @override
  String get tagHotDog => '热狗';

  @override
  String get tagDonut => '甜甜圈';

  @override
  String get tagPancake => '煎饼';

  @override
  String get tagCroissant => '牛角面包';

  @override
  String get tagBagel => '贝果';

  @override
  String get tagBaguette => '法棍';

  @override
  String get tagPretzel => '椒盐卷饼';

  @override
  String get tagBurrito => '墨西哥卷';

  @override
  String get tagIceCream => '冰淇淋';

  @override
  String get tagPudding => '布丁';

  @override
  String get tagRiceCracker => '米饼';

  @override
  String get tagDango => '团子';

  @override
  String get tagShavedIce => '刨冰';

  @override
  String get tagPie => '派';

  @override
  String get tagCupcake => '纸杯蛋糕';

  @override
  String get tagCake => '蛋糕';

  @override
  String get tagCandy => '糖果';

  @override
  String get tagLollipop => '棒棒糖';

  @override
  String get tagChocolate => '巧克力';

  @override
  String get tagPopcorn => '爆米花';

  @override
  String get tagCookie => '饼干';

  @override
  String get tagPeanuts => '花生';

  @override
  String get tagBeans => '豆子';

  @override
  String get tagChestnut => '栗子';

  @override
  String get tagFortuneCookie => '幸运饼干';

  @override
  String get tagMooncake => '月饼';

  @override
  String get tagHoney => '蜂蜜';

  @override
  String get tagWaffle => '华夫饼';

  @override
  String get tagApple => '苹果';

  @override
  String get tagPear => '梨';

  @override
  String get tagOrange => '橙子';

  @override
  String get tagLemon => '柠檬';

  @override
  String get tagLime => '青柠';

  @override
  String get tagBanana => '香蕉';

  @override
  String get tagWatermelon => '西瓜';

  @override
  String get tagGrapes => '葡萄';

  @override
  String get tagStrawberry => '草莓';

  @override
  String get tagBlueberry => '蓝莓';

  @override
  String get tagMelon => '甜瓜';

  @override
  String get tagCherry => '樱桃';

  @override
  String get tagPeach => '桃子';

  @override
  String get tagMango => '芒果';

  @override
  String get tagPineapple => '菠萝';

  @override
  String get tagCoconut => '椰子';

  @override
  String get tagKiwi => '猕猴桃';

  @override
  String get tagSalad => '沙拉';

  @override
  String get tagTomato => '番茄';

  @override
  String get tagEggplant => '茄子';

  @override
  String get tagAvocado => '牛油果';

  @override
  String get tagGreenBeans => '青豆';

  @override
  String get tagBroccoli => '西兰花';

  @override
  String get tagLettuce => '生菜';

  @override
  String get tagCucumber => '黄瓜';

  @override
  String get tagChili => '辣椒';

  @override
  String get tagBellPepper => '甜椒';

  @override
  String get tagCorn => '玉米';

  @override
  String get tagCarrot => '胡萝卜';

  @override
  String get tagOlive => '橄榄';

  @override
  String get tagGarlic => '大蒜';

  @override
  String get tagOnion => '洋葱';

  @override
  String get tagPotato => '土豆';

  @override
  String get tagSweetPotato => '红薯';

  @override
  String get tagGinger => '姜';

  @override
  String get tagShiitake => '香菇';

  @override
  String get tagTeapot => '茶壶';

  @override
  String get tagCoffee => '咖啡';

  @override
  String get tagTea => '茶';

  @override
  String get tagJuice => '果汁';

  @override
  String get tagSoftDrink => '软饮料';

  @override
  String get tagBubbleTea => '珍珠奶茶';

  @override
  String get tagSake => '清酒';

  @override
  String get tagBeer => '啤酒';

  @override
  String get tagChampagne => '香槟';

  @override
  String get tagWine => '葡萄酒';

  @override
  String get tagWhiskey => '威士忌';

  @override
  String get tagCocktail => '鸡尾酒';

  @override
  String get tagTropicalCocktail => '热带鸡尾酒';

  @override
  String get tagMateTea => '马黛茶';

  @override
  String get tagMilk => '牛奶';

  @override
  String get tagKamaboko => '鱼糕';

  @override
  String get tagOden => '关东煮';

  @override
  String get tagCheese => '奶酪';

  @override
  String get tagEgg => '鸡蛋';

  @override
  String get tagFriedEgg => '煎蛋';

  @override
  String get tagButter => '黄油';

  @override
  String get done => '完成';

  @override
  String get save => '保存';

  @override
  String get searchFood => '搜索食物';

  @override
  String get noResultsFound => '未找到搜索结果';

  @override
  String get searchCountry => '搜索国家';

  @override
  String get searchEmptyTitle => '输入餐厅名称进行搜索';

  @override
  String get searchEmptyHintTitle => '搜索提示';

  @override
  String get searchEmptyHintLocation => '开启位置信息可优先显示附近结果';

  @override
  String get searchEmptyHintSearch => '可通过餐厅名称或菜系类型搜索';

  @override
  String get postErrorPickImage => '拍照失败';

  @override
  String get favoritePostEmptyTitle => '没有保存的帖子';

  @override
  String get favoritePostEmptySubtitle => '保存您感兴趣的帖子吧！';

  @override
  String get userInfoFetchError => '获取用户信息失败';

  @override
  String get saved => '已保存';

  @override
  String get savedPosts => '保存的帖子';

  @override
  String get postSaved => '帖子已保存';

  @override
  String get postSavedMessage => '您可以在我的页面查看保存的帖子';

  @override
  String get noMapAppAvailable => '没有可用的地图应用';

  @override
  String get notificationLunchTitle => '#今天的饭菜，已经发了吗？🍜';

  @override
  String get notificationLunchBody => '今天的午餐，趁还记得的时候记录一下吧？';

  @override
  String get notificationDinnerTitle => '#今天的饭菜，已经发了吗？🍛';

  @override
  String get notificationDinnerBody => '发布今天的饭菜，轻松结束这一天吧📷';
}
