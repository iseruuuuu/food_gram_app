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
  String get settingPremiumMembership => '成为高级会员，享受特别体验';

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
  String get searchTitle => '搜索';

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
  String get shareInviteMessage => '在 FoodGram 分享美味吧！';

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
  String get tabMyMap => '我的地图';

  @override
  String get tabSearch => '搜索';

  @override
  String get tabMyPage => '我的页面';

  @override
  String get tabSetting => '设置';

  @override
  String get mapStatsVisitedArea => '访问区域';

  @override
  String get mapStatsPosts => '投稿';

  @override
  String get mapStatsActivityDays => '活动天数';

  @override
  String get mapStatsPrefectures => '都道府县';

  @override
  String get mapStatsAchievementRate => '达成率';

  @override
  String get mapStatsVisitedCountries => '访问国家';

  @override
  String get mapViewTypeRecord => '记录';

  @override
  String get mapViewTypeJapan => '日本';

  @override
  String get mapViewTypeWorld => '世界';

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
  String get tutorialDiscoverTitle => '去发现下一道心仪美食！';

  @override
  String get tutorialDiscoverSubTitle => '每次滑动都有新发现。\n现在就去探索美味吧。';

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
  String get paywallTrophyTitle => '发帖越多获得称号';

  @override
  String get paywallTrophyDesc => '称号会随帖子数量升级';

  @override
  String get paywallTagTitle => '设置喜爱类别';

  @override
  String get paywallTagDesc => '让个人资料更有风格';

  @override
  String get paywallIconTitle => '用任意图片做头像';

  @override
  String get paywallIconDesc => '更显眼，脱颖而出';

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
  String get paywallTagline => '✨ 升级你的美食体验 ✨';

  @override
  String get paywallMapTitle => '地图查找';

  @override
  String get paywallMapDesc => '更快更容易找到餐厅';

  @override
  String get paywallRankTitle => '发帖越多获得称号';

  @override
  String get paywallRankDesc => '称号会随帖子数量升级';

  @override
  String get paywallGenreTitle => '设置喜爱类别';

  @override
  String get paywallGenreDesc => '让个人资料更有风格';

  @override
  String get paywallCustomIconTitle => '用任意图片做头像';

  @override
  String get paywallCustomIconDesc => '更显眼，脱颖而出';

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

  @override
  String get posted => '发布';

  @override
  String get tutorialLocationTitle => '开启位置！';

  @override
  String get tutorialLocationSubTitle => '为了找到附近的好地方，\n让餐厅发现更轻松';

  @override
  String get tutorialLocationButton => '开启位置';

  @override
  String get tutorialNotificationTitle => '开启通知！';

  @override
  String get tutorialNotificationSubTitle => '我们将在午餐和晚餐时间发送提醒';

  @override
  String get tutorialNotificationButton => '开启通知';

  @override
  String get selectMapApp => '选择地图应用';

  @override
  String get mapAppGoogle => '谷歌地图';

  @override
  String get mapAppApple => '苹果地图';

  @override
  String get mapAppBaidu => '百度地图';

  @override
  String get mapAppMapsMe => 'Maps.me';

  @override
  String get mapAppKakao => 'KakaoMap';

  @override
  String get mapAppNaver => 'Naver地图';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class L10nZhTw extends L10nZh {
  L10nZhTw() : super('zh_TW');

  @override
  String get close => '關閉';

  @override
  String get cancel => '取消';

  @override
  String get editTitle => '編輯';

  @override
  String get editPostButton => '編輯貼文';

  @override
  String get emailInputField => '請輸入您的電子郵件地址';

  @override
  String get settingIcon => '選擇圖示';

  @override
  String get userName => '使用者名稱';

  @override
  String get userNameInputField => '使用者名稱（例如：iseryu）';

  @override
  String get userId => '使用者ID';

  @override
  String get userIdInputField => '使用者ID（例如：iseryuuu）';

  @override
  String get registerButton => '註冊';

  @override
  String get settingAppBar => '設定';

  @override
  String get settingCheckVersion => '檢查最新版本';

  @override
  String get settingCheckVersionDialogTitle => '更新資訊';

  @override
  String get settingCheckVersionDialogText1 => '有新版本可用。';

  @override
  String get settingCheckVersionDialogText2 => '請更新到最新版本。';

  @override
  String get settingDeveloper => '推特';

  @override
  String get settingGithub => 'Github';

  @override
  String get settingReview => '評價支援';

  @override
  String get settingLicense => '授權';

  @override
  String get settingShareApp => '分享此應用程式';

  @override
  String get settingFaq => '常見問題';

  @override
  String get settingPrivacyPolicy => '隱私權政策';

  @override
  String get settingTermsOfUse => '使用條款';

  @override
  String get settingContact => '聯絡我們';

  @override
  String get settingTutorial => '教學';

  @override
  String get settingCredit => '致謝';

  @override
  String get unregistered => '未註冊';

  @override
  String get settingBatteryLevel => '電池電量';

  @override
  String get settingDeviceInfo => '裝置資訊';

  @override
  String get settingIosVersion => 'iOS版本';

  @override
  String get settingAndroidSdk => 'SDK';

  @override
  String get settingAppVersion => '應用程式版本';

  @override
  String get settingAccount => '帳戶';

  @override
  String get settingLogoutButton => '登出';

  @override
  String get settingDeleteAccountButton => '申請刪除帳戶';

  @override
  String get settingQuestion => '問題箱';

  @override
  String get settingAccountManagement => '帳戶管理';

  @override
  String get settingRestoreSuccessTitle => '還原成功';

  @override
  String get settingRestoreSuccessSubtitle => '進階功能已啟用！';

  @override
  String get settingRestoreFailureTitle => '還原失敗';

  @override
  String get settingRestoreFailureSubtitle => '沒有購買記錄？請聯絡客服';

  @override
  String get settingRestore => '還原購買';

  @override
  String get settingPremiumMembership => '成為進階會員，享受特別體驗';

  @override
  String get shareButton => '分享';

  @override
  String get postFoodName => '食物名稱';

  @override
  String get postFoodNameInputField => '輸入食物名稱（必填）';

  @override
  String get postRestaurantNameInputField => '新增餐廳（必填）';

  @override
  String get postComment => '輸入評論（選填）';

  @override
  String get postCommentInputField => '評論';

  @override
  String get postError => '提交失敗';

  @override
  String get postCategoryTitle => '選擇國家/菜系標籤（選填）';

  @override
  String get postCountryCategory => '國家';

  @override
  String get postCuisineCategory => '菜系';

  @override
  String get postTitle => '發布';

  @override
  String get postMissingInfo => '請填寫所有必填項目';

  @override
  String get postMissingPhoto => '請新增照片';

  @override
  String get postMissingFoodName => '請輸入您吃了什麼';

  @override
  String get postMissingRestaurant => '請新增餐廳名稱';

  @override
  String get postPhotoSuccess => '照片新增成功';

  @override
  String get postCameraPermission => '需要相機權限';

  @override
  String get postAlbumPermission => '需要照片庫權限';

  @override
  String get postSuccess => '發布成功';

  @override
  String get postSearchError => '無法搜尋地點名稱';

  @override
  String get editUpdateButton => '更新';

  @override
  String get editBio => '個人簡介（選填）';

  @override
  String get editBioInputField => '輸入個人簡介';

  @override
  String get editFavoriteTagTitle => '選擇收藏標籤';

  @override
  String get emptyPosts => '暫無貼文';

  @override
  String get searchEmptyResult => '未找到搜尋結果。';

  @override
  String get searchButton => '搜尋';

  @override
  String get searchTitle => '搜尋';

  @override
  String get searchRestaurantTitle => '搜尋餐廳';

  @override
  String get searchUserTitle => '使用者搜尋';

  @override
  String get searchUserHeader => '使用者搜尋（依貼文數量）';

  @override
  String searchUserPostCount(Object count) {
    return '貼文數: $count';
  }

  @override
  String get searchUserLatestPosts => '最新貼文';

  @override
  String get searchUserNoUsers => '沒有找到有貼文的使用者';

  @override
  String get unknown => '未知・無結果';

  @override
  String get profilePostCount => '貼文';

  @override
  String get profilePointCount => '積分';

  @override
  String get profileEditButton => '編輯個人資料';

  @override
  String get profileExchangePointsButton => '兌換積分';

  @override
  String get profileFavoriteGenre => '收藏類型';

  @override
  String get likeButton => '按讚';

  @override
  String get shareReviewPrefix => '剛剛分享了我吃的美食評論！';

  @override
  String get shareReviewSuffix => '更多內容，請查看foodGram！';

  @override
  String get postDetailSheetTitle => '關於此貼文';

  @override
  String get postDetailSheetShareButton => '分享此貼文';

  @override
  String get postDetailSheetReportButton => '檢舉此貼文';

  @override
  String get postDetailSheetBlockButton => '封鎖此使用者';

  @override
  String get dialogYesButton => '是';

  @override
  String get dialogNoButton => '否';

  @override
  String get dialogReportTitle => '檢舉貼文';

  @override
  String get dialogReportDescription1 => '您將檢舉此貼文。';

  @override
  String get dialogReportDescription2 => '您將跳轉到Google表單。';

  @override
  String get dialogBlockTitle => '封鎖確認';

  @override
  String get dialogBlockDescription1 => '您要封鎖此使用者嗎？';

  @override
  String get dialogBlockDescription2 => '這將隱藏該使用者的貼文。';

  @override
  String get dialogBlockDescription3 => '被封鎖的使用者將儲存在本機。';

  @override
  String get dialogDeleteTitle => '刪除貼文';

  @override
  String get heartLimitMessage => '您已達到今天10個讚的限制。請明天再試。';

  @override
  String get dialogDeleteDescription1 => '您要刪除此貼文嗎？';

  @override
  String get dialogDeleteDescription2 => '刪除後無法還原。';

  @override
  String get dialogDeleteError => '刪除失敗。';

  @override
  String get dialogLogoutTitle => '確認登出';

  @override
  String get dialogLogoutDescription1 => '您要登出嗎？';

  @override
  String get dialogLogoutDescription2 => '帳戶狀態儲存在伺服器上。';

  @override
  String get dialogLogoutButton => '登出';

  @override
  String get errorTitle => '通訊錯誤';

  @override
  String get errorDescription1 => '發生連線錯誤。';

  @override
  String get errorDescription2 => '請檢查網路連線並重試。';

  @override
  String get errorRefreshButton => '重新載入';

  @override
  String get error => '發生錯誤';

  @override
  String get mapLoadingError => '發生錯誤';

  @override
  String get mapLoadingRestaurant => '正在取得餐廳資訊...';

  @override
  String get appShareTitle => '分享';

  @override
  String get appShareStoreButton => '分享此店家';

  @override
  String get appShareInstagramButton => '在Instagram上分享';

  @override
  String get appShareGoButton => '前往此店家';

  @override
  String get appShareCloseButton => '關閉';

  @override
  String get shareInviteMessage => '在 FoodGram 分享美味吧！';

  @override
  String get appRestaurantLabel => '搜尋餐廳';

  @override
  String get appRequestTitle => '🙇 請開啟目前位置 🙇';

  @override
  String get appRequestReason => '餐廳選擇需要目前位置資料';

  @override
  String get appRequestInduction => '以下按鈕將帶您到設定介面';

  @override
  String get appRequestOpenSetting => '開啟設定介面';

  @override
  String get appTitle => 'FoodGram';

  @override
  String get appSubtitle => '分享您的美味時刻';

  @override
  String get agreeToTheTermsOfUse => '請同意使用條款';

  @override
  String get restaurantCategoryList => '依國家選擇菜系';

  @override
  String get cookingCategoryList => '選擇食物標籤';

  @override
  String get restaurantReviewNew => '新';

  @override
  String get restaurantReviewViewDetails => '查看詳情';

  @override
  String get restaurantReviewOtherPosts => '其他貼文';

  @override
  String get restaurantReviewReviewList => '評論列表';

  @override
  String get restaurantReviewError => '發生錯誤';

  @override
  String get nearbyRestaurants => '📍附近餐廳';

  @override
  String get seeMore => '查看更多';

  @override
  String get selectCountryTag => '選擇國家標籤';

  @override
  String get selectFavoriteTag => '選擇收藏標籤';

  @override
  String get favoriteTagPlaceholder => '選擇您的收藏標籤';

  @override
  String get selectFoodTag => '選擇食物標籤';

  @override
  String get tabHome => '美食';

  @override
  String get tabMap => '地圖';

  @override
  String get tabMyMap => '我的地圖';

  @override
  String get tabSearch => '搜尋';

  @override
  String get tabMyPage => '我的頁面';

  @override
  String get tabSetting => '設定';

  @override
  String get mapStatsVisitedArea => '訪問區域';

  @override
  String get mapStatsPosts => '投稿';

  @override
  String get mapStatsActivityDays => '活動天數';

  @override
  String get mapStatsPrefectures => '都道府縣';

  @override
  String get mapStatsAchievementRate => '達成率';

  @override
  String get mapStatsVisitedCountries => '訪問國家';

  @override
  String get mapViewTypeRecord => '記錄';

  @override
  String get mapViewTypeJapan => '日本';

  @override
  String get mapViewTypeWorld => '世界';

  @override
  String get logoutFailure => '登出失敗';

  @override
  String get accountDeletionFailure => '帳戶刪除失敗';

  @override
  String get appleLoginFailure => 'Apple登入不可用';

  @override
  String get emailAuthenticationFailure => '電子郵件認證失敗';

  @override
  String get loginError => '登入錯誤';

  @override
  String get loginSuccessful => '登入成功';

  @override
  String get emailAuthentication => '請透過您的電子郵件應用程式進行認證';

  @override
  String get emailEmpty => '未輸入電子郵件地址';

  @override
  String get email => '電子郵件地址';

  @override
  String get enterTheCorrectFormat => '請輸入正確格式';

  @override
  String get authInvalidFormat => '電子郵件地址格式不正確。';

  @override
  String get authSocketException => '網路有問題。請檢查連線。';

  @override
  String get camera => '相機';

  @override
  String get album => '相簿';

  @override
  String get snsLogin => 'SNS登入';

  @override
  String get tutorialFirstPageTitle => '分享您的美味時刻';

  @override
  String get tutorialFirstPageSubTitle => '透過FoodGram，讓每頓飯都更加特別。\n享受發現新口味的樂趣！';

  @override
  String get tutorialDiscoverTitle => '去發現下一道心儀美食！';

  @override
  String get tutorialDiscoverSubTitle => '每次滑動都有新發現。\n現在就去探索美味吧。';

  @override
  String get tutorialSecondPageTitle => '此應用程式獨有的美食地圖';

  @override
  String get tutorialSecondPageSubTitle => '讓我們為此應用程式建立一個獨特的地圖。\n您的貼文將幫助地圖發展。';

  @override
  String get tutorialThirdPageTitle => '使用條款';

  @override
  String get tutorialThirdPageSubTitle =>
      '・請注意分享個人資訊，如姓名、地址、電話號碼或位置。\n\n・避免發布攻擊性、不當或有害內容，不要未經許可使用他人作品。\n\n・與食物無關的貼文可能會被刪除。\n\n・反覆違反規則或發布令人反感內容的使用者可能會被管理團隊刪除。\n\n・我們期待與大家一起改進這個應用程式。開發者';

  @override
  String get tutorialThirdPageButton => '同意使用條款';

  @override
  String get tutorialThirdPageClose => '關閉';

  @override
  String get detailMenuShare => '分享';

  @override
  String get detailMenuVisit => '造訪';

  @override
  String get detailMenuPost => '發布';

  @override
  String get detailMenuSearch => '搜尋';

  @override
  String get forceUpdateTitle => '更新通知';

  @override
  String get forceUpdateText => '此應用程式的新版本已發布。請更新應用程式以確保最新功能和安全環境。';

  @override
  String get forceUpdateButtonTitle => '更新';

  @override
  String get newAccountImportantTitle => '重要提示';

  @override
  String get newAccountImportant =>
      '建立帳戶時，請不要在使用者名稱或使用者ID中包含電子郵件地址或電話號碼等個人資訊。為確保安全的線上體驗，請選擇不會洩露個人資訊的名稱。';

  @override
  String get accountRegistrationSuccess => '帳戶註冊完成';

  @override
  String get accountRegistrationError => '發生錯誤';

  @override
  String get requiredInfoMissing => '缺少必要資訊';

  @override
  String get shareTextAndImage => '分享文字和圖片';

  @override
  String get shareImageOnly => '僅分享圖片';

  @override
  String get foodCategoryNoodles => '麵條';

  @override
  String get foodCategoryMeat => '肉類';

  @override
  String get foodCategoryFastFood => '速食';

  @override
  String get foodCategoryRiceDishes => '米飯類';

  @override
  String get foodCategorySeafood => '海鮮';

  @override
  String get foodCategoryBread => '麵包';

  @override
  String get foodCategorySweetsAndSnacks => '甜點和零食';

  @override
  String get foodCategoryFruits => '水果';

  @override
  String get foodCategoryVegetables => '蔬菜';

  @override
  String get foodCategoryBeverages => '飲料';

  @override
  String get foodCategoryOthers => '其他';

  @override
  String get foodCategoryAll => '全部';

  @override
  String get rankEmerald => '翡翠';

  @override
  String get rankDiamond => '鑽石';

  @override
  String get rankGold => '黃金';

  @override
  String get rankSilver => '白銀';

  @override
  String get rankBronze => '青銅';

  @override
  String get rank => '等級';

  @override
  String get promoteDialogTitle => '✨成為進階會員✨';

  @override
  String get promoteDialogTrophyTitle => '獎盃功能';

  @override
  String get promoteDialogTrophyDesc => '根據您的活動顯示獎盃。';

  @override
  String get promoteDialogTagTitle => '自訂標籤';

  @override
  String get promoteDialogTagDesc => '為您喜愛的食物設定自訂標籤。';

  @override
  String get promoteDialogIconTitle => '自訂圖示';

  @override
  String get promoteDialogIconDesc => '將您的個人資料圖示設定為任何您喜歡的圖片！！';

  @override
  String get promoteDialogAdTitle => '無廣告';

  @override
  String get promoteDialogAdDesc => '移除所有廣告！！';

  @override
  String get promoteDialogButton => '成為進階會員';

  @override
  String get promoteDialogLater => '稍後再說';

  @override
  String get paywallTitle => 'FoodGram進階版';

  @override
  String get paywallPremiumTitle => '✨ 進階特權 ✨';

  @override
  String get paywallTrophyTitle => '發文越多獲得稱號';

  @override
  String get paywallTrophyDesc => '稱號會隨貼文數量升級';

  @override
  String get paywallTagTitle => '設定喜愛類別';

  @override
  String get paywallTagDesc => '讓個人資料更有風格';

  @override
  String get paywallIconTitle => '用任意圖片做頭像';

  @override
  String get paywallIconDesc => '更顯眼，脫穎而出';

  @override
  String get paywallAdTitle => '無廣告';

  @override
  String get paywallAdDesc => '移除所有廣告';

  @override
  String get paywallComingSoon => '即將推出...';

  @override
  String get paywallNewFeatures => '進階會員專屬新功能\n即將推出！';

  @override
  String get paywallSubscribeButton => '成為進階會員';

  @override
  String get paywallPrice => '每月 \$3 / 月';

  @override
  String get paywallCancelNote => '隨時可取消';

  @override
  String get paywallWelcomeTitle => '歡迎加入\nFoodGram會員！';

  @override
  String get paywallSkip => '跳過';

  @override
  String get purchaseError => '購買過程中發生錯誤';

  @override
  String get paywallTagline => '✨ 升級你的美食體驗 ✨';

  @override
  String get paywallMapTitle => '地圖查找';

  @override
  String get paywallMapDesc => '更快更容易找到餐廳';

  @override
  String get paywallRankTitle => '發文越多獲得稱號';

  @override
  String get paywallRankDesc => '稱號會隨貼文數量升級';

  @override
  String get paywallGenreTitle => '設定喜愛類別';

  @override
  String get paywallGenreDesc => '讓個人資料更有風格';

  @override
  String get paywallCustomIconTitle => '用任意圖片做頭像';

  @override
  String get paywallCustomIconDesc => '更顯眼，脫穎而出';

  @override
  String get anonymousPost => '匿名發布';

  @override
  String get anonymousPostDescription => '使用者名稱將被隱藏';

  @override
  String get anonymousShare => '匿名分享';

  @override
  String get anonymousUpdate => '匿名更新';

  @override
  String get anonymousPoster => '匿名發布者';

  @override
  String get anonymousUsername => 'foodgramer';

  @override
  String get tagOtherCuisine => '其他菜系';

  @override
  String get tagOtherFood => '其他食物';

  @override
  String get tagJapaneseCuisine => '日本料理';

  @override
  String get tagItalianCuisine => '義大利料理';

  @override
  String get tagFrenchCuisine => '法國料理';

  @override
  String get tagChineseCuisine => '中國料理';

  @override
  String get tagIndianCuisine => '印度料理';

  @override
  String get tagMexicanCuisine => '墨西哥料理';

  @override
  String get tagHongKongCuisine => '香港料理';

  @override
  String get tagAmericanCuisine => '美國料理';

  @override
  String get tagMediterraneanCuisine => '地中海料理';

  @override
  String get tagThaiCuisine => '泰國料理';

  @override
  String get tagGreekCuisine => '希臘料理';

  @override
  String get tagTurkishCuisine => '土耳其料理';

  @override
  String get tagKoreanCuisine => '韓國料理';

  @override
  String get tagRussianCuisine => '俄羅斯料理';

  @override
  String get tagSpanishCuisine => '西班牙料理';

  @override
  String get tagVietnameseCuisine => '越南料理';

  @override
  String get tagPortugueseCuisine => '葡萄牙料理';

  @override
  String get tagAustrianCuisine => '奧地利料理';

  @override
  String get tagBelgianCuisine => '比利時料理';

  @override
  String get tagSwedishCuisine => '瑞典料理';

  @override
  String get tagGermanCuisine => '德國料理';

  @override
  String get tagBritishCuisine => '英國料理';

  @override
  String get tagDutchCuisine => '荷蘭料理';

  @override
  String get tagAustralianCuisine => '澳洲料理';

  @override
  String get tagBrazilianCuisine => '巴西料理';

  @override
  String get tagArgentineCuisine => '阿根廷料理';

  @override
  String get tagColombianCuisine => '哥倫比亞料理';

  @override
  String get tagPeruvianCuisine => '秘魯料理';

  @override
  String get tagNorwegianCuisine => '挪威料理';

  @override
  String get tagDanishCuisine => '丹麥料理';

  @override
  String get tagPolishCuisine => '波蘭料理';

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
  String get tagNewZealandCuisine => '紐西蘭料理';

  @override
  String get tagFilipinoCuisine => '菲律賓料理';

  @override
  String get tagMalaysianCuisine => '馬來西亞料理';

  @override
  String get tagSingaporeanCuisine => '新加坡料理';

  @override
  String get tagIndonesianCuisine => '印尼料理';

  @override
  String get tagIranianCuisine => '伊朗料理';

  @override
  String get tagSaudiArabianCuisine => '沙烏地阿拉伯料理';

  @override
  String get tagMongolianCuisine => '蒙古料理';

  @override
  String get tagCambodianCuisine => '柬埔寨料理';

  @override
  String get tagLaotianCuisine => '寮國料理';

  @override
  String get tagCubanCuisine => '古巴料理';

  @override
  String get tagJamaicanCuisine => '牙買加料理';

  @override
  String get tagChileanCuisine => '智利料理';

  @override
  String get tagVenezuelanCuisine => '委內瑞拉料理';

  @override
  String get tagPanamanianCuisine => '巴拿馬料理';

  @override
  String get tagBolivianCuisine => '玻利維亞料理';

  @override
  String get tagIcelandicCuisine => '冰島料理';

  @override
  String get tagLithuanianCuisine => '立陶宛料理';

  @override
  String get tagEstonianCuisine => '愛沙尼亞料理';

  @override
  String get tagLatvianCuisine => '拉脫維亞料理';

  @override
  String get tagFinnishCuisine => '芬蘭料理';

  @override
  String get tagCroatianCuisine => '克羅埃西亞料理';

  @override
  String get tagSlovenianCuisine => '斯洛維尼亞料理';

  @override
  String get tagSlovakCuisine => '斯洛伐克料理';

  @override
  String get tagRomanianCuisine => '羅馬尼亞料理';

  @override
  String get tagBulgarianCuisine => '保加利亞料理';

  @override
  String get tagSerbianCuisine => '塞爾維亞料理';

  @override
  String get tagAlbanianCuisine => '阿爾巴尼亞料理';

  @override
  String get tagGeorgianCuisine => '喬治亞料理';

  @override
  String get tagArmenianCuisine => '亞美尼亞料理';

  @override
  String get tagAzerbaijaniCuisine => '亞塞拜然料理';

  @override
  String get tagUkrainianCuisine => '烏克蘭料理';

  @override
  String get tagBelarusianCuisine => '白俄羅斯料理';

  @override
  String get tagKazakhCuisine => '哈薩克料理';

  @override
  String get tagUzbekCuisine => '烏茲別克料理';

  @override
  String get tagKyrgyzCuisine => '吉爾吉斯料理';

  @override
  String get tagTurkmenCuisine => '土庫曼料理';

  @override
  String get tagTajikCuisine => '塔吉克料理';

  @override
  String get tagMaldivianCuisine => '馬爾地夫料理';

  @override
  String get tagNepaleseCuisine => '尼泊爾料理';

  @override
  String get tagBangladeshiCuisine => '孟加拉料理';

  @override
  String get tagMyanmarCuisine => '緬甸料理';

  @override
  String get tagBruneianCuisine => '汶萊料理';

  @override
  String get tagTaiwaneseCuisine => '台灣料理';

  @override
  String get tagNigerianCuisine => '奈及利亞料理';

  @override
  String get tagKenyanCuisine => '肯亞料理';

  @override
  String get tagGhanaianCuisine => '迦納料理';

  @override
  String get tagEthiopianCuisine => '衣索比亞料理';

  @override
  String get tagSudaneseCuisine => '蘇丹料理';

  @override
  String get tagTunisianCuisine => '突尼西亞料理';

  @override
  String get tagAngolanCuisine => '安哥拉料理';

  @override
  String get tagCongoleseCuisine => '剛果料理';

  @override
  String get tagZimbabweanCuisine => '辛巴威料理';

  @override
  String get tagMalagasyCuisine => '馬達加斯加料理';

  @override
  String get tagPapuaNewGuineanCuisine => '巴布亞紐幾內亞料理';

  @override
  String get tagSamoanCuisine => '薩摩亞料理';

  @override
  String get tagTuvaluanCuisine => '吐瓦魯料理';

  @override
  String get tagFijianCuisine => '斐濟料理';

  @override
  String get tagPalauanCuisine => '帛琉料理';

  @override
  String get tagKiribatiCuisine => '吉里巴斯料理';

  @override
  String get tagVanuatuanCuisine => '萬那杜料理';

  @override
  String get tagBahrainiCuisine => '巴林料理';

  @override
  String get tagQatariCuisine => '卡達料理';

  @override
  String get tagKuwaitiCuisine => '科威特料理';

  @override
  String get tagOmaniCuisine => '阿曼料理';

  @override
  String get tagYemeniCuisine => '葉門料理';

  @override
  String get tagLebaneseCuisine => '黎巴嫩料理';

  @override
  String get tagSyrianCuisine => '敘利亞料理';

  @override
  String get tagJordanianCuisine => '約旦料理';

  @override
  String get tagNoodles => '麵條';

  @override
  String get tagMeatDishes => '肉類料理';

  @override
  String get tagFastFood => '速食';

  @override
  String get tagRiceDishes => '米飯料理';

  @override
  String get tagSeafood => '海鮮';

  @override
  String get tagBread => '麵包';

  @override
  String get tagSweetsAndSnacks => '甜點和零食';

  @override
  String get tagFruits => '水果';

  @override
  String get tagVegetables => '蔬菜';

  @override
  String get tagBeverages => '飲料';

  @override
  String get tagOthers => '其他';

  @override
  String get tagPasta => '義大利麵';

  @override
  String get tagRamen => '拉麵';

  @override
  String get tagSteak => '牛排';

  @override
  String get tagYakiniku => '烤肉';

  @override
  String get tagChicken => '雞肉';

  @override
  String get tagBacon => '培根';

  @override
  String get tagHamburger => '漢堡';

  @override
  String get tagFrenchFries => '薯條';

  @override
  String get tagPizza => '披薩';

  @override
  String get tagTacos => '墨西哥捲餅';

  @override
  String get tagTamales => '玉米粽';

  @override
  String get tagGyoza => '餃子';

  @override
  String get tagFriedShrimp => '炸蝦';

  @override
  String get tagHotPot => '火鍋';

  @override
  String get tagCurry => '咖哩';

  @override
  String get tagPaella => '海鮮飯';

  @override
  String get tagFondue => '起司火鍋';

  @override
  String get tagOnigiri => '飯糰';

  @override
  String get tagRice => '米飯';

  @override
  String get tagBento => '便當';

  @override
  String get tagSushi => '壽司';

  @override
  String get tagFish => '魚';

  @override
  String get tagOctopus => '章魚';

  @override
  String get tagSquid => '魷魚';

  @override
  String get tagShrimp => '蝦';

  @override
  String get tagCrab => '螃蟹';

  @override
  String get tagShellfish => '貝類';

  @override
  String get tagOyster => '牡蠣';

  @override
  String get tagSandwich => '三明治';

  @override
  String get tagHotDog => '熱狗';

  @override
  String get tagDonut => '甜甜圈';

  @override
  String get tagPancake => '煎餅';

  @override
  String get tagCroissant => '可頌';

  @override
  String get tagBagel => '貝果';

  @override
  String get tagBaguette => '法式長棍麵包';

  @override
  String get tagPretzel => '椒鹽捲餅';

  @override
  String get tagBurrito => '墨西哥捲';

  @override
  String get tagIceCream => '冰淇淋';

  @override
  String get tagPudding => '布丁';

  @override
  String get tagRiceCracker => '米餅';

  @override
  String get tagDango => '糰子';

  @override
  String get tagShavedIce => '刨冰';

  @override
  String get tagPie => '派';

  @override
  String get tagCupcake => '杯子蛋糕';

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
  String get tagCookie => '餅乾';

  @override
  String get tagPeanuts => '花生';

  @override
  String get tagBeans => '豆子';

  @override
  String get tagChestnut => '栗子';

  @override
  String get tagFortuneCookie => '幸運籤餅';

  @override
  String get tagMooncake => '月餅';

  @override
  String get tagHoney => '蜂蜜';

  @override
  String get tagWaffle => '鬆餅';

  @override
  String get tagApple => '蘋果';

  @override
  String get tagPear => '梨';

  @override
  String get tagOrange => '橘子';

  @override
  String get tagLemon => '檸檬';

  @override
  String get tagLime => '萊姆';

  @override
  String get tagBanana => '香蕉';

  @override
  String get tagWatermelon => '西瓜';

  @override
  String get tagGrapes => '葡萄';

  @override
  String get tagStrawberry => '草莓';

  @override
  String get tagBlueberry => '藍莓';

  @override
  String get tagMelon => '甜瓜';

  @override
  String get tagCherry => '櫻桃';

  @override
  String get tagPeach => '桃子';

  @override
  String get tagMango => '芒果';

  @override
  String get tagPineapple => '鳳梨';

  @override
  String get tagCoconut => '椰子';

  @override
  String get tagKiwi => '奇異果';

  @override
  String get tagSalad => '沙拉';

  @override
  String get tagTomato => '番茄';

  @override
  String get tagEggplant => '茄子';

  @override
  String get tagAvocado => '酪梨';

  @override
  String get tagGreenBeans => '四季豆';

  @override
  String get tagBroccoli => '花椰菜';

  @override
  String get tagLettuce => '生菜';

  @override
  String get tagCucumber => '小黃瓜';

  @override
  String get tagChili => '辣椒';

  @override
  String get tagBellPepper => '甜椒';

  @override
  String get tagCorn => '玉米';

  @override
  String get tagCarrot => '胡蘿蔔';

  @override
  String get tagOlive => '橄欖';

  @override
  String get tagGarlic => '大蒜';

  @override
  String get tagOnion => '洋蔥';

  @override
  String get tagPotato => '馬鈴薯';

  @override
  String get tagSweetPotato => '地瓜';

  @override
  String get tagGinger => '薑';

  @override
  String get tagShiitake => '香菇';

  @override
  String get tagTeapot => '茶壺';

  @override
  String get tagCoffee => '咖啡';

  @override
  String get tagTea => '茶';

  @override
  String get tagJuice => '果汁';

  @override
  String get tagSoftDrink => '汽水';

  @override
  String get tagBubbleTea => '珍珠奶茶';

  @override
  String get tagSake => '清酒';

  @override
  String get tagBeer => '啤酒';

  @override
  String get tagChampagne => '香檳';

  @override
  String get tagWine => '葡萄酒';

  @override
  String get tagWhiskey => '威士忌';

  @override
  String get tagCocktail => '雞尾酒';

  @override
  String get tagTropicalCocktail => '熱帶雞尾酒';

  @override
  String get tagMateTea => '馬黛茶';

  @override
  String get tagMilk => '牛奶';

  @override
  String get tagKamaboko => '魚板';

  @override
  String get tagOden => '關東煮';

  @override
  String get tagCheese => '起司';

  @override
  String get tagEgg => '雞蛋';

  @override
  String get tagFriedEgg => '煎蛋';

  @override
  String get tagButter => '奶油';

  @override
  String get done => '完成';

  @override
  String get save => '儲存';

  @override
  String get searchFood => '搜尋食物';

  @override
  String get noResultsFound => '未找到搜尋結果';

  @override
  String get searchCountry => '搜尋國家';

  @override
  String get searchEmptyTitle => '輸入餐廳名稱進行搜尋';

  @override
  String get searchEmptyHintTitle => '搜尋提示';

  @override
  String get searchEmptyHintLocation => '開啟位置資訊可優先顯示附近結果';

  @override
  String get searchEmptyHintSearch => '可透過餐廳名稱或菜系類型搜尋';

  @override
  String get postErrorPickImage => '拍照失敗';

  @override
  String get favoritePostEmptyTitle => '沒有儲存的貼文';

  @override
  String get favoritePostEmptySubtitle => '儲存您感興趣的貼文吧！';

  @override
  String get userInfoFetchError => '取得使用者資訊失敗';

  @override
  String get saved => '已儲存';

  @override
  String get savedPosts => '儲存的貼文';

  @override
  String get postSaved => '貼文已儲存';

  @override
  String get postSavedMessage => '您可以在我的頁面查看儲存的貼文';

  @override
  String get noMapAppAvailable => '沒有可用的地圖應用程式';

  @override
  String get notificationLunchTitle => '#今天的飯菜，已經發了嗎？🍜';

  @override
  String get notificationLunchBody => '今天的午餐，趁還記得的時候記錄一下吧？';

  @override
  String get notificationDinnerTitle => '#今天的飯菜，已經發了嗎？🍛';

  @override
  String get notificationDinnerBody => '發布今天的飯菜，輕鬆結束這一天吧📷';

  @override
  String get posted => '發布';

  @override
  String get tutorialLocationTitle => '開啟位置！';

  @override
  String get tutorialLocationSubTitle => '為了找到附近的好地方，\n讓餐廳發現更輕鬆';

  @override
  String get tutorialLocationButton => '開啟位置';

  @override
  String get tutorialNotificationTitle => '開啟通知！';

  @override
  String get tutorialNotificationSubTitle => '我們將在午餐和晚餐時間發送提醒';

  @override
  String get tutorialNotificationButton => '開啟通知';

  @override
  String get selectMapApp => '選擇地圖應用程式';

  @override
  String get mapAppGoogle => 'Google地圖';

  @override
  String get mapAppApple => 'Apple地圖';

  @override
  String get mapAppBaidu => '百度地圖';

  @override
  String get mapAppMapsMe => 'Maps.me';

  @override
  String get mapAppKakao => 'KakaoMap';

  @override
  String get mapAppNaver => 'Naver地圖';
}
