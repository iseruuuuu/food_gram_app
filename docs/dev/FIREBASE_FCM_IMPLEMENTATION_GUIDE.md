# Firebase Cloud Messaging (FCM) Complete Implementation Guide

## Overview

This guide explains how to implement push notifications for both iOS and Android in a Flutter app using Firebase Cloud Messaging (FCM).

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Firebase Console Configuration](#firebase-console-configuration)
3. [APNS Authentication Key from Apple Developer Portal](#apns-authentication-key-from-apple-developer-portal)
4. [Supabase Functions Implementation](#supabase-functions-implementation)
5. [Flutter App Implementation](#flutter-app-implementation)
6. [Testing Methods](#testing-methods)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Flutter project is created
- Firebase project is created
- Supabase project is created
- Apple Developer Program membership (for iOS notifications)

---

## Firebase Console Configuration

### Step 1: Firebase Project Setup

1. **Access Firebase Console**
   - https://console.firebase.google.com/
   - Select your project

2. **Register iOS App**
   - Project Settings → General tab
   - Click "Add iOS app" in the "Your apps" section
   - Enter Bundle ID (e.g., `com.example.app`)
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/GoogleService-Info.plist`

3. **Register Android App**
   - Click "Add Android app"
   - Enter package name
   - Download `google-services.json`
   - Place it in `android/app/google-services.json`

### Step 2: Enable Cloud Messaging API

1. **Access Google Cloud Console**
   - https://console.cloud.google.com/
   - Select Firebase project

2. **Enable Cloud Messaging API**
   - APIs & Services → Library
   - Search for "Cloud Messaging API"
   - Click "Enable"

---

## APNS Authentication Key from Apple Developer Portal

### Step 1: Create APNS Authentication Key

1. **Access Apple Developer Portal**
   - https://developer.apple.com/account/
   - Log in with Apple Developer account

2. **Open Keys Page**
   - Direct link: https://developer.apple.com/account/resources/authkeys/list
   - Or, left menu → "Certificates, Identifiers & Profiles" → "Keys"

3. **Create New Key**
   - Click the "+" button (or "Create a key") in the top right
   - **Key Name**: Enter an appropriate name like `Firebase Cloud Messaging`
   - **Enable the following services**: 
     - Check "Apple Push Notifications service (APNs)"
   - Click "Continue" button
   - Review and click "Register" button

4. **Download Key**
   - The key detail page will be displayed
   - Click "Download" button
   - A `.p8` file will be downloaded
   - **⚠️ Important**: This file can only be downloaded once. Save it in a secure location

5. **Note Key ID and Team ID**
   - Note the information displayed on the key detail page:
     - **Key ID**: Format like `ABC123XYZ`
     - **Team ID**: Format like `ABCD1234` (may also be displayed at the top of the page)

### Step 2: Configure APNS Authentication Key in Firebase Console

1. **Access Firebase Console**
   - https://console.firebase.google.com/
   - Select your project
   - Project Settings → Cloud Messaging tab

2. **Open "Apple app configuration" Section**
   - Scroll down the page
   - Expand "Apple app configuration" section

3. **Select Correct iOS App**
   - In the "Apple app" section, verify the app with the correct Bundle ID is selected
   - If there are multiple iOS apps, select the correct one

4. **Upload APNs Authentication Key**
   - **Upload Production Authentication Key:**
     - Click "Upload" button for "Production APNs authentication key"
     - Enter the following information:
       - **Key ID**: Enter the Key ID noted in Step 1
       - **Team ID**: Enter the Team ID noted in Step 1
       - **.p8 file**: Select the downloaded `.p8` file
     - Click "Upload" button
   
   - **Upload Development Authentication Key:**
     - Click "Upload" button for "Development APNs authentication key"
     - Enter the same information and upload

5. **Verify Configuration**
   - Reload the page
   - Verify both development and production authentication keys are displayed in the table
   - Verify Key IDs are displayed for both

6. **Wait for Configuration to Take Effect**
   - When you change settings in Firebase Console, it may take **up to 1 hour** to take effect
   - Wait 1 hour before running tests

---

## Supabase Functions Implementation

### Step 1: Get Firebase Service Account Key

1. **Access Google Cloud Console**
   - https://console.cloud.google.com/
   - Select Firebase project

2. **Create Service Account**
   - IAM & Admin → Service Accounts
   - Click "Create Service Account"
   - Enter an appropriate name and create

3. **Download Service Account Key**
   - Select the created service account
   - Open "Keys" tab
   - Select "Add Key" → "Create new key"
   - Download in JSON format

### Step 2: Configure Supabase Secrets

1. **Access Supabase Dashboard**
   - https://supabase.com/dashboard
   - Select your project

2. **Set Secrets**
   - Project Settings → Edge Functions → Secrets
   - Add the following Secrets:
     - `FIREBASE_SERVICE_ACCOUNT`: Paste the content of the downloaded JSON file as-is
     - `SUPABASE_URL`: Supabase project URL (may already be set)
     - `SUPABASE_SERVICE_ROLE_KEY`: Supabase service role key (may already be set)

### Step 3: Create user_fcm_tokens Table

1. **Supabase Dashboard → SQL Editor**
2. **Create Table**
   - Create `user_fcm_tokens` table
   - Columns: `id` (UUID), `user_id` (TEXT), `fcm_token` (TEXT), `created_at`, `updated_at`
   - Set UNIQUE constraint on `fcm_token`
   - Create indexes on `user_id` and `fcm_token`
   - Enable Row Level Security (RLS)
   - Create policy so users can only manage their own FCM tokens
   - See project SQL files for implementation details

### Step 4: Create FirebaseMessaging Edge Function

1. **Supabase Dashboard → Edge Functions**
2. **Create New Function**
   - Click "Create a new function"
   - Function name: `FirebaseMessaging`

3. **Implement Code**
   - Implement code in Supabase Functions Code tab
   - **Main Features**:
     - Initialize Firebase Admin SDK (using service account key or Application Default Credentials)
     - Get notification type, post owner ID, post ID, and liker name from request body
     - Get post owner's FCM token from Supabase
     - Create notification messages for both iOS/Android
     - Send notifications using Firebase Cloud Messaging API
     - Error handling for APNS authentication errors, etc.
   - See project Supabase Functions code for implementation details

4. **Deploy Function**
   - Click "Deploy" button

---

## Flutter App Implementation

### Step 1: Add Dependencies

Add the following to `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_messaging: ^15.1.3
  flutter_local_notifications: ^17.0.0
```

### Step 2: Create Firebase Messaging Service

Create `lib/core/notification/firebase_messaging_service.dart`:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirebaseMessagingService {
  final _logger = Logger();
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    try {
      // Create Android notification channel
      await _createNotificationChannel();

      // Request notification permission
      await requestNotificationPermission();

      // Get and save FCM token
      final token = await getFCMToken();
      if (token != null) {
        await _saveFCMTokenToSupabase(token);
      }

      // Token refresh listener
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _saveFCMTokenToSupabase(newToken);
      });

      // Foreground message handler
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Message handler when app is opened
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      _logger.i('Firebase Messaging initialization completed');
    } on Exception catch (e) {
      _logger.e('Firebase Messaging initialization failed: $e');
    }
  }

  /// Create Android notification channel
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

  /// Request notification permission
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
        _logger.i('Notification permission granted');
        return true;
      } else {
        _logger.w('Notification permission denied');
        return false;
      }
    } on Exception catch (e) {
      _logger.e('Notification permission request failed: $e');
      return false;
    }
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      _logger.i('FCM token obtained: ${token?.substring(0, 20)}...');
      return token;
    } on Exception catch (e) {
      _logger.e('Failed to get FCM token: $e');
      return null;
    }
  }

  /// Save FCM token to Supabase
  Future<void> _saveFCMTokenToSupabase(String token) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        _logger.w('Cannot save FCM token because user is not logged in');
        return;
      }

      await supabase.from('user_fcm_tokens').upsert({
        'user_id': currentUser.id,
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'fcm_token');

      _logger.i('FCM token saved to Supabase');
    } on Exception catch (e) {
      _logger.e('Failed to save FCM token to Supabase: $e');
    }
  }

  /// Handle foreground message
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _logger.i('Message received in foreground: ${message.messageId}');

    final messageType = message.data['type'] as String?;
    if (messageType == 'heart') {
      await _showHeartNotification(message);
    } else {
      await _showLocalNotification(message);
    }
  }

  /// Show like notification
  Future<void> _showHeartNotification(RemoteMessage message) async {
    final userName = message.data['userName'] as String? ?? 'Someone';

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
      'Your post received a "Like!" 🍰',
      '$userName also thought it looks delicious!',
      notificationDetails,
    );
  }

  /// Show local notification
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
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      notificationDetails,
    );
  }

  /// Handle message when app is opened
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    _logger.i('Message received when app was opened: ${message.messageId}');

    final messageType = message.data['type'] as String?;
    if (messageType == 'heart') {
      final postId = message.data['postId'] as String?;
      _logger.i('Like notification tapped: Post ID=$postId');
      // Implement navigation to post detail screen here
    }
  }

  /// Send like notification
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
        'Like notification send request sent: '
        'Post Owner ID=$postOwnerId, Post ID=$postId, Liker=$likerName, '
        'Response=$data',
      );
    } on Exception catch (e) {
      _logger.e('Failed to send like notification: $e');
    }
  }

  /// Delete FCM token (used when logging out, etc.)
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
      _logger.i('FCM token deleted');
    } on Exception catch (e) {
      _logger.e('Failed to delete FCM token: $e');
    }
  }
}
```

### Step 3: Initialize in main.dart

Add the following to `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:food_gram_app/core/notification/firebase_messaging_service.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final logger = Logger();
  final messageType = message.data['type'] as String?;
  if (messageType == 'heart') {
    final userName = message.data['userName'] as String? ?? 'Someone';
    logger.i(
      'Like notification received in background: ${message.messageId}, '
      'User: $userName',
    );
  } else {
    logger.i('Message received in background: ${message.messageId}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Initialize Firebase Messaging Service
  final firebaseMessagingService = FirebaseMessagingService();
  await firebaseMessagingService.initialize();
  
  runApp(MyApp());
}
```

### Step 4: Send Notification from Like Feature

Send notification when the like button is tapped in post detail screen, etc.:

```dart
final firebaseMessagingService = FirebaseMessagingService();
await firebaseMessagingService.sendHeartNotification(
  postOwnerId: post.userId,
  postId: post.id,
  likerName: currentUser.name,
);
```

---

## Testing Methods

### iOS → Android Test

1. **Launch app on iOS device**
   - Log in and grant notification permission
   - Create a post

2. **Launch app on Android device**
   - Log in and grant notification permission
   - Move app to background

3. **Send like from iOS device**
   - Open Android device's post
   - Tap like button

4. **Check notification on Android device**
   - Verify notification is received

### Android → iOS Test

1. **Launch app on iOS device**
   - Log in and grant notification permission
   - Create a post
   - Move app to background

2. **Launch app on Android device**
   - Log in and grant notification permission

3. **Send like from Android device**
   - Open iOS device's post
   - Tap like button

4. **Check notification on iOS device**
   - Verify notification is received

---

## Troubleshooting

### Issue 1: APNS Authentication Error Occurs

**Error Message:**
```
Auth error from APNS or Web Push Service
```

**Solution:**
1. Verify the correct iOS app is selected in Firebase Console
2. Verify APNS authentication key is correctly uploaded
3. Verify Key ID and Team ID are correct
4. Wait 1 hour for settings to take effect

### Issue 2: Cannot Get FCM Token

**Solution:**
1. Verify notification permission is granted in iOS app
2. Verify `GoogleService-Info.plist` is correctly placed
3. Restart app and re-obtain FCM token

### Issue 3: Notifications Not Received

**Solution:**
1. Verify notification permission is granted
2. Verify app is in background
3. Verify FCM token is saved in Supabase
4. Check errors in Supabase Functions Logs

### Issue 4: Bundle ID Mismatch

**Solution:**
1. Check Bundle ID in Xcode
2. Verify it matches the Bundle ID registered in Firebase Console
3. Set APNS authentication key for the app with the correct Bundle ID

---

## Summary

By following this guide, push notifications for both iOS and Android should work.

Key Points:
- ✅ Correctly configure APNS authentication key in Firebase Console
- ✅ Select app with correct Bundle ID
- ✅ Implement correct code in Supabase Functions
- ✅ Correctly save FCM tokens in Flutter app
- ✅ Wait 1 hour for settings to take effect

If issues occur, refer to the Troubleshooting section.

