// ignore_for_file

import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class L10nJa extends L10n {
  L10nJa([String locale = 'ja']) : super(locale);

  @override
  String get close => '閉じる';

  @override
  String get cancel => 'キャンセル';

  @override
  String get editTitle => '編集';

  @override
  String get editPostButton => '編集する';

  @override
  String get emailInputField => 'メールアドレスを入力してください';

  @override
  String get settingsIcon => 'アイコンの設定';

  @override
  String get userName => 'ユーザー名';

  @override
  String get userNameInputField => 'ユーザー名（例：いせりゅー）';

  @override
  String get userId => 'ユーザーID';

  @override
  String get userIdInputField => 'ユーザーID （例：iseryuuu）';

  @override
  String get registerButton => '登録';

  @override
  String get settingsAppBar => '基本設定';

  @override
  String get settingsCheckVersion => 'アップデート';

  @override
  String get settingsCheckVersionDialogTitle => '更新情報';

  @override
  String get settingsCheckVersionDialogText1 => '新しいバージョンがご利用いただけます。';

  @override
  String get settingsCheckVersionDialogText2 => '最新版にアップデートしてご利用ください。';

  @override
  String get settingsDeveloper => '公式Twitter';

  @override
  String get settingsGithub => 'Github';

  @override
  String get settingsReview => 'レビューする';

  @override
  String get settingsLicense => 'ライセンス';

  @override
  String get settingsShareApp => 'シェアする';

  @override
  String get settingsFaq => 'FAQ';

  @override
  String get settingsPrivacyPolicy => 'プライバシー';

  @override
  String get settingsTermsOfUse => '利用規約';

  @override
  String get settingsContact => 'お問い合せ';

  @override
  String get settingsTutorial => 'チュートリアル';

  @override
  String get settingsCredit => 'クレジット';

  @override
  String get settingsBatteryLevel => 'バッテリー残量';

  @override
  String get settingsDeviceInfo => '端末情報';

  @override
  String get settingsIosVersion => 'iOSバージョン';

  @override
  String get settingsAndroidSdk => 'SDK';

  @override
  String get settingsAppVersion => 'アプリバージョン';

  @override
  String get settingsAccount => 'アカウント';

  @override
  String get settingsLogoutButton => 'ログアウト';

  @override
  String get settingsDeleteAccountButton => 'アカウント削除申請';

  @override
  String get settingQuestion => '質問箱';

  @override
  String get postShareButton => 'シェア';

  @override
  String get postFoodName => '食べたもの';

  @override
  String get postFoodNameInputField => '食べたものを入力(必須)';

  @override
  String get postRestaurantNameInputField => 'レストラン名を追加(必須)';

  @override
  String get postComment => 'コメントを入力(任意)';

  @override
  String get postCommentInputField => 'コメント(任意)';

  @override
  String get postError => '投稿失敗';

  @override
  String get postCategoryTitle => '国・料理カテゴリーの選択(任意)';

  @override
  String get postCountryCategory => '国';

  @override
  String get postCuisineCategory => '料理';

  @override
  String get postTitle => '投稿';

  @override
  String get editUpdateButton => '更新';

  @override
  String get editBio => '自己紹介(任意)';

  @override
  String get editBioInputField => '自己紹介を入力してください';

  @override
  String get emptyPosts => '投稿がありません';

  @override
  String get searchEmptyResult => '該当する場所が見つかりませんでした';

  @override
  String get homeCooking => '自炊';

  @override
  String get unknown => '不明・ヒットなし';

  @override
  String get profilePostCount => '投稿';

  @override
  String get profilePointCount => 'ポイント';

  @override
  String get profileEditButton => 'プロフィールを編集';

  @override
  String get profileExchangePointsButton => 'ポイントを交換する';

  @override
  String get postDetailLikeButton => 'いいね';

  @override
  String get shareReviewPrefix => 'で食べたレビューを投稿しました！';

  @override
  String get shareReviewSuffix => '詳しくはfoodGramで確認してみよう！';

  @override
  String get postDetailSheetTitle => 'この投稿について';

  @override
  String get postDetailSheetShareButton => 'この投稿をシェアする';

  @override
  String get postDetailSheetReportButton => 'この投稿を報告する';

  @override
  String get postDetailSheetBlockButton => 'このユーザーをブロックする';

  @override
  String get postSearchError => '場所名の検索ができません';

  @override
  String get dialogYesButton => 'はい';

  @override
  String get dialogNoButton => 'いいえ';

  @override
  String get dialogReportTitle => '投稿の報告';

  @override
  String get dialogReportDescription1 => 'この投稿について報告を行います';

  @override
  String get dialogReportDescription2 => 'Googleフォームに遷移します';

  @override
  String get dialogBlockTitle => 'ブロック確認';

  @override
  String get dialogBlockDescription1 => 'このユーザーをブロックしますか？';

  @override
  String get dialogBlockDescription2 => 'このユーザーの投稿を非表示にします';

  @override
  String get dialogBlockDescription3 => 'ブロックしたユーザーはローカルで保存します';

  @override
  String get dialogDeleteTitle => '投稿の削除';

  @override
  String get dialogDeleteDescription1 => 'この投稿を削除しますか？';

  @override
  String get dialogDeleteDescription2 => '一度削除してしまうと復元できません';

  @override
  String get dialogDeleteError => '削除が失敗しました';

  @override
  String get dialogLogoutTitle => 'ログアウトの確認';

  @override
  String get dialogLogoutDescription1 => 'ログアウトしますか?';

  @override
  String get dialogLogoutDescription2 => 'アカウントの状態はサーバー上に保存されています。';

  @override
  String get dialogLogoutButton => 'ログアウト';

  @override
  String get errorTitle => '通信エラー';

  @override
  String get errorDescription1 => '接続エラーが発生しました';

  @override
  String get errorDescription2 => 'ネットワーク接続を確認し、もう一度試してください';

  @override
  String get errorRefreshButton => '再読み込み';

  @override
  String get appShareTitle => '共有';

  @override
  String get appShareStoreButton => 'このお店を共有する';

  @override
  String get appShareInstagramButton => 'Instagramで共有する';

  @override
  String get appShareGoButton => 'このお店に行ってみる';

  @override
  String get appShareCloseButton => '閉じる';

  @override
  String get agreeToTheTermsOfUse => '利用規約に同意してください';

  @override
  String get appRestaurantLabel => 'レストランを検索';

  @override
  String get restaurantCategoryList => '国別料理を選ぶ';

  @override
  String get cookingCategoryList => '料理カテゴリーを選ぶ';

  @override
  String get tabHome => 'フード';

  @override
  String get tabMap => 'マップ';

  @override
  String get tabSearch => '探す';

  @override
  String get tabMyPage => 'マイページ';

  @override
  String get tabSetting => '設定';

  @override
  String get logoutFailure => 'ログアウト失敗';

  @override
  String get accountDeletionFailure => 'アカウント削除失敗';

  @override
  String get appleLoginFailure => 'Appleログインはできません';

  @override
  String get emailAuthenticationFailure => 'メール認証の失敗';

  @override
  String get loginError => 'ログインエラー';

  @override
  String get loginSuccessful => 'ログイン成功';

  @override
  String get emailAuthentication => 'メールアプリで認証をしてください';

  @override
  String get emailEmpty => 'メールアドレスが入力されていません';

  @override
  String get error => 'エラーが発生しました';

  @override
  String get appRequestTitle => '🙇現在地をオンにしてください🙇';

  @override
  String get appRequestReason => 'レストランの選択には現在地のデータが必要になります';

  @override
  String get appRequestInduction => '以下のボタンから設定画面に遷移します';

  @override
  String get appRequestOpenSetting => '設定画面を開く';

  @override
  String get email => 'メールアドレス';

  @override
  String get enterTheCorrectFormat => '正しい形式で入力してください';

  @override
  String get camera => 'カメラ';

  @override
  String get album => 'アルバム';

  @override
  String get snsLogin => 'SNSログイン';

  @override
  String get tutorialFirstPageTitle => '美味しい瞬間、シェアしよう';

  @override
  String get tutorialFirstPageSubTitle => 'FoodGramで、毎日の食事がもっと特別に\n新しい味との出会いを楽しもう';

  @override
  String get tutorialSecondPageTitle => 'このアプリだけのフードマップ';

  @override
  String get tutorialSecondPageSubTitle => 'このアプリだけのマップ作りをしよう\nあなたの投稿でマップが進化していく';

  @override
  String get tutorialThirdPageTitle => '利用規約';

  @override
  String get tutorialThirdPageSubTitle => '・氏名、住所、電話番号などの個人情報や位置情報の公開には注意しましょう。\n\n・攻撃的、不適切、または有害なコンテンツの投稿を避け、他人の作品を無断で使用しないようにしましょう。\n\n・食べ物以外の投稿は削除させていただく場合があります。\n\n・違反が繰り返されるユーザーや不快なコンテンツは運営側で削除します。\n\n・みなさんと一緒にこのアプリをより良くしていけることを楽しみにしています by 開発者';

  @override
  String get tutorialThirdPageButton => '利用規約に同意する';

  @override
  String get tutorialThirdPageClose => '閉じる';

  @override
  String get settingRestoreSuccessTitle => '復元が成功しました';

  @override
  String get settingRestoreSuccessSubtitle => 'プレミアム機能が有効になりました！';

  @override
  String get settingRestoreFailureTitle => '復元失敗';

  @override
  String get settingRestoreFailureSubtitle => '購入履歴がない場合はサポートにご連絡を';

  @override
  String get settingRestore => '購入を復元';

  @override
  String get authInvalidFormat => 'メールアドレスのフォーマットが間違っています';

  @override
  String get authSocketException => 'ネットワークに問題があります。接続を確認してください';

  @override
  String get detailMenuShare => 'シェア';

  @override
  String get detailMenuVisit => '行く';

  @override
  String get detailMenuPost => '投稿';

  @override
  String get detailMenuSearch => '調べる';

  @override
  String get forceUpdateTitle => 'アップデートのお知らせ';

  @override
  String get forceUpdateText => 'このアプリの新しいバージョンがリリースされました。最新の機能や安全な環境でご利用いただくために、アプリをアップデートしてください。';

  @override
  String get forceUpdateButtonTitle => 'アップデート';

  @override
  String get mapLoadingError => 'エラーが発生しました';

  @override
  String get mapLoadingRestaurant => '店舗情報を取得中...';

  @override
  String get postMissingInfo => '必須項目を入力してください';

  @override
  String get postPhotoSuccess => '写真を追加しました';

  @override
  String get postCameraPermission => 'カメラの許可が必要です';

  @override
  String get postAlbumPermission => 'フォトライブラリの許可が必要です';

  @override
  String get postSuccess => '投稿が完了しました';

  @override
  String get searchButton => '検索';

  @override
  String get newAccountImportantTitle => '重要な注意事項';

  @override
  String get newAccountImportant => 'アカウントを作成する際、ユーザー名やユーザーIDには、メールアドレスや電話番号などの個人情報を含めないようにしてください。安全なオンライン体験のため、個人情報が特定されない名前を設定してください。';

  @override
  String get accountRegistrationSuccess => 'アカウントの登録が完了しました';

  @override
  String get accountRegistrationError => 'エラーが発生しました';

  @override
  String get requiredInfoMissing => '必要な情報が入力されていません';

  @override
  String get shareTextAndImage => 'テキスト＋画像でシェア';

  @override
  String get shareImageOnly => '画像のみシェア';

  @override
  String get foodCategoryNoodles => '麺類';

  @override
  String get foodCategoryMeat => '肉料理';

  @override
  String get foodCategoryFastFood => 'ファストフード';

  @override
  String get foodCategoryRiceDishes => 'ごはん';

  @override
  String get foodCategorySeafood => '魚介';

  @override
  String get foodCategoryBread => 'パン';

  @override
  String get foodCategorySweetsAndSnacks => 'スイーツ';

  @override
  String get foodCategoryFruits => 'フルーツ';

  @override
  String get foodCategoryVegetables => '野菜';

  @override
  String get foodCategoryBeverages => '飲み物';

  @override
  String get foodCategoryOthers => 'その他';

  @override
  String get foodCategoryAll => '全て';

  @override
  String get rankEmerald => 'エメラルド';

  @override
  String get rankDiamond => 'ダイヤモンド';

  @override
  String get rankGold => 'ゴールド';

  @override
  String get rankSilver => 'シルバー';

  @override
  String get rankBronze => 'ブロンズ';

  @override
  String get rank => 'ランク';

  @override
  String get profileFavoriteGenre => '好きなジャンル';

  @override
  String get editFavoriteTagTitle => 'お気に入りタグの選択';

  @override
  String get selectFavoriteTag => 'お気に入りタグを選択';

  @override
  String get favoriteTagPlaceholder => 'お気に入りのタグ';

  @override
  String get promoteDialogTitle => '✨プレミアム会員になろう✨';

  @override
  String get promoteDialogTrophyTitle => 'トロフィー機能';

  @override
  String get promoteDialogTrophyDesc => '特定の活動に応じてトロフィーを表示できるようになります。';

  @override
  String get promoteDialogTagTitle => 'カスタムタグ';

  @override
  String get promoteDialogTagDesc => 'お気に入りのフードに独自のタグを設定できます。';

  @override
  String get promoteDialogIconTitle => 'カスタムアイコン';

  @override
  String get promoteDialogIconDesc => 'プロフィールアイコンを自由な画像に設定できます!!';

  @override
  String get promoteDialogAdTitle => '広告フリー';

  @override
  String get promoteDialogAdDesc => 'すべての広告が表示されなくなります!!';

  @override
  String get promoteDialogButton => 'プレミアム会員になる';

  @override
  String get promoteDialogLater => '後で考える';

  @override
  String get paywallTitle => 'FoodGram プレミアム';

  @override
  String get paywallPremiumTitle => '✨ プレミアム特典 ✨';

  @override
  String get paywallTrophyTitle => 'トロフィー機能';

  @override
  String get paywallTrophyDesc => '活動に応じてトロフィーを表示';

  @override
  String get paywallTagTitle => 'カスタムタグ';

  @override
  String get paywallTagDesc => 'お気に入りフードに独自タグ';

  @override
  String get paywallIconTitle => 'カスタムアイコン';

  @override
  String get paywallIconDesc => 'プロフィールアイコンを自由に';

  @override
  String get paywallAdTitle => '広告フリー';

  @override
  String get paywallAdDesc => 'すべての広告を非表示';

  @override
  String get paywallComingSoon => 'Coming Soon...';

  @override
  String get paywallNewFeatures => 'プレミアム会員限定の新機能を\n随時リリース予定！';

  @override
  String get paywallSubscribeButton => 'プレミアム会員になる';

  @override
  String get paywallPrice => '月額  ￥ 300 / 月';

  @override
  String get paywallCancelNote => 'いつでも解約可能';

  @override
  String get paywallWelcomeTitle => 'Welcome to\nFoodGram Members!';

  @override
  String get appTitle => 'FoodGram';

  @override
  String get appSubtitle => '美味しい瞬間、シェアしよう';

  @override
  String get searchRestaurantTitle => 'レストランを探す';

  @override
  String get nearbyRestaurants => '📍近いレストラン';

  @override
  String get seeMore => 'もっとみる';

  @override
  String get selectCountryTag => '国カテゴリーの選択';

  @override
  String get selectFoodTag => '料理カテゴリーの選択';

  @override
  String get paywallSkip => 'スキップ';

  @override
  String get purchaseError => '購入処理中にエラーが発生しました';

  @override
  String get anonymousPost => '匿名で投稿';

  @override
  String get anonymousPostDescription => 'ユーザー名が非表示になります';

  @override
  String get anonymousShare => '匿名でシェア';

  @override
  String get anonymousUpdate => '匿名で更新';

  @override
  String get anonymousPoster => 'とある投稿者';

  @override
  String get anonymousUsername => 'foodgramer';
}
