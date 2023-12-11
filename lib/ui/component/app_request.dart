import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

class AppRequest extends StatelessWidget {
  const AppRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🙇現在地をオンにしてください🙇',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'レストランの選択には現在地のデータが必要になります',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '以下のボタンから設定画面に遷移します',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            SizedBox(height: 50),
            TextButton(
              onPressed: () {
                AppSettings.openAppSettings(type: AppSettingsType.location);
              },
              child: Text(
                '設定画面を開く',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
