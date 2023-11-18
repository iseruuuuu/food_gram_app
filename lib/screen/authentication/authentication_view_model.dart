import 'package:flutter/material.dart';
import 'package:food_gram_app/provider/loading.dart';
import 'package:food_gram_app/screen/authentication/authentication_state.dart';
import 'package:food_gram_app/screen/authentication/new_account_screen.dart';
import 'package:food_gram_app/screen/tab/tab_screen.dart';
import 'package:open_mail_app/open_mail_app.dart';
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

  final supabase = Supabase.instance.client;
  final emailTextField = TextEditingController();
  final _shouldCreateUser = true;

  Loading get loading => ref.read(loadingProvider.notifier);

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
        loading.state = false;
        state = state.copyWith(
          loginStatus: 'ログインの成功\n'
              'メールアプリを立ち上げます...',
        );
        await Future.delayed(Duration(seconds: 2));
        await _openInMailApp(context);
        state = state.copyWith(loginStatus: 'ログインの成功');
        if (!await doesAccountExist()) {
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
      } on AuthException catch (error) {
        loading.state = false;
        state = state.copyWith(loginStatus: error.message);
      } on Exception catch (error) {
        loading.state = false;
        state = state.copyWith(loginStatus: error.toString());
      }
    } else {
      state = state.copyWith(loginStatus: 'メールアドレスが入力されていません');
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

  Future<void> _openInMailApp(BuildContext context) async {
    final result = await OpenMailApp.openMailApp();

    if (!result.didOpen && !result.canOpen) {
      print('not open mail');
      state = state.copyWith(loginStatus: 'メールのアプリの立ち上げに\n失敗しました');
    } else {
      await showDialog(
        context: context,
        builder: (_) {
          return MailAppPickerDialog(
            title: 'メールアプリを開く',
            mailApps: result.options,
          );
        },
      );
    }
  }
}
