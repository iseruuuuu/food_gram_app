import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/app.dart';
import 'package:food_gram_app/core/notification/notification_initializer.dart';
import 'package:food_gram_app/env.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSystemSettings();
  await initializeThirdPartyServices();
  await initializePurchases();
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

/// RevenueCatの初期化処理
Future<void> initializePurchases() async {
  await Purchases.setLogLevel(LogLevel.debug);
  await Purchases.configure(
    PurchasesConfiguration(
      Platform.isAndroid ? Env.androidPurchaseKey : Env.iOSPurchaseKey,
    ),
  );
}
