import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../gen/l10n/l10n.dart';
import '../../gen/l10n/l10n_de.dart';
import '../../gen/l10n/l10n_en.dart';
import '../../gen/l10n/l10n_es.dart';
import '../../gen/l10n/l10n_fr.dart';
import '../../gen/l10n/l10n_ja.dart';
import '../../gen/l10n/l10n_ko.dart';
import '../../gen/l10n/l10n_pt.dart';
import '../../gen/l10n/l10n_zh.dart';

part 'notification_service.g.dart';

/// ローカル通知サービス
class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  /// ロケールに基づいて適切なL10nインスタンスを取得
  L10n _getL10n() {
    final locale = Platform.localeName;
    final languageCode = locale.split('_')[0];

    switch (languageCode) {
      case 'ja':
        return L10nJa();
      case 'en':
        return L10nEn();
      case 'ko':
        return L10nKo();
      case 'zh':
        return L10nZh();
      case 'es':
        return L10nEs();
      case 'fr':
        return L10nFr();
      case 'de':
        return L10nDe();
      case 'pt':
        return L10nPt();
      default:
        return L10nJa(); // デフォルトは日本語
    }
  }

  /// 通知サービスを初期化
  Future<void> initialize() async {
    try {
      // 既存の通知をすべてキャンセル（重複を防ぐため）
      await _flutterLocalNotificationsPlugin.cancelAll();
      // Android設定
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      // iOS設定
      const initializationSettingsIOS = DarwinInitializationSettings();
      // 初期化設定
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      // 初期化
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      // Android 13以降の通知チャンネルを作成
      if (Platform.isAndroid) {
        await _createNotificationChannels();
      }
      _logger.i('通知サービスが正常に初期化されました');
    } on Exception catch (e) {
      _logger.e('通知サービスの初期化に失敗しました: $e');
    }
  }

  /// Android通知チャンネルを作成
  Future<void> _createNotificationChannels() async {
    try {
      const androidNotificationChannel = AndroidNotificationChannel(
        'food_gram_channel',
        'FoodGram通知',
        description: 'FoodGramアプリからの通知',
        importance: Importance.max,
        enableLights: true,
      );
      const androidScheduleChannel = AndroidNotificationChannel(
        'food_gram_schedule_channel',
        'FoodGramスケジュール通知',
        description: 'FoodGramアプリのスケジュール通知',
        importance: Importance.max,
        enableLights: true,
      );
      const androidPeriodicChannel = AndroidNotificationChannel(
        'food_gram_periodic_channel',
        'FoodGram定期通知',
        description: 'FoodGramアプリの定期通知',
        importance: Importance.max,
        enableLights: true,
      );
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidNotificationChannel);
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidScheduleChannel);
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidPeriodicChannel);

      _logger.i('Android通知チャンネルを作成しました');
    } on Exception catch (e) {
      _logger.e('Android通知チャンネルの作成に失敗しました: $e');
    }
  }

  /// 通知権限をリクエスト
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isIOS) {
        final result = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        return result ?? false;
      } else if (Platform.isAndroid) {
        // Android 13以降の通知権限をリクエスト
        final result = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        // 権限が付与されたかどうかを確認
        final hasPermission = await checkPermissions();
        _logger.i('Android通知権限リクエスト結果: $result, 権限確認: $hasPermission');
        return hasPermission;
      }
      return false;
    } on Exception catch (e) {
      _logger.e('通知権限のリクエストに失敗しました: $e');
      return false;
    }
  }

  /// 通知権限の状態を確認
  Future<bool> checkPermissions() async {
    try {
      if (Platform.isIOS) {
        final result = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.checkPermissions();
        return result?.isEnabled ?? false;
      } else if (Platform.isAndroid) {
        // Android 13以降の通知権限を確認
        final result = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled();
        _logger.i('Android通知権限確認結果: $result');
        return result ?? false;
      }
      return false;
    } on Exception catch (e) {
      _logger.e('通知権限の確認に失敗しました: $e');
      return false;
    }
  }

  /// スケジュール通知を設定
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    int id = 0,
  }) async {
    try {
      // 権限を確認
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        _logger.w('通知権限がありません。スケジュール通知を設定できません。');
        return;
      }
      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'food_gram_schedule_channel',
        'FoodGramスケジュール通知',
        channelDescription: 'FoodGramアプリのスケジュール通知',
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
      final scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);
      try {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTZDate,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
        );
      } on Exception catch (e) {
        if (e.toString().contains('exact_alarms_not_permitted')) {
          // Exact alarms権限がない場合は、通常のスケジュールモードを使用
          await _flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            title,
            body,
            scheduledTZDate,
            platformChannelSpecifics,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: payload,
          );
        } else {
          rethrow;
        }
      }
    } on Exception catch (e) {
      _logger.e('スケジュール通知の設定に失敗しました: $e');
    }
  }

  /// 通知がタップされたときの処理
  void _onNotificationTapped(NotificationResponse response) {
    try {
      // ペイロードがある場合は処理
      if (response.payload != null) {
        final dynamic decoded = json.decode(response.payload!);
        final payload = decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded as Map);
        _handleNotificationPayload(payload);
      }
    } on Exception catch (e) {
      _logger.e('通知タップの処理に失敗しました: $e');
    }
  }

  /// 食事リマインダーを設定（昼12時）
  Future<void> scheduleLunchReminder() async {
    final l10n = _getL10n();
    final title = l10n.notificationLunchTitle;
    final body = l10n.notificationLunchBody;
    final payload = json.encode({
      'type': 'meal_reminder',
      'mealType': 'lunch',
    });

    final now = DateTime.now();
    final lunchTime = DateTime(now.year, now.month, now.day, 12);

    /// 今日の12時が過ぎている場合は明日の12時に設定
    final scheduledTime = lunchTime.isBefore(now)
        ? lunchTime.add(const Duration(days: 1))
        : lunchTime;

    await scheduleNotification(
      title: title,
      body: body,
      scheduledDate: scheduledTime,
      payload: payload,
      id: 1,
    );
  }

  /// 食事リマインダーを設定（夜7時）
  Future<void> scheduleDinnerReminder() async {
    final l10n = _getL10n();
    final title = l10n.notificationDinnerTitle;
    final body = l10n.notificationDinnerBody;
    final payload = json.encode({
      'type': 'meal_reminder',
      'mealType': 'dinner',
    });

    final now = DateTime.now();
    final dinnerTime = DateTime(now.year, now.month, now.day, 19);

    /// 今日の19時が過ぎている場合は明日の19時に設定
    final scheduledTime = dinnerTime.isBefore(now)
        ? dinnerTime.add(const Duration(days: 1))
        : dinnerTime;

    await scheduleNotification(
      title: title,
      body: body,
      scheduledDate: scheduledTime,
      payload: payload,
      id: 2,
    );
  }

  /// 通知ペイロードの処理
  void _handleNotificationPayload(Map<String, dynamic> payload) {
    try {
      final type = payload['type']?.toString() ?? '';

      switch (type) {
        case 'meal_reminder':
          // 食事リマインダーの通知
          _handleMealReminderNotification(payload);
        default:
          _logger.w('未知の通知タイプ: $type');
      }
    } on Exception catch (e) {
      _logger.e('通知ペイロードの処理に失敗しました: $e');
    }
  }

  /// 食事リマインダーの通知処理
  void _handleMealReminderNotification(Map<String, dynamic> payload) {
    _logger.i('食事リマインダーの通知を処理: $payload');

    // 次の日の通知を再設定
    _scheduleNextDayReminder(payload['mealType'] as String);
  }

  /// 次の日の食事リマインダーを設定
  Future<void> _scheduleNextDayReminder(String mealType) async {
    try {
      if (mealType == 'lunch') {
        await scheduleLunchReminder();
      } else if (mealType == 'dinner') {
        await scheduleDinnerReminder();
      }
      _logger.i('次の日の$mealTypeリマインダーを設定しました');
    } on Exception catch (e) {
      _logger.e('次の日のリマインダー設定に失敗しました: $e');
    }
  }
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return NotificationService();
}

@Riverpod(keepAlive: true)
class NotificationPermission extends _$NotificationPermission {
  @override
  bool build() => false;

  Future<void> request() async {
    final service = ref.read(notificationServiceProvider);
    final hasPermission = await service.requestPermissions();
    state = hasPermission;
  }
}

@Riverpod(keepAlive: true)
Future<void> setupMealReminders(Ref ref) async {
  final service = ref.read(notificationServiceProvider);
  await service.scheduleLunchReminder();
  await service.scheduleDinnerReminder();
}
