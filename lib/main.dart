import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/app.dart';
import 'package:food_gram_app/env.dart';
import 'package:food_gram_app/firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSystemSettings();
  await initializeThirdPartyServices();
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
  /// Supabaseの初期化
  await Supabase.initialize(
    anonKey: kReleaseMode ? Prod.supabaseAnonKey : Dev.supabaseAnonKey,
    url: kReleaseMode ? Prod.supabaseUrl : Dev.supabaseUrl,
    debug: kDebugMode,
  );

  /// Firebaseの初期化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
