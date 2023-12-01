import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_gram_app/mixin/account_exist_mixin.dart';
import 'package:food_gram_app/provider/loading.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/screen/authentication/authentication_state.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'authentication_view_model.g.dart';

@riverpod
class AuthenticationViewModel extends _$AuthenticationViewModel
    with AccountExistMixin {
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
  late StreamSubscription<AuthState> authStateSubscription;
  bool _redirecting = false;

  void init(BuildContext context) {
    authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) {
        return;
      }
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        redirect(context);
      }
    });
  }

  Future<void> login(BuildContext context) async {
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
        state = state.copyWith(loginStatus: error.message);
      } on Exception catch (error) {
        state = state.copyWith(loginStatus: error.toString());
      } finally {
        loading.state = false;
      }
    } else {
      state = state.copyWith(loginStatus: 'メールアドレスが入力されていません');
    }
  }

  Future<void> redirect(BuildContext context) async {
    if (!await doesAccountExist()) {
      context.pushReplacementNamed(RouterPath.newAccount);
    } else {
      context.pushReplacementNamed(RouterPath.tab);
    }
  }
}
