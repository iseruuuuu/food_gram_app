import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/config/environment.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await dotenv.load(fileName: Environment().fileName);
  await Supabase.initialize(
    anonKey: Environment().supabaseAnonKey,
    url: Environment().supabaseUrl,
    debug: kDebugMode,
  );
  runApp(const ProviderScope(child: MyApp()));
}

final supabase = Supabase.instance.client;
final logger = Logger();

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      localizationsDelegates: const [
        ...L10n.localizationsDelegates,
      ],
      supportedLocales: const [
        ...L10n.supportedLocales,
      ],
      routerConfig: ref.watch(routerProvider),
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: kReleaseMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}
