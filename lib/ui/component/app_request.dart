import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';

class AppRequest extends StatelessWidget {
  const AppRequest({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.appRequestTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.appRequestReason,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.appRequestInduction,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 50),
            TextButton(
              onPressed: () {
                AppSettings.openAppSettings(type: AppSettingsType.location);
              },
              child: Text(
                l10n.appRequestOpenSetting,
                style: const TextStyle(color: Colors.blue, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
