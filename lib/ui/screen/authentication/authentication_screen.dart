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
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/screen/authentication/authentication_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snow_fall_animation/snow_fall_animation.dart';

class AuthenticationScreen extends HookConsumerWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loadingProvider);
    final buttonWidth = MediaQuery.of(context).size.width / 1.3;
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

    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            const SnowFallAnimation(
              config: SnowfallConfig(
                numberOfSnowflakes: 300,
                enableRandomOpacity: false,
                enableSnowDrift: false,
                holdSnowAtBottom: false,
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Gap(80),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.image.food.image(width: 72, height: 72),
                        const Gap(12),
                        Text(
                          'FoodGram',
                          style: AuthenticationStyle.foodGram(),
                        ),
                      ],
                    ),
                      ),
                    ),
                    const Gap(24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.gif.login1.image(width: 70, height: 70),
                        Assets.gif.login2.image(width: 70, height: 70),
                        Assets.gif.login3.image(width: 70, height: 70),
                        Assets.gif.login4.image(width: 70, height: 70),
                      ],
                    ),
                    const Gap(12),
                    const Divider(),
                    const Gap(24),
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
                      style: AuthenticationStyle.authButtonStyle(buttonWidth),
                      onPressed: () => controller.loginGoogle(context),
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
    SnackBarHelper().hideSnackBar(context);
    ref.read(currentUserProvider.notifier).update();
    if (await ref.read(accountServiceProvider).isUserRegistered()) {
      context.pushReplacementNamed(RouterPath.tab);
    } else {
      context.pushReplacementNamed(RouterPath.newAccount);
    }
  }
}
