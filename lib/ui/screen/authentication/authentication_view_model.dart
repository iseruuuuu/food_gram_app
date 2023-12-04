import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/screen/authentication/authentication_state.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final _shouldCreateUser = true;

  Loading get loading => ref.read(loadingProvider.notifier);

  Future<void> login() async {
    if (emailTextField.text.isNotEmpty) {
      try {
        primaryFocus?.unfocus();
        loading.state = true;
        await supabase.auth.signInWithOtp(
          email: emailTextField.text.trim(),
          shouldCreateUser: _shouldCreateUser,
          emailRedirectTo: 'io.supabase.flutterquickstart://login-callback/',
        );
        await Future.delayed(Duration(seconds: 2));
        state = state.copyWith(loginStatus: 'メールアプリで認証をしてください');
      } on AuthException catch (error) {
        logger.e(error.message);
        state = state.copyWith(loginStatus: error.message);
      } on Exception catch (error) {
        logger.e(error);
        state = state.copyWith(loginStatus: error.toString());
      } finally {
        loading.state = false;
      }
    } else {
      state = state.copyWith(loginStatus: 'メールアドレスが入力されていません');
    }
  }
}
