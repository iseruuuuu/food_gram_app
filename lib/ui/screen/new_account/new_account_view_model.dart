import 'package:flutter/material.dart';
import 'package:food_gram_app/core/data/supabase/auth/account_service.dart';
import 'package:food_gram_app/ui/screen/new_account/new_account_state.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'new_account_view_model.g.dart';

@riverpod
class NewAccountViewModel extends _$NewAccountViewModel {
  @override
  NewAccountState build({
    NewAccountState initState = const NewAccountState(),
  }) {
    ref.onDispose(() {
      nameTextController.dispose();
      userNameTextController.dispose();
    });
    return initState;
  }

  Loading get loading => ref.read(loadingProvider.notifier);

  final nameTextController = TextEditingController();
  final userNameTextController = TextEditingController();

  void selectIcon(int number) {
    state = state.copyWith(number: number);
  }

  Future<bool> setUsers() async {
    state = state.copyWith(loginStatus: '');
    primaryFocus?.unfocus();
    loading.state = true;
    if (nameTextController.text.isNotEmpty &&
        userNameTextController.text.isNotEmpty) {
      final result = await ref.read(accountServiceProvider).createUsers(
            name: nameTextController.text.trim(),
            userName: userNameTextController.text.trim(),
            image: state.number,
          );
      result.when(
        success: (_) {
          state = state.copyWith(
            loginStatus: 'アカウントの登録が完了しました',
            isSuccess: true,
          );
        },
        failure: (_) {
          state = state.copyWith(
            loginStatus: 'エラーが発生しました',
            isSuccess: false,
          );
        },
      );
      loading.state = false;
      return state.isSuccess;
    } else {
      state = state.copyWith(loginStatus: '必要な情報が入力されていません');
      return false;
    }
  }
}
