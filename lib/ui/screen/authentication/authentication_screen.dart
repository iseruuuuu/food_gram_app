import 'dart:async';
import 'dart:io';

import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/supabase/auth/services/account_service.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/theme/style/authentication_style.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/screen/authentication/authentication_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthenticationScreen extends HookConsumerWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loadingProvider);
    final buttonWidth = MediaQuery.of(context).size.width;
    final controller = ref.watch(authenticationViewModelProvider().notifier);
    final supabase = ref.read(supabaseProvider);
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    Assets.image.authImage.path,
                    height: MediaQuery.of(context).size.height * 0.45,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.white],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 200),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Assets.image.food.image(width: 60, height: 60),
                      Column(
                        children: [
                          Text(
                            L10n.of(context).appTitle,
                            style: AuthenticationStyle.authTitleStyle(),
                          ),
                          Text(
                            L10n.of(context).appSubtitle,
                            style: AuthenticationStyle.authSubTitleStyle(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(28),
                  const Divider(),
                  const Gap(28),
                  AppleAuthButton(
                    style: AuthenticationStyle.authButtonStyle(buttonWidth),
                    onPressed: () {
                      if (Platform.isIOS) {
                        controller.loginApple(context);
                      } else {
                        SnackBarHelper().openErrorSnackBar(
                          context,
                          L10n.of(context).appleLoginFailure,
                          '',
                        );
                      }
                    },
                  ),
                  const Gap(24),
                  GoogleAuthButton(
                    onPressed: () => controller.loginGoogle(context),
                    style: AuthenticationStyle.authButtonStyle(buttonWidth),
                  ),
                  const Gap(24),
                  TwitterAuthButton(
                    onPressed: () => controller.loginTwitter(context),
                    style: AuthenticationStyle.authButtonStyle(buttonWidth),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Assets.gif.login1.image(width: 70, height: 70),
                Assets.gif.login2.image(width: 70, height: 70),
                Assets.gif.login3.image(width: 70, height: 70),
                Assets.gif.login4.image(width: 70, height: 70),
              ],
            ),
          ),
          AppLoading(loading: loading, status: 'Loading...'),
        ],
      ),
    );
  }

  Future<void> redirect(BuildContext context, WidgetRef ref) async {
    SnackBarHelper().hideSnackBar(context);
    ref.read(currentUserProvider.notifier).update();
    if (await ref.read(accountServiceProvider).isUserRegistered()) {
      context.pushReplacementNamed(RouterPath.tab);
    } else {
      context.pushReplacementNamed(RouterPath.newAccount);
    }
  }
}
