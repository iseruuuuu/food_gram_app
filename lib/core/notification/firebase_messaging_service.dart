import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/post/repository/detail_post_repository.dart'
    as detail_repo;
import 'package:food_gram_app/router/router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'firebase_messaging_service.g.dart';

/// Firebase Messagingサービス
/// プッシュ通知のリクエストとトークン管理を担当
class FirebaseMessagingService {
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final Logger _logger = Logger();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String? _fcmToken;
  WidgetRef? _ref;

  /// FCMトークンを取得
  String? get fcmToken => _fcmToken;

  /// Refを設定（ナビゲーション用）
  void setRef(WidgetRef ref) {
    _ref = ref;
  }

  /// Firebase Messagingを初期化
  Future<void> initialize() async {
    try {
      // Android通知チャンネルを作成
      if (Platform.isAndroid) {
        await _createNotificationChannel();
      }

      // 通知権限をリクエスト
      await requestNotificationPermission();

      // FCMトークンを取得
      await getFCMToken();

      // トークン更新のリスナーを設定
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        _logger.i('FCMトークンが更新されました');
        // Supabaseにトークンを保存
        await _saveFCMTokenToSupabase(newToken);
      });

      // フォアグラウンドメッセージのハンドラーを設定
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // バックグラウンドメッセージがタップされたときのハンドラーを設定
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // アプリが終了状態から通知をタップして起動された場合の処理
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        // 少し待ってから処理（アプリが完全に起動してから）
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await _handleMessageOpenedApp(initialMessage);
      }

      _logger.i('Firebase Messagingが正常に初期化されました');
    } on Exception catch (e) {
      _logger.e('Firebase Messagingの初期化に失敗しました: $e');
    }
  }

  /// Android通知チャンネルを作成
  Future<void> _createNotificationChannel() async {
    try {
      const androidNotificationChannel = AndroidNotificationChannel(
        'food_gram_fcm_channel',
        'FoodGramプッシュ通知',
        description: 'FoodGramアプリのプッシュ通知',
        importance: Importance.max,
        enableLights: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidNotificationChannel);

      _logger.i('Firebase Messaging用のAndroid通知チャンネルを作成しました');
    } on Exception catch (e) {
      _logger.e('Android通知チャンネルの作成に失敗しました: $e');
    }
  }

  /// 通知権限をリクエスト
  Future<bool> requestNotificationPermission() async {
    try {
      if (Platform.isIOS) {
        // iOSの場合
        final settings = await _firebaseMessaging.requestPermission();

        final isAuthorized =
            settings.authorizationStatus == AuthorizationStatus.authorized ||
                settings.authorizationStatus == AuthorizationStatus.provisional;

        _logger.i(
          'iOS通知権限リクエスト結果: ${settings.authorizationStatus}, '
          '許可状態: $isAuthorized',
        );

        return isAuthorized;
      } else if (Platform.isAndroid) {
        // Android 13以降の場合、通知権限をリクエスト
        final androidPlugin = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin != null) {
          final result = await androidPlugin.requestNotificationsPermission();
          final hasPermission = await androidPlugin.areNotificationsEnabled();

          _logger.i(
            'Android通知権限リクエスト結果: $result, '
            '権限確認: $hasPermission',
          );

          return hasPermission ?? false;
        }

        // Android 12以前の場合は常にtrue
        return true;
      }

      return false;
    } on Exception catch (e) {
      _logger.e('通知権限のリクエストに失敗しました: $e');
      return false;
    }
  }

  /// 通知権限の状態を確認
  Future<bool> checkNotificationPermission() async {
    try {
      if (Platform.isIOS) {
        final settings = await _firebaseMessaging.getNotificationSettings();
        return settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
      } else if (Platform.isAndroid) {
        final androidPlugin = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final hasPermission =
            await androidPlugin?.areNotificationsEnabled() ?? false;
        return hasPermission;
      }
      return false;
    } on Exception catch (e) {
      _logger.e('通知権限の確認に失敗しました: $e');
      return false;
    }
  }

  /// FCMトークンを取得
  Future<String?> getFCMToken() async {
    try {
      // iOSの場合、APNsトークンの登録を確実にする
      if (Platform.isIOS) {
        // APNsトークンを取得（これによりFCMトークンも確実に取得できる）
        await _firebaseMessaging.requestPermission();

        // APNsトークンの登録を待つ
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }

      _fcmToken = await _firebaseMessaging.getToken();
      _logger.i('FCMトークンを取得しました');

      // Supabaseにトークンを保存
      if (_fcmToken != null) {
        await _saveFCMTokenToSupabase(_fcmToken!);
      } else {
        _logger.w('FCMトークンがnullです。APNsの設定を確認してください。');
      }

      return _fcmToken;
    } on Exception catch (e) {
      _logger.e('FCMトークンの取得に失敗しました: $e');
      return null;
    }
  }

  /// FCMトークンをSupabaseに保存 （Edge Function経由でサーバー側に登録）
  Future<void> _saveFCMTokenToSupabase(String token) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        _logger.w('ユーザーがログインしていないため、FCMトークンを保存できません');
        return;
      }
      _logger.i(
        'FCMトークンをSupabaseに保存します（Edge Function）: '
        'ユーザーID=${currentUser.id}',
      );
      final res = await supabase.functions.invoke(
        'fcm-token',
        body: {'action': 'register', 'fcm_token': token},
      );
      final data = res.data;
      if (data is Map<String, dynamic> && data['error'] != null) {
        _logger.e(
          'FCMトークン登録に失敗: ${data['error']}, '
          'details: ${data['details']}',
        );
        return;
      }
      _logger.i('FCMトークンをSupabaseに保存しました（Edge Function）');
    } on Exception catch (e) {
      _logger.e('FCMトークンのSupabase保存に失敗しました: $e');
      // エラーが発生してもアプリの動作は続行
    }
  }

  /// FCMトークンを削除（ログアウト時などに使用・Edge Function経由）
  Future<void> deleteFCMToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      if (currentUser != null) {
        final res = await supabase.functions.invoke(
          'fcm-token',
          body: {'action': 'delete'},
        );
        final data = res.data;
        if (data is Map<String, dynamic> && data['error'] != null) {
          _logger.e(
            'FCMトークン削除に失敗: ${data['error']}, details: ${data['details']}',
          );
        }
      }

      _logger.i('FCMトークンを削除しました');
    } on Exception catch (e) {
      _logger.e('FCMトークンの削除に失敗しました: $e');
    }
  }

  /// いいね通知を送信
  /// [postOwnerId] 投稿者のユーザーID
  /// [postId] 投稿ID
  /// [likerName] いいねをした人の名前
  Future<void> sendHeartNotification({
    required String postOwnerId,
    required int postId,
    required String likerName,
    required String likerUserId,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      final requestBody = {
        'type': 'heart',
        'postOwnerId': postOwnerId,
        'post_id': postId,
        'likerName': likerName,
        'likerUserId': likerUserId,
      };

      _logger.i(
        'いいね通知の送信を開始: '
        '投稿者ID=$postOwnerId, 投稿ID=$postId, いいねした人=$likerName, '
        'リクエストボディ=$requestBody',
      );

      // Supabase Functionsを呼び出して通知を送信
      final res = await supabase.functions.invoke(
        'FirebaseMessaging',
        body: requestBody,
      );

      _logger.i(
        'Supabase Functions呼び出し完了: '
        'ステータスコード=${res.status}, '
        'レスポンスデータ=${res.data}',
      );

      final data = res.data;

      // エラーレスポンスのチェック
      if (data is Map<String, dynamic>) {
        if (data.containsKey('error')) {
          final errorMessage = data['error'] as String? ?? 'Unknown error';
          final errorDetails = data['details'] as String?;
          final errorHint = data['hint'] as String?;
          final errorCode = data['code'] as String?;

          _logger.e(
            'いいね通知の送信に失敗しました: '
            'エラー=$errorMessage, '
            '詳細=$errorDetails, '
            'ヒント=$errorHint, '
            'コード=$errorCode, '
            'ステータスコード=${res.status}',
          );
        } else if (data.containsKey('success') || data.containsKey('message')) {
          _logger.i(
            'いいね通知の送信が成功しました: '
            'レスポンス=$data, '
            'ステータスコード=${res.status}',
          );
        } else {
          _logger.w(
            'いいね通知の送信レスポンスが不明な形式です: '
            'レスポンス=$data, '
            'ステータスコード=${res.status}',
          );
        }
      } else {
        _logger.i(
          'いいね通知の送信リクエストを送信しました: '
          '投稿者ID=$postOwnerId, 投稿ID=$postId, いいねした人=$likerName, '
          'レスポンス=$data, '
          'ステータスコード=${res.status}',
        );
      }
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'いいね通知の送信に失敗しました: $e',
        error: e,
        stackTrace: stackTrace,
      );
      // エラーが発生してもアプリの動作は続行
    }
  }

  /// フォアグラウンドメッセージを処理
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _logger.i('フォアグラウンドでメッセージを受信しました: ${message.messageId}');

    // メッセージタイプに応じて処理
    final messageType = message.data['type'] as String?;
    if (messageType == 'heart') {
      await _showHeartNotification(message);
    } else {
      // その他のメッセージは通常の通知として表示
      await _showLocalNotification(message);
    }
  }

  /// メッセージがタップされたときの処理
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    _logger.i('通知がタップされました: ${message.messageId}');

    final messageType = message.data['type'] as String?;
    if (messageType == 'heart') {
      // いいね通知がタップされた場合
      final postIdStr =
          (message.data['post_id'] ?? message.data['postId']) as String?;
      if (postIdStr == null) {
        _logger.w('投稿IDが取得できませんでした');
        return;
      }

      final postId = int.tryParse(postIdStr);
      if (postId == null) {
        _logger.w('投稿IDが無効です: $postIdStr');
        return;
      }

      _logger.i('いいね通知がタップされました。投稿ID: $postId');

      // 投稿詳細画面への遷移
      await _navigateToPostDetail(postId);
    } else {
      // その他の通知がタップされた場合
      final postIdStr =
          (message.data['post_id'] ?? message.data['postId']) as String?;
      if (postIdStr != null) {
        final postId = int.tryParse(postIdStr);
        if (postId != null) {
          await _navigateToPostDetail(postId);
        }
      }
    }
  }

  /// 投稿詳細画面に遷移
  Future<void> _navigateToPostDetail(int postId) async {
    if (_ref == null) {
      _logger.w('Refが設定されていないため、ナビゲーションできません');
      return;
    }

    try {
      // 投稿データを取得
      final repository =
          _ref!.read(detail_repo.detailPostRepositoryProvider.notifier);
      final postResult = await repository.getPost(postId);

      await postResult.when(
        success: (posts) async {
          // ユーザーデータを取得
          final userData = await repository.getUserData(posts.userId);
          final users = Users.fromJson(userData);
          final model = Model(users, posts);

          // GoRouterで遷移
          final router = _ref!.read(routerProvider);

          // 次のフレームでナビゲーションを実行（アプリが完全に起動してから）
          WidgetsBinding.instance.addPostFrameCallback((_) {
            router.pushNamed(
              RouterPath.timeLineDetail,
              extra: model,
            );
            _logger.i('投稿詳細画面に遷移しました: 投稿ID=$postId');
          });
        },
        failure: (error) {
          _logger.e('投稿データの取得に失敗しました: $error');
        },
      );
    } on Exception catch (e) {
      _logger.e('投稿詳細画面への遷移に失敗しました: $e');
    }
  }

  /// いいね通知を表示
  Future<void> _showHeartNotification(RemoteMessage message) async {
    try {
      // ユーザー名を取得（dataから取得、なければnotification.bodyから取得）
      final userName = message.data['userName'] as String? ??
          message.notification?.body?.split('さん')[0] ??
          '誰か';

      // タイトルとサブタイトルを設定
      const title = 'あなたの投稿に「いいね！」が届きました 🍰';
      final subtitle = '$userNameさんも、おいしそうって思ったみたい！';

      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'food_gram_fcm_channel',
        'FoodGramプッシュ通知',
        channelDescription: 'FoodGramアプリのプッシュ通知',
        importance: Importance.max,
        priority: Priority.high,
        enableLights: true,
        styleInformation: BigTextStyleInformation(subtitle),
      );

      final iOSPlatformChannelSpecifics = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: subtitle,
      );

      final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        title,
        subtitle,
        platformChannelSpecifics,
        payload: message.data.toString(),
      );

      _logger.i('いいね通知を表示しました: $title - $subtitle');
    } on Exception catch (e) {
      _logger.e('いいね通知の表示に失敗しました: $e');
    }
  }

  /// ローカル通知を表示
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      if (notification == null) {
        return;
      }

      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'food_gram_fcm_channel',
        'FoodGramプッシュ通知',
        channelDescription: 'FoodGramアプリのプッシュ通知',
        importance: Importance.max,
        priority: Priority.high,
        enableLights: true,
      );

      const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
    } on Exception catch (e) {
      _logger.e('ローカル通知の表示に失敗しました: $e');
    }
  }
}

@Riverpod(keepAlive: true)
FirebaseMessagingService firebaseMessagingService(Ref ref) {
  return FirebaseMessagingService();
}

@Riverpod(keepAlive: true)
Future<String?> fcmToken(Ref ref) async {
  final service = ref.read(firebaseMessagingServiceProvider);
  return service.getFCMToken();
}
