import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_gram_app/core/supabase/auth/services/auth_service.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/screen/authentication/authentication_state.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'authentication_view_model.g.dart';

@riverpod
class AuthenticationViewModel extends _$AuthenticationViewModel {
  @override
  AuthenticationState build({
    AuthenticationState initState = const AuthenticationState(),
  }) {
    return initState;
  }

  final logger = Logger();

  Loading get loading => ref.read(loadingProvider.notifier);

  Future<void> loginApple(BuildContext context) async {
    primaryFocus?.unfocus();
    final result = await ref.read(authServiceProvider).loginApple();
    await result.when(
      success: (_) async {
        state = state.copyWith(
          loginStatus: Translations.of(context).auth.loginSuccessful,
        );
      },
      failure: (error) {
        logger.e(error);
        SnackBarHelper().openErrorSnackBar(
          context,
          Translations.of(context).auth.loginError,
          Translations.of(context).error.message,
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
          loginStatus: Translations.of(context).auth.loginSuccessful,
        );
      },
      failure: (error) {
        logger.e(error);
        SnackBarHelper().openErrorSnackBar(
          context,
          Translations.of(context).auth.loginError,
          Translations.of(context).error.message,
        );
      },
    );
  }

  Future<void> loginTwitter(BuildContext context) async {
    primaryFocus?.unfocus();
    final result = await ref.read(authServiceProvider).loginTwitter();
    await result.when(
      success: (_) async {
        state = state.copyWith(
          loginStatus: Translations.of(context).auth.loginSuccessful,
        );
      },
      failure: (error) {
        logger.e(error);
        SnackBarHelper().openErrorSnackBar(
          context,
          Translations.of(context).auth.loginError,
          Translations.of(context).error.message,
        );
      },
    );
  }
}

String authErrorManager(String error, BuildContext context) {
  return Translations.of(context).auth.authSocketException;
}
