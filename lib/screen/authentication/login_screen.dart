import 'package:flutter/material.dart';
import 'package:food_gram_app/component/app_elevated_button.dart';
import 'package:food_gram_app/component/app_post_text_field.dart';
import 'package:food_gram_app/component/app_text_button.dart';
import 'package:food_gram_app/screen/tab/tab_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/image/food.png',
                  width: 70,
                  height: 70,
                ),
                const Text(
                  'Food Instagram',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            AppPostTextField(
              controller: controller,
              hintText: 'メールアドレス',
              maxLines: 1,
            ),
            AppPostTextField(
              controller: controller,
              hintText: 'パスワード',
              maxLines: 1,
            ),
            AppTextButton(
              onPressed: () {},
              title: '新規登録',
              color: Colors.black,
            ),
            const SizedBox(height: 10),
            AppElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TabScreen(),
                  ),
                );
              },
              title: 'ログイン',
            ),
          ],
        ),
      ),
    );
  }
}
