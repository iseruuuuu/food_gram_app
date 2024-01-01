import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/ui/component/app_elevated_button.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({required this.onTap, super.key});

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '通信エラー',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '接続エラーが発生しました。\nネットワーク接続を確認し、もう一度試してください。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Assets.image.error.image(
              width: 150,
              height: 150,
            ),
            SizedBox(height: 50),
            AppElevatedButton(
              onPressed: onTap,
              title: '再読み込み',
            ),
          ],
        ),
      ),
    );
  }
}
