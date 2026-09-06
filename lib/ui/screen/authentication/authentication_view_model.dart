import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/supabase/auth/services/account_service.dart';
import 'package:food_gram_app/core/supabase/auth/services/auth_service.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
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

  void _logLogin(String method) {
    ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
          name: AnalyticsEvent.login,
          parameters: {AnalyticsParam.method: method},
        );
  }

  Future<void> loginApple(BuildContext context) async {
    primaryFocus?.unfocus();
    final result = await ref.read(authServiceProvider).loginApple();
    await result.when(
      success: (_) async {
        _logLogin('apple');
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
        _logLogin('google');
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

  /// SNSログイン後にプロフィールが無ければ仮名で作成する。
  /// `true` は新規作成、`false` は既存、`null` は失敗。
  Future<bool?> completeSignIn() async {
    loading.state = true;
    ref.read(currentUserProvider.notifier).update();
    try {
      for (var i = 0; i < 2; i++) {
        final result =
            await ref.read(accountServiceProvider).ensureUserRegistered();
        final isNewUser = result.when(
          success: (value) => value,
          failure: (_) => null,
        );
        if (isNewUser != null) {
          return isNewUser;
        }
      }
      return null;
    } finally {
      loading.state = false;
    }
  }

  Future<void> loginTwitter(BuildContext context) async {
    primaryFocus?.unfocus();
    final result = await ref.read(authServiceProvider).loginTwitter();
    await result.when(
      success: (_) async {
        _logLogin('twitter');
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
