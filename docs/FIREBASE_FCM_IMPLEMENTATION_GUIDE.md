# Firebase Cloud Messaging (FCM) 完全実装ガイド

## 概要

このガイドでは、FlutterアプリでFirebase Cloud Messaging (FCM)を使用して、iOS/Android両対応のプッシュ通知を実装する方法を説明します。

## 目次

1. [前提条件](#前提条件)
2. [Firebase Consoleの設定](#firebase-consoleの設定)
3. [Apple Developer PortalでのAPNS認証キー取得](#apple-developer-portalでのapns認証キー取得)
4. [Supabase Functionsの実装](#supabase-functionsの実装)
5. [Flutterアプリ側の実装](#flutterアプリ側の実装)
6. [テスト方法](#テスト方法)
7. [トラブルシューティング](#トラブルシューティング)

---

## 前提条件

- Flutterプロジェクトが作成されている
- Firebaseプロジェクトが作成されている
- Supabaseプロジェクトが作成されている
- Apple Developer Programに加入している（iOS通知の場合）

---

## Firebase Consoleの設定

### ステップ1: Firebaseプロジェクトの準備

1. **Firebase Consoleにアクセス**
   - https://console.firebase.google.com/
   - プロジェクトを選択

2. **iOSアプリを登録**
   - プロジェクト設定 → 全般タブ
   - 「マイアプリ」セクションで「iOSアプリを追加」をクリック
   - Bundle IDを入力（例: `com.example.app`）
   - `GoogleService-Info.plist` をダウンロード
   - `ios/Runner/GoogleService-Info.plist` に配置

3. **Androidアプリを登録**
   - 「Androidアプリを追加」をクリック
   - パッケージ名を入力
   - `google-services.json` をダウンロード
   - `android/app/google-services.json` に配置

### ステップ2: Cloud Messaging APIを有効化

1. **Google Cloud Consoleにアクセス**
   - https://console.cloud.google.com/
   - Firebaseプロジェクトを選択

2. **Cloud Messaging APIを有効化**
   - APIとサービス → ライブラリ
   - 「Cloud Messaging API」を検索
   - 「有効にする」をクリック

---

## Apple Developer PortalでのAPNS認証キー取得

### ステップ1: APNS認証キーを作成

1. **Apple Developer Portalにアクセス**
   - https://developer.apple.com/account/
   - Apple Developerアカウントでログイン

2. **Keysページを開く**
   - 直接リンク: https://developer.apple.com/account/resources/authkeys/list
   - または、左側メニュー → 「Certificates, Identifiers & Profiles」 → 「Keys」

3. **新しいキーを作成**
   - 右上の「+」ボタン（または「Create a key」）をクリック
   - **Key Name**: `Firebase Cloud Messaging` など適切な名前を入力
   - **Enable the following services**: 
     - 「Apple Push Notifications service (APNs)」にチェックを入れる
   - 「Continue」ボタンをクリック
   - 内容を確認して「Register」ボタンをクリック

4. **キーをダウンロード**
   - 作成されたキーの詳細ページが表示されます
   - 「Download」ボタンをクリック
   - `.p8`ファイルがダウンロードされます
   - **⚠️ 重要**: このファイルは一度しかダウンロードできません。安全な場所に保存してください

5. **Key IDとTeam IDをメモ**
   - キーの詳細ページに表示されている情報をメモ：
     - **Key ID**: `ABC123XYZ` のような形式
     - **Team ID**: `ABCD1234` のような形式（ページ上部に表示されている場合もあります）

### ステップ2: Firebase ConsoleでAPNS認証キーを設定

1. **Firebase Consoleにアクセス**
   - https://console.firebase.google.com/
   - プロジェクトを選択
   - プロジェクト設定 → Cloud Messagingタブ

2. **「Apple アプリの構成」セクションを開く**
   - ページを下にスクロール
   - 「Apple app configuration」セクションを展開

3. **正しいiOSアプリを選択**
   - 「Apple アプリ」セクションで、正しいBundle IDのアプリが選択されているか確認
   - 複数のiOSアプリがある場合、正しいアプリを選択

4. **APNs認証キーをアップロード**
   - **本番環境用の認証キーをアップロード：**
     - 「本番環境用 APNs 認証キー」の「アップロード」ボタンをクリック
     - 以下の情報を入力：
       - **Key ID**: ステップ1でメモしたKey IDを入力
       - **Team ID**: ステップ1でメモしたTeam IDを入力
       - **.p8 file**: ダウンロードした`.p8`ファイルを選択
     - 「アップロード」ボタンをクリック
   
   - **開発用の認証キーをアップロード：**
     - 「開発用 APNs 認証キー」の「アップロード」ボタンをクリック
     - 同じ情報を入力してアップロード

5. **設定を確認**
   - ページを再読み込み
   - 開発用と本番環境用の両方の認証キーがテーブルに表示されているか確認
   - キーIDが両方に表示されているか確認

6. **設定の反映を待つ**
   - Firebase Consoleで設定を変更した場合、反映に**最大1時間**かかることがあります
   - 1時間待ってからテストを実行してください

---

## Supabase Functionsの実装

### ステップ1: Firebaseサービスアカウントキーを取得

1. **Google Cloud Consoleにアクセス**
   - https://console.cloud.google.com/
   - Firebaseプロジェクトを選択

2. **サービスアカウントを作成**
   - IAMと管理 → サービスアカウント
   - 「サービスアカウントを作成」をクリック
   - 適切な名前を入力して作成

3. **サービスアカウントキーをダウンロード**
   - 作成したサービスアカウントを選択
   - 「キー」タブを開く
   - 「キーを追加」→「新しいキーを作成」を選択
   - JSON形式でダウンロード

### ステップ2: Supabase Secretsに設定

1. **Supabaseダッシュボードにアクセス**
   - https://supabase.com/dashboard
   - プロジェクトを選択

2. **Secretsを設定**
   - プロジェクト設定 → Edge Functions → Secrets
   - 以下のSecretsを追加：
     - `FIREBASE_SERVICE_ACCOUNT`: ダウンロードしたJSONファイルの内容をそのまま貼り付け
     - `SUPABASE_URL`: SupabaseプロジェクトのURL（既に設定されている場合もあります）
     - `SUPABASE_SERVICE_ROLE_KEY`: Supabaseのサービスロールキー（既に設定されている場合もあります）

### ステップ3: user_fcm_tokensテーブルを作成

1. **Supabaseダッシュボード → SQL Editor**
2. **テーブルを作成**
   - `user_fcm_tokens`テーブルを作成
   - カラム: `id` (UUID), `user_id` (TEXT), `fcm_token` (TEXT), `created_at`, `updated_at`
   - `fcm_token`にUNIQUE制約を設定
   - `user_id`と`fcm_token`にインデックスを作成
   - Row Level Security (RLS) を有効化
   - ユーザーが自分のFCMトークンのみ管理できるポリシーを作成
   - 実装の詳細はプロジェクトのSQLファイルを参照してください

### ステップ4: FirebaseMessaging Edge Functionを作成

1. **Supabaseダッシュボード → Edge Functions**
2. **新しい関数を作成**
   - 「Create a new function」をクリック
   - 関数名: `FirebaseMessaging`

3. **コードを実装**
   - Supabase FunctionsのCodeタブにコードを実装
   - **主な機能**:
     - Firebase Admin SDKの初期化（サービスアカウントキーまたはApplication Default Credentialsを使用）
     - リクエストボディから通知タイプ、投稿者ID、投稿ID、いいねした人の名前を取得
     - Supabaseから投稿者のFCMトークンを取得
     - iOS/Android両対応の通知メッセージを作成
     - Firebase Cloud Messaging APIを使用して通知を送信
     - APNS認証エラーなどのエラーハンドリング
   - 実装の詳細はプロジェクトのSupabase Functionsコードを参照してください

4. **関数をデプロイ**
   - 「Deploy」ボタンをクリック

---

## Flutterアプリ側の実装

### ステップ1: 依存関係を追加

`pubspec.yaml` に以下を追加：

```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_messaging: ^15.1.3
  flutter_local_notifications: ^17.0.0
```

### ステップ2: Firebase Messaging Serviceを作成

`lib/core/notification/firebase_messaging_service.dart` を作成：

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirebaseMessagingService {
  final _logger = Logger();
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  /// Firebase Messagingを初期化
  Future<void> initialize() async {
    try {
      // Android通知チャネルの作成
      await _createNotificationChannel();

      // 通知権限のリクエスト
      await requestNotificationPermission();

      // FCMトークンの取得と保存
      final token = await getFCMToken();
      if (token != null) {
        await _saveFCMTokenToSupabase(token);
      }

      // トークンリフレッシュのリスナー
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _saveFCMTokenToSupabase(newToken);
      });

      // フォアグラウンドメッセージのハンドラー
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // アプリが開かれたときのメッセージハンドラー
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      _logger.i('Firebase Messagingの初期化が完了しました');
    } on Exception catch (e) {
      _logger.e('Firebase Messagingの初期化に失敗しました: $e');
    }
  }

  /// Android通知チャネルを作成
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// 通知権限をリクエスト
  Future<bool> requestNotificationPermission() async {
    try {
      // iOS
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.i('通知権限が許可されました');
        return true;
      } else {
        _logger.w('通知権限が拒否されました');
        return false;
      }
    } on Exception catch (e) {
      _logger.e('通知権限のリクエストに失敗しました: $e');
      return false;
    }
  }

  /// FCMトークンを取得
  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      _logger.i('FCMトークンを取得しました: ${token?.substring(0, 20)}...');
      return token;
    } on Exception catch (e) {
      _logger.e('FCMトークンの取得に失敗しました: $e');
      return null;
    }
  }

  /// FCMトークンをSupabaseに保存
  Future<void> _saveFCMTokenToSupabase(String token) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        _logger.w('ユーザーがログインしていないため、FCMトークンを保存できません');
        return;
      }

      await supabase.from('user_fcm_tokens').upsert({
        'user_id': currentUser.id,
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'fcm_token');

      _logger.i('FCMトークンをSupabaseに保存しました');
    } on Exception catch (e) {
      _logger.e('FCMトークンのSupabase保存に失敗しました: $e');
    }
  }

  /// フォアグラウンドメッセージを処理
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _logger.i('フォアグラウンドでメッセージを受信しました: ${message.messageId}');

    final messageType = message.data['type'] as String?;
    if (messageType == 'heart') {
      await _showHeartNotification(message);
    } else {
      await _showLocalNotification(message);
    }
  }

  /// いいね通知を表示
  Future<void> _showHeartNotification(RemoteMessage message) async {
    final userName = message.data['userName'] as String? ?? '誰か';

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      'あなたの投稿に「いいね！」が届きました 🍰',
      '$userNameさんも、おいしそうって思ったみたい！',
      notificationDetails,
    );
  }

  /// ローカル通知を表示
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? '通知',
      message.notification?.body ?? '',
      notificationDetails,
    );
  }

  /// アプリが開かれたときのメッセージを処理
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    _logger.i('アプリが開かれたときのメッセージを受信しました: ${message.messageId}');

    final messageType = message.data['type'] as String?;
    if (messageType == 'heart') {
      final postId = message.data['postId'] as String?;
      _logger.i('いいね通知がタップされました: 投稿ID=$postId');
      // ここで投稿詳細画面に遷移するなどの処理を実装
    }
  }

  /// いいね通知を送信
  Future<void> sendHeartNotification({
    required String postOwnerId,
    required int postId,
    required String likerName,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final res = await supabase.functions.invoke(
        'FirebaseMessaging',
        body: {
          'type': 'heart',
          'postOwnerId': postOwnerId,
          'postId': postId,
          'likerName': likerName,
        },
      );

      final data = res.data;
      _logger.i(
        'いいね通知の送信リクエストを送信しました: '
        '投稿者ID=$postOwnerId, 投稿ID=$postId, いいねした人=$likerName, '
        'レスポンス=$data',
      );
    } on Exception catch (e) {
      _logger.e('いいね通知の送信に失敗しました: $e');
    }
  }

  /// FCMトークンを削除（ログアウト時などに使用）
  Future<void> deleteFCMToken() async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        return;
      }

      await supabase
          .from('user_fcm_tokens')
          .delete()
          .eq('user_id', currentUser.id);

      await _firebaseMessaging.deleteToken();
      _logger.i('FCMトークンを削除しました');
    } on Exception catch (e) {
      _logger.e('FCMトークンの削除に失敗しました: $e');
    }
  }
}
```

### ステップ3: main.dartで初期化

`lib/main.dart` に以下を追加：

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:food_gram_app/core/notification/firebase_messaging_service.dart';

// バックグラウンドメッセージハンドラー
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final logger = Logger();
  final messageType = message.data['type'] as String?;
  if (messageType == 'heart') {
    final userName = message.data['userName'] as String? ?? '誰か';
    logger.i(
      'バックグラウンドでいいね通知を受信しました: ${message.messageId}, '
      'ユーザー: $userName',
    );
  } else {
    logger.i('バックグラウンドでメッセージを受信しました: ${message.messageId}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebaseの初期化
  await Firebase.initializeApp();
  
  // バックグラウンドメッセージハンドラーを設定
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Firebase Messaging Serviceの初期化
  final firebaseMessagingService = FirebaseMessagingService();
  await firebaseMessagingService.initialize();
  
  runApp(MyApp());
}
```

