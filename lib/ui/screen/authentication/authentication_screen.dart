import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/screen/authentication/authentication_view_model.dart';
import 'package:food_gram_app/utils/mixin/account_exist_mixin.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
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
    final loading = ref.watch(loadingProvider);
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.image.food.image(width: 72, height: 72),
                        Gap(12),
                        Text(
                          'FoodGram',
                          style: theme.textTheme.headlineLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Gap(12),
                    AppAuthTextField(controller: controller.emailTextField),
                    Gap(8),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width - 80,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                        ),
                        onPressed: () => controller.login(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mail, color: Colors.white),
                            Gap(12),
                            Text(
                              'Sign in with Mail',
                              style: theme.textTheme.titleMedium!
                                  .copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Gap(20),
                    Divider(),
                    Gap(12),
                    Text(
                      'SNSログイン',
                      style: theme.textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gap(24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (Platform.isIOS) {
                              controller.loginApple(context);
                            } else {
                              openErrorSnackBar(context, 'Appleログインはできません');
                            }
                          },
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(FontAwesomeIcons.apple, size: 35),
                          ),
                        ),
                        Gap(40),
                        GestureDetector(
                          onTap: () => controller.loginGoogle(context),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Assets.image.logoGoogle.image(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AppLoading(loading: loading, status: 'Loading...'),
          ],
        ),
      ),
    );
  }
}
