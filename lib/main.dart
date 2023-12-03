import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/config/environment.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await dotenv.load(fileName: Environment().fileName);
  await Supabase.initialize(
    anonKey: Environment().supabaseAnonKey,
    url: Environment().supabaseUrl,
    debug: kDebugMode,
    authCallbackUrlHostname: 'login-callback',
  );
  runApp(const ProviderScope(child: MyApp()));
}

final supabase = Supabase.instance.client;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerProvider = ref.watch(router);
    return MaterialApp.router(
      routerConfig: routerProvider,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: kReleaseMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
