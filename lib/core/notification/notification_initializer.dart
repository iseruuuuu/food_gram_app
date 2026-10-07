import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:food_gram_app/core/notification/firebase_messaging_service.dart';
import 'package:food_gram_app/core/notification/heart_push_localization.dart';
import 'package:food_gram_app/core/notification/notification_service.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:logger/logger.dart';
import 'package:timezone/data/latest.dart' as tz;

/// 通知の初期化処理。
///
/// 権限ダイアログは出さない。許可済みのときだけリマインダーとトークンを整える。
/// 未許可のリクエストは初回投稿後の [requestUserNotificationPermission] で行う。
///
/// プラットフォーム／プラグイン初期化の失敗は呼び出し元へ伝播する。
/// リマインダー設定の失敗は非致命として握りつぶす。
Future<void> initializeNotifications() async {
  final logger = Logger();
  tz.initializeTimeZones();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final firebaseMessagingService = FirebaseMessagingService();
  await firebaseMessagingService.initialize();

  try {
    final hasPermission = await notificationService.checkPermissions();
    if (hasPermission) {
      await firebaseMessagingService.getFCMToken();
      await notificationService.scheduleLunchReminder();
      await notificationService.scheduleDinnerReminder();
    }
  } on Exception catch (e, stackTrace) {
    logger.w(
      '通知リマインダー設定をスキップしました: $e',
      stackTrace: stackTrace,
    );
  }
}

/// 初投稿の直後に、OSの通知許可ダイアログを出す。
Future<bool> requestUserNotificationPermission() async {
  final logger = Logger();
  try {
    final notificationService = NotificationService();
    final firebaseMessagingService = FirebaseMessagingService();
    final localGranted = await notificationService.requestPermissions();
    // Android は同じ権限を二度要求しない。最初の結果をそのまま使う。
    final pushGranted = Platform.isAndroid
        ? localGranted
        : await firebaseMessagingService.requestNotificationPermission();
    final granted = localGranted || pushGranted;
    if (!granted) {
      return false;
    }
    await notificationService.scheduleLunchReminder();
    await notificationService.scheduleDinnerReminder();
    await firebaseMessagingService.getFCMToken();
    return true;
  } on Exception catch (e, stackTrace) {
    logger.w(
      '通知権限のリクエストをスキップしました: $e',
      stackTrace: stackTrace,
    );
    return false;
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
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  // 初期化設定
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  if (messageType == 'heart') {
    final userName = message.data['userName'] as String? ??
        message.data['likerName'] as String? ??
        '';
    logger.i(
      'バックグラウンドでいいね通知を受信しました: ${message.messageId}, '
      'ユーザー: $userName',
    );

    // notification / loc-key 付きの場合は OS が端末言語で表示する。
    // ここでローカル通知を出すと日本語固定の二重表示になる。
    if (message.notification != null) {
      return;
    }

    LocaleSettings.useDeviceLocale();
    final copy = heartPushCopy(
      translations: devicePushTranslations(),
      variant: parseHeartPushVariant(message.data['messageVariant']),
      userName: userName,
    );
    final title = copy.title;
    final subtitle = copy.body;

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
