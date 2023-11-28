import 'package:flutter/material.dart';
import 'package:food_gram_app/mixin/account_exist_mixin.dart';
import 'package:food_gram_app/screen/authentication/authentication_screen.dart';
import 'package:food_gram_app/screen/authentication/new_account_screen.dart';
import 'package:food_gram_app/screen/splash/splash_state.dart';
import 'package:food_gram_app/screen/tab/tab_screen.dart';
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
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AuthenticationScreen(),
        ),
      );
    } else if (!await doesAccountExist()) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NewAccountScreen(),
        ),
      );
    } else {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TabScreen(),
        ),
      );
    }
  }
}
