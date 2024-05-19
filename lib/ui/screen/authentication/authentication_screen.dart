import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/gen/assets.gen.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/screen/authentication/authentication_view_model.dart';
import 'package:food_gram_app/utils/mixin/account_exist_mixin.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_button/sign_button.dart';
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
    final theme = Theme.of(context);
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
                      Assets.image.food.image(width: 70, height: 70),
                      Text(
                        'Food Instagram',
                        style: theme.textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Gap(20),
                  AppAuthTextField(
                    controller: ref
                        .watch(authenticationViewModelProvider().notifier)
                        .emailTextField,
                  ),
                  Gap(20),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width - 80,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        backgroundColor: Colors.black,
                      ),
                      onPressed: ref
                          .read(authenticationViewModelProvider().notifier)
                          .login,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mail,
                            color: Colors.white,
                          ),
                          Gap(10),
                          Text(
                            'Sign in with Mail',
                            style: theme.textTheme.bodyLarge!.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 10,
                    ),
                    child: Divider(),
                  ),
                  Text(
                    'SNSログイン',
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(20),
                  Wrap(
                    children: [
                      if (Platform.isIOS)
                        SignInButton.mini(
                          buttonType: ButtonType.appleDark,
                          onPressed: ref
                              .read(authenticationViewModelProvider().notifier)
                              .loginApple,
                        ),
                      SignInButton.mini(
                        buttonType: ButtonType.googleDark,
                        onPressed: ref
                            .read(authenticationViewModelProvider().notifier)
                            .loginGoogle,
                      ),
                    ],
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
