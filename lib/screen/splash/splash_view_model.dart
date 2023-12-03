import 'package:flutter/material.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/mixin/account_exist_mixin.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/screen/splash/splash_state.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_view_model.g.dart';

@riverpod
class SplashViewModel extends _$SplashViewModel with AccountExistMixin {
  @override
  SplashState build({
    SplashState initState = const SplashState(),
  }) {
    return initState;
  }

  Future<void> redirect(BuildContext context) async {
    await Future.delayed(Duration.zero);
    final session = supabase.auth.currentSession;
    if (session == null || !await loginStatus()) {
      context.pushReplacementNamed(RouterPath.authentication);
    } else if (!await doesAccountExist()) {
      context.pushReplacementNamed(RouterPath.newAccount);
    } else {
      context.pushReplacementNamed(RouterPath.tab);
    }
  }
}
