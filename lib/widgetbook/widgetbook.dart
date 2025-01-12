import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/env.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/widgetbook/widgetbook.directories.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSystemSettings();
  await Supabase.initialize(
    anonKey: kReleaseMode ? Prod.supabaseAnonKey : Dev.supabaseAnonKey,
    url: kReleaseMode ? Prod.supabaseUrl : Dev.supabaseUrl,
    debug: kDebugMode,
  );
  runApp(const WidgetbookApp());
}

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      appBuilder: (context, child) =>
          ProviderScope(child: MaterialApp(home: child)),
      addons: <WidgetbookAddon>[
        MaterialThemeAddon(
          themes: <WidgetbookTheme<ThemeData>>[
            WidgetbookTheme<ThemeData>(
              name: 'Light',
              data: ThemeData.light(useMaterial3: true),
            ),
            WidgetbookTheme<ThemeData>(
              name: 'Dark',
              data: ThemeData.dark(useMaterial3: true),
            ),
          ],
        ),
        DeviceFrameAddon(
          devices: <DeviceInfo>[
            Devices.ios.iPhoneSE,
            Devices.ios.iPhone13,
          ],
          initialDevice: Devices.ios.iPhone13,
        ),
        TextScaleAddon(),
        LocalizationAddon(
          locales: L10n.supportedLocales,
          localizationsDelegates: L10n.localizationsDelegates,
          initialLocale: L10n.supportedLocales.last,
        ),
      ],
    );
  }
}
