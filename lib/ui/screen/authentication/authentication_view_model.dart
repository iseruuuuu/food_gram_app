import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_gram_app/core/data/supabase/auth/auth_service.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/screen/authentication/authentication_state.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:food_gram_app/utils/snack_bar_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'authentication_view_model.g.dart';

@riverpod
class AuthenticationViewModel extends _$AuthenticationViewModel {
  @override
  AuthenticationState build({
    AuthenticationState initState = const AuthenticationState(),
  }) {
    ref.onDispose(emailTextField.dispose);
    return initState;
  }

  final emailTextField = TextEditingController();

  Loading get loading => ref.read(loadingProvider.notifier);

  Future<void> login(BuildContext context) async {
    loading.state = true;
    hideSnackBar(context);
    primaryFocus?.unfocus();
    if (emailTextField.text.isNotEmpty) {
      final result =
          await ref.read(authServiceProvider).login(emailTextField.text.trim());
      await result.when(
        success: (_) async {
          await Future.delayed(Duration(seconds: 2));
          openSuccessSnackBar(
            context,
            L10n.of(context).loginSuccessful,
            L10n.of(context).emailAuthentication,
          );
        },
        failure: (error) {
          logger.e(error);
          openErrorSnackBar(
            context,
            error,
            L10n.of(context).emailAuthenticationFailure,
          );
        },
      );
    } else {
      openErrorSnackBar(
        context,
        L10n.of(context).emailEmpty,
        L10n.of(context).loginError,
      );
    }
    loading.state = false;
  }

  Future<void> loginApple(BuildContext context) async {
    primaryFocus?.unfocus();
    final result = await ref.read(authServiceProvider).loginApple();
    await result.when(
      success: (_) async {
        state = state.copyWith(loginStatus: L10n.of(context).loginSuccessful);
      },
      failure: (error) {
        logger.e(error);
        openErrorSnackBar(
          context,
          L10n.of(context).error,
          L10n.of(context).loginError,
        );
      },
    );
  }

  Future<void> loginGoogle(BuildContext context) async {
    primaryFocus?.unfocus();
    final result = await ref.read(authServiceProvider).loginGoogle();
    await result.when(
      success: (_) async {
        state = state.copyWith(
          loginStatus: L10n.of(context).loginSuccessful,
        );
      },
      failure: (error) {
        logger.e(error);
        openErrorSnackBar(
          context,
          L10n.of(context).error,
          L10n.of(context).loginError,
        );
      },
    );
  }
}