### ステップ4: いいね機能で通知を送信

投稿詳細画面などで、いいねボタンをタップしたときに通知を送信：

```dart
final firebaseMessagingService = FirebaseMessagingService();
await firebaseMessagingService.sendHeartNotification(
  postOwnerId: post.userId,
  postId: post.id,
  likerName: currentUser.name,
);
```

---

## テスト方法

### iOS → Androidのテスト

1. **iOSデバイスでアプリを起動**
   - ログインして通知権限を許可
   - 投稿を作成

2. **Androidデバイスでアプリを起動**
   - ログインして通知権限を許可
   - アプリをバックグラウンドに移動

3. **iOSデバイスからいいねを送信**
   - Androidデバイスの投稿を開く
   - いいねボタンをタップ

4. **Androidデバイスで通知を確認**
   - 通知が届くか確認

### Android → iOSのテスト

1. **iOSデバイスでアプリを起動**
   - ログインして通知権限を許可
   - 投稿を作成
   - アプリをバックグラウンドに移動

2. **Androidデバイスでアプリを起動**
   - ログインして通知権限を許可

3. **Androidデバイスからいいねを送信**
   - iOSデバイスの投稿を開く
   - いいねボタンをタップ

4. **iOSデバイスで通知を確認**
   - 通知が届くか確認

