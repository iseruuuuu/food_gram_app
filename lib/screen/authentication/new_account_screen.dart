import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/component/app_edit_text_field.dart';
import 'package:food_gram_app/component/app_elevated_button.dart';
import 'package:food_gram_app/component/app_loading.dart';
import 'package:food_gram_app/provider/loading.dart';
import 'package:food_gram_app/screen/authentication/new_account_view_model.dart';

class NewAccountScreen extends ConsumerWidget {
  const NewAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loadingProvider);
    final controller = ref.watch(newAccountViewModelProvider().notifier);
    final state = ref.watch(newAccountViewModelProvider());
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/image/food.png'),
                    radius: 60,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //TODO 画像を選ぶ感じにする。
                      Image.asset(
                        'assets/image/food.png',
                        width: 50,
                        height: 50,
                      ),
                      Image.asset(
                        'assets/image/food.png',
                        width: 50,
                        height: 50,
                      ),
                      Image.asset(
                        'assets/image/food.png',
                        width: 50,
                        height: 50,
                      ),
                      Image.asset(
                        'assets/image/food.png',
                        width: 50,
                        height: 50,
                      ),
                    ],
                  ),
                  AppEditTextField(
                    title: '名前',
                    controller: controller.nameTextController,
                  ),
                  //TODO これは英語のみにする
                  AppEditTextField(
                    title: 'ユーザー名',
                    controller: controller.userNameTextController,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      state.loginStatus,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AppElevatedButton(
                    onPressed: () => ref
                        .read(newAccountViewModelProvider().notifier)
                        .setUsers(context),
                    title: '登録',
                  ),
                ],
              ),
            ),
            AppLoading(loading: loading),
          ],
        ),
      ),
    );
  }
}
