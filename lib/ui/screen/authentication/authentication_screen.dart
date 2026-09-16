import 'dart:async';
import 'dart:io';

import 'package:auth_button_kit/auth_button_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/theme/style/authentication_style.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/loading/app_overlay_loading.dart';
import 'package:food_gram_app/ui/screen/authentication/authentication_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthenticationScreen extends HookConsumerWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loadingProvider);
    final controller = ref.watch(authenticationViewModelProvider().notifier);
    final supabase = ref.read(supabaseProvider);
    final hasNavigatedRef = useRef(false);
    final authStateSubscription = useMemoized(
      () => supabase.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null && !hasNavigatedRef.value) {
          hasNavigatedRef.value = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!context.mounted) {
              return;
            }
            final didNavigate = await redirect(context, ref);
            if (!didNavigate) {
              hasNavigatedRef.value = false;
            }
          });
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Theme.of(context).colorScheme.surface,
                        ],
                        stops: const [0.6, 1.0],
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
                            Translations.of(context).app.title,
                            style: AuthenticationStyle.authTitleStyle(context),
                          ),
                          Text(
                            Translations.of(context).app.subtitle,
                            style:
                                AuthenticationStyle.authSubTitleStyle(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(14),
                  Divider(color: Theme.of(context).colorScheme.outlineVariant),
                  const Gap(14),
                  AuthButton(
                    brand: Method.apple,
                    backgroundColor:
                        AuthenticationStyle.authButtonBackground(context),
                    textColor: AuthenticationStyle.authButtonTextColor(context),
                    shape: AuthenticationStyle.authButtonShape(context),
                    fontWeight: FontWeight.bold,
                    padding: EdgeInsets.zero,
                    splashEffect:
                        Theme.of(context).brightness != Brightness.dark,
                    onPressed: (_) {
                      if (Platform.isIOS) {
                        controller.loginApple(context);
                      } else {
                        SnackBarHelper().openErrorSnackBar(
                          context,
                          Translations.of(context).auth.appleLoginFailure,
                          '',
                        );
                      }
                    },
                  ),
                  const Gap(24),
                  AuthButton(
                    brand: Method.google,
                    backgroundColor:
                        AuthenticationStyle.authButtonBackground(context),
                    textColor: AuthenticationStyle.authButtonTextColor(context),
                    shape: AuthenticationStyle.authButtonShape(context),
                    fontWeight: FontWeight.bold,
                    padding: EdgeInsets.zero,
                    splashEffect:
                        Theme.of(context).brightness != Brightness.dark,
                    onPressed: (_) => controller.loginGoogle(context),
                  ),
                  const Gap(24),
                  AuthButton(
                    brand: Method.twitter,
                    text: 'Continue with X',
                    backgroundColor:
                        AuthenticationStyle.authButtonBackground(context),
                    textColor: AuthenticationStyle.authButtonTextColor(context),
                    shape: AuthenticationStyle.authButtonShape(context),
                    fontWeight: FontWeight.bold,
                    padding: EdgeInsets.zero,
                    splashEffect:
                        Theme.of(context).brightness != Brightness.dark,
                    onPressed: (_) => controller.loginTwitter(context),
                  ),
                ],
              ),
            ),
          ),
          AppProcessLoading(loading: loading, status: 'Loading...'),
        ],
      ),
    );
  }

  Future<bool> redirect(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) {
      return false;
    }
    SnackBarHelper().hideSnackBar(context);
    final isNewUser = await ref
        .read(authenticationViewModelProvider().notifier)
        .completeSignIn();
    if (!context.mounted) {
      return false;
    }
    if (isNewUser == null) {
      SnackBarHelper().openErrorSnackBar(
        context,
        '',
        Translations.of(context).accountRegistration.error,
      );
      return false;
    }
    context.pushReplacementNamed(
      isNewUser ? RouterPath.registrationWelcome : RouterPath.tab,
    );
    return true;
  }
}
