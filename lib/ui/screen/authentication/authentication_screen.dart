import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_auth_text_field.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/screen/authentication/authentication_view_model.dart';
import 'package:food_gram_app/utils/mixin/account_exist_mixin.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationScreen extends ConsumerStatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  AuthenticationScreenState createState() => AuthenticationScreenState();
}

class AuthenticationScreenState extends ConsumerState<AuthenticationScreen>
    with AccountExistMixin {
  @override
  void initState() {
    init(context);
    super.initState();
  }

  @override
  void dispose() {
    authStateSubscription.cancel();
    super.dispose();
  }

  late StreamSubscription<AuthState> authStateSubscription;
  bool _redirecting = false;

  void init(BuildContext context) {
    authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted || _redirecting) {
        return;
      }
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        redirect(context);
      }
    });
  }

  Future<void> redirect(BuildContext context) async {
    if (!await doesAccountExist()) {
      if (!mounted) {
        return;
      }
      context.pushReplacementNamed(RouterPath.newAccount);
    } else {
      if (!mounted) {
        return;
      }
      context.pushReplacementNamed(RouterPath.tab);
    }
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
                      Assets.image.food.image(
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
                  Gap(20),
                  AppAuthTextField(
                    controller: ref
                        .watch(authenticationViewModelProvider().notifier)
                        .emailTextField,
                    hintText: 'メールアドレス',
                    maxLines: 1,
                  ),
                  Gap(20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 100,
                    height: 50,
                    child: SignInButton(
                      Buttons.email,
                      onPressed: ref
                          .read(authenticationViewModelProvider().notifier)
                          .login,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  if (Platform.isIOS)
                    Column(
                      children: [
                        Gap(30),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 100,
                          height: 50,
                          child: SignInButton(
                            Buttons.apple,
                            onPressed: () async {
                              await ref
                                  .read(authenticationViewModelProvider()
                                      .notifier)
                                  .loginApple();
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  Gap(30),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 100,
                    height: 50,
                    child: SignInButton(
                      Buttons.google,
                      onPressed: () async {
                        await ref
                            .read(authenticationViewModelProvider().notifier)
                            .loginGoogle();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  Gap(40),
                  Text(
                    state.loginStatus,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            AppLoading(
              loading: loading,
              status: 'Loading...',
            ),
          ],
        ),
      ),
    );
  }
}
