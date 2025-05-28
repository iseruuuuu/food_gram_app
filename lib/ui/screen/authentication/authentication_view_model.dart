import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_gram_app/core/supabase/auth/services/auth_service.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
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
    ref.onDispose(emailTextField.dispose);
    return initState;
  }

  final logger = Logger();

  final emailTextField = TextEditingController();

  Loading get loading => ref.read(loadingProvider.notifier);

  Future<void> loginApple(BuildContext context) async {
    primaryFocus?.unfocus();
    final result = await ref.read(authServiceProvider).loginApple();
    await result.when(
      success: (_) async {
        state = state.copyWith(loginStatus: L10n.of(context).loginSuccessful);
      },
      failure: (error) {
        logger.e(error);
        SnackBarHelper().openErrorSnackBar(
          context,
          L10n.of(context).loginError,
          L10n.of(context).error,
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
        SnackBarHelper().openErrorSnackBar(
          context,
          L10n.of(context).loginError,
          L10n.of(context).error,
        );
      },
    );
  }

  Future<void> loginTwitter(BuildContext context) async {
    primaryFocus?.unfocus();
    final result = await ref.read(authServiceProvider).loginTwitter();
    await result.when(
      success: (_) async {
        state = state.copyWith(loginStatus: L10n.of(context).loginSuccessful);
      },
      failure: (error) {
        logger.e(error);
        SnackBarHelper().openErrorSnackBar(
          context,
          L10n.of(context).loginError,
          L10n.of(context).error,
        );
      },
    );
  }
}

String authErrorManager(String error, BuildContext context) {
  switch (error) {
    case 'Unable to validate email address: invalid format':
      return L10n.of(context).authInvalidFormat;
    default:
      return L10n.of(context).authSocketException;
  }
}
