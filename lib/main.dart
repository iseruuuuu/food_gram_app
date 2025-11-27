import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/app.dart';
import 'package:food_gram_app/core/notification/firebase_messaging_service.dart';
import 'package:food_gram_app/core/notification/notification_service.dart';
import 'package:food_gram_app/env.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSystemSettings();
  await initializeThirdPartyServices();
  await initializeNotifications();
  await MobileAds.instance.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> initializeSystemSettings() async {
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

Future<void> initializeThirdPartyServices() async {
  // Firebaseが既に初期化されているかチェック
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  // バックグラウンドメッセージハンドラーを設定
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  /// Supabaseの初期化
  await Supabase.initialize(
    anonKey: kReleaseMode ? Prod.supabaseAnonKey : Dev.supabaseAnonKey,
    url: kReleaseMode ? Prod.supabaseUrl : Dev.supabaseUrl,
    debug: kDebugMode,
  );
}

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
  } on Exception catch (e) {
    logger.e('通知の初期化に失敗しました: $e');
  }
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