---

## トラブルシューティング

### 問題1: APNS認証エラーが発生する

**エラーメッセージ：**
```
Auth error from APNS or Web Push Service
```

**解決方法：**
1. Firebase Consoleで正しいiOSアプリが選択されているか確認
2. APNS認証キーが正しくアップロードされているか確認
3. Key IDとTeam IDが正しいか確認
4. 設定の反映を1時間待つ

### 問題2: FCMトークンが取得できない

**解決方法：**
1. iOSアプリで通知権限が許可されているか確認
2. `GoogleService-Info.plist` が正しく配置されているか確認
3. アプリを再起動してFCMトークンを再取得

### 問題3: 通知が届かない

**解決方法：**
1. 通知権限が許可されているか確認
2. アプリがバックグラウンドにあるか確認
3. FCMトークンがSupabaseに保存されているか確認
4. Supabase FunctionsのLogsでエラーを確認

### 問題4: Bundle IDが一致しない

**解決方法：**
1. XcodeでBundle IDを確認
2. Firebase Consoleで登録されているBundle IDと一致しているか確認
3. 正しいBundle IDのアプリに対してAPNS認証キーを設定

---

## まとめ

このガイドに従って実装すれば、iOS/Android両対応のプッシュ通知が動作するはずです。

重要なポイント：
- ✅ Firebase ConsoleでAPNS認証キーを正しく設定
- ✅ 正しいBundle IDのアプリを選択
- ✅ Supabase Functionsで正しいコードを実装
- ✅ FlutterアプリでFCMトークンを正しく保存
- ✅ 設定の反映を1時間待つ

問題が発生した場合は、トラブルシューティングセクションを参照してください。

