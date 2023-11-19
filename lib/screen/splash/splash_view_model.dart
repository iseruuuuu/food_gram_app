import 'package:flutter/material.dart';
import 'package:food_gram_app/screen/authentication/authentication_screen.dart';
import 'package:food_gram_app/screen/authentication/new_account_screen.dart';
import 'package:food_gram_app/screen/splash/splash_state.dart';
import 'package:food_gram_app/screen/tab/tab_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'splash_view_model.g.dart';

@riverpod
class SplashViewModel extends _$SplashViewModel {
  @override
  SplashState build({
    SplashState initState = const SplashState(),
  }) {
    return initState;
  }

  final supabase = Supabase.instance.client;

  Future<void> redirect(BuildContext context) async {
    await Future.delayed(Duration.zero);
    final session = supabase.auth.currentSession;
    if (session == null) {
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

  Future<bool> doesAccountExist() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        return false;
      }
      final response = await supabase
          .from('users')
          .select()
          .eq('user_id', user.id)
          .execute();
      final data = response.data;
      if (data is List && data.isEmpty) {
        return false;
      }
      return true;
    } on Exception catch (_) {
      return false;
    }
  }
}
