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
