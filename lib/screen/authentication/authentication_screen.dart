import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/component/app_elevated_button.dart';
import 'package:food_gram_app/component/app_loading.dart';
import 'package:food_gram_app/component/app_post_text_field.dart';
import 'package:food_gram_app/component/app_text_button.dart';
import 'package:food_gram_app/provider/loading.dart';
import 'package:food_gram_app/screen/authentication/authentication_view_model.dart';
import 'package:food_gram_app/screen/tab/tab_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AuthenticationScreen extends ConsumerStatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  ConsumerState<AuthenticationScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<AuthenticationScreen> {
  String appName = '';

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  Future<void> getInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authenticationViewModelProvider());
    final loading = ref.watch(loadingProvider);
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
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
                  Text(
                    appName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  AppPostTextField(
                    controller: ref
                        .watch(authenticationViewModelProvider().notifier)
                        .emailTextField,
                    hintText: 'メールアドレス',
                    maxLines: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      state.loginStatus,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppTextButton(
                    onPressed: () => ref
                        .read(authenticationViewModelProvider().notifier)
                        .login(context),
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
            AppLoading(loading: loading),
          ],
        ),
      ),
    );
  }
}
