import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_gram_app/config/supabase/auth_service.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/screen/authentication/authentication_state.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
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

  Future<void> login() async {
    loading.state = true;
    primaryFocus?.unfocus();
    if (emailTextField.text.isNotEmpty) {
      final result =
          await ref.read(authServiceProvider).login(emailTextField.text.trim());
      await result.when(
        success: (_) async {
          await Future.delayed(Duration(seconds: 2));
          state = state.copyWith(loginStatus: 'メールアプリで認証をしてください');
        },
        failure: (error) {
          logger.e(error);
          state = state.copyWith(loginStatus: 'エラーが発生しました');
        },
      );
    } else {
      state = state.copyWith(loginStatus: 'メールアドレスが入力されていません');
    }
    loading.state = false;
  }

  Future<void> loginApple() async {
    //TODO キャンセルをすると、ずっとローディングになってしまう。
    loading.state = true;
    primaryFocus?.unfocus();
    final result = await ref.read(authServiceProvider).loginApple();
    await result.when(
      success: (_) async {
        await Future.delayed(Duration(seconds: 2));
        loading.state = false;
      },
      failure: (error) {
        print(error);
        logger.e(error);
        state = state.copyWith(loginStatus: 'エラーが発生しました');
        loading.state = false;
      },
    );
  }
}
