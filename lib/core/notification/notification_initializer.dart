import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:food_gram_app/core/notification/firebase_messaging_service.dart';
import 'package:food_gram_app/core/notification/notification_service.dart';
import 'package:logger/logger.dart';
import 'package:timezone/data/latest.dart' as tz;

/// 通知の初期化処理
Future<void> initializeNotifications() async {
  final logger = Logger();
  try {
    tz.initializeTimeZones();

    // ローカル通知サービスを初期化
    final notificationService = NotificationService();
    await notificationService.initialize();

    // Firebase Messagingサービスを初期化
    final firebaseMessagingService = FirebaseMessagingService();
    await firebaseMessagingService.initialize();

    // ローカル通知の権限をリクエスト
    final hasPermission = await notificationService.requestPermissions();
    if (hasPermission) {
      await notificationService.scheduleLunchReminder();
      await notificationService.scheduleDinnerReminder();
    }
  } catch (e, stackTrace) {
    logger.e('通知の初期化に失敗しました: $e', stackTrace: stackTrace);
  }
}

/// チュートリアル用: 権限ダイアログのみ表示（FCMトークン取得はしない）
Future<void> requestTutorialNotificationPermission() async {
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();
  await FirebaseMessagingService().requestNotificationPermission();
}

/// バックグラウンドメッセージハンドラー
/// トップレベル関数として定義する必要があります
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebaseを初期化（バックグラウンドでは明示的に初期化が必要）
  await Firebase.initializeApp();
  final logger = Logger();

  logger.i(
    'バックグラウンドでメッセージを受信しました: '
    'messageId=${message.messageId}, '
    'data=${message.data}, '
    'notification=${message.notification?.title}',
  );

  final messageType = message.data['type'] as String?;

  // ローカル通知プラグインを初期化
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Android設定
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  // iOS設定
  const iosSettings = DarwinInitializationSettings();
  // 初期化設定
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  if (messageType == 'heart') {
    final userName = message.data['userName'] as String? ?? '誰か';
    logger.i(
      'バックグラウンドでいいね通知を受信しました: ${message.messageId}, '
      'ユーザー: $userName',
    );

    // いいね通知を表示
    const title = 'あなたの投稿に「いいね！」が届きました 🍰';
    final subtitle = '$userNameさんも、おいしそうって思ったみたい！';

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'food_gram_fcm_channel',
      'FoodGramプッシュ通知',
      channelDescription: 'FoodGramアプリのプッシュ通知',
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
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

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      title,
      subtitle,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );

    logger.i('バックグラウンドでいいね通知を表示しました');
  } else {
    // その他の通知
    final notification = message.notification;
    if (notification != null) {
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

      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        notification.title ?? '通知',
        notification.body ?? '',
        platformChannelSpecifics,
        payload: message.data.toString(),
      );

      logger.i('バックグラウンドで通知を表示しました');
    }
  }
}
