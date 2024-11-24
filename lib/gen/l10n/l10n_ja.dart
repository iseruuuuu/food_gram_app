// ignore_for_file: type=lint

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
  String get emailInputField => 'メールアドレスを入力してください';

  @override
  String get settingsIcon => 'アイコンの設定';

  @override
  String get userName => 'ユーザー名';

  @override
  String get userNameInputField => 'ユーザー名を入力してください';

  @override
  String get userId => 'ユーザーID';

  @override
  String get userIdInputField => 'ユーザーIDを入力してください';

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
  String get settingsDeveloper => '開発者';

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
  String get postShareButton => 'シェア';

  @override
  String get postFoodName => '食べたもの';

  @override
  String get postFoodNameInputField => '食べたものを入力';

  @override
  String get postRestaurantNameInputField => 'レストラン名を追加';

  @override
  String get postComment => 'コメントを入力';

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
}
