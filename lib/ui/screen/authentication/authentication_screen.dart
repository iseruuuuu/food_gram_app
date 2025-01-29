import 'dart:async';
import 'dart:io';

import 'package:auth_buttons/auth_buttons.dart'
    show AppleAuthButton, AuthButtonStyle, GoogleAuthButton;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/utils/mixin/account_exist_mixin.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/core/utils/snack_bar_manager.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/screen/authentication/authentication_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snow_fall_animation/snow_fall_animation.dart';

class AuthenticationScreen extends HookConsumerWidget with AccountExistMixin {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loadingProvider);
    final theme = Theme.of(context);
    final controller = ref.watch(authenticationViewModelProvider().notifier);
    final authStateSubscription = useMemoized(
      () => supabase.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null) {
          redirect(context, ref);
        }
      }),
    );

    useEffect(
      () {
        return authStateSubscription.cancel;
      },
      [authStateSubscription],
    );

    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SnowFallAnimation(
              config: SnowfallConfig(
                numberOfSnowflakes: 300,
                enableRandomOpacity: false,
                enableSnowDrift: false,
                customEmojis: ['❄️', '❅', '❆'],
                holdSnowAtBottom: false,
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    Gap(80),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.image.food.image(width: 72, height: 72),
                        Gap(12),
                        Text(
                          'FoodGram',
                          style: theme.textTheme.headlineLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
                    Gap(24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.gif.login1.image(width: 70, height: 70),
                        Assets.gif.login2.image(width: 70, height: 70),
                        Assets.gif.login3.image(width: 70, height: 70),
                        Assets.gif.login4.image(width: 70, height: 70),
                      ],
                    ),
                    Gap(12),
                    Divider(),
                    Gap(24),
                    AppleAuthButton(
                      style: AuthButtonStyle(
                        splashColor: Colors.white,
                        height: 50,
                        elevation: 3,
                        borderRadius: 20,
                        width: MediaQuery.of(context).size.width / 1.3,
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        if (Platform.isIOS) {
                          controller.loginApple(context);
                        } else {
                          openErrorSnackBar(
                            context,
                            L10n.of(context).appleLoginFailure,
                            '',
                          );
                        }
                      },
                    ),
                    Gap(24),
                    GoogleAuthButton(
                      onPressed: () => controller.loginGoogle(context),
                      style: AuthButtonStyle(
                        splashColor: Colors.white,
                        height: 50,
                        elevation: 3,
                        borderRadius: 20,
                        width: MediaQuery.of(context).size.width / 1.3,
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Future<void> redirect(BuildContext context, WidgetRef ref) async {
    hideSnackBar(context);
    if (!await doesAccountExist()) {
      context.pushReplacementNamed(RouterPath.tab);
    } else {
      context.pushReplacementNamed(RouterPath.newAccount);
    }
  }
}
