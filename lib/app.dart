import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/notification/firebase_messaging_service.dart';
import 'package:food_gram_app/core/theme/text_form_borders.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:toastification/toastification.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Firebase Messaging ServiceにRefを設定（ディープリンク用）
    final firebaseMessagingService = FirebaseMessagingService();
    firebaseMessagingService.setRef(ref);

    return ToastificationWrapper(
      child: MaterialApp.router(
        localizationsDelegates: const [
          ...L10n.localizationsDelegates,
        ],
        supportedLocales: const [
          ...L10n.supportedLocales,
        ],
        localeListResolutionCallback: (locales, supported) {
          for (final deviceLocale in locales ?? const <Locale>[]) {
            // 1) 言語+地域の完全一致を優先して supported から返す
            for (final s in supported) {
              if (s.languageCode == deviceLocale.languageCode &&
                  s.countryCode == deviceLocale.countryCode) {
                return s;
              }
            }
            // 2) 言語コード一致で supported から返す
            for (final s in supported) {
              if (s.languageCode == deviceLocale.languageCode) {
                return s;
              }
            }
          }
          // 3) 非対応は英語
          return const Locale('en');
        },
        routerConfig: ref.watch(routerProvider),
        debugShowCheckedModeBanner: kReleaseMode,
        theme: ThemeData(
          inputDecorationTheme: const InputDecorationTheme(
            contentPadding: EdgeInsets.all(15),
            focusedBorder: TextFormBorders.textFormFocusedBorder,
            enabledBorder: TextFormBorders.textFormEnabledBorder,
            focusedErrorBorder: TextFormBorders.textFormErrorBorder,
            errorBorder: TextFormBorders.textFormErrorBorder,
          ),
        ),
      ),
    );
  }
}
