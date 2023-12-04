import 'package:flutter/material.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/screen/authentication/new_account_state.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> setUsers(BuildContext context) async {
    state = state.copyWith(loginStatus: '');
    primaryFocus?.unfocus();
    if (nameTextController.text.isNotEmpty &&
        userNameTextController.text.isNotEmpty) {
      loading.state = true;
      final name = nameTextController.text.trim();
      final userName = userNameTextController.text.trim();
      final updates = {
        'name': name,
        'user_name': userName,
        'self_introduce': '',
        'image': 'assets/icon/icon${state.number}.png',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      try {
        await supabase.from('users').insert(updates);
        state = state.copyWith(loginStatus: 'アカウントの登録が完了しました');
        await Future.delayed(Duration(seconds: 2));
        context.pushReplacementNamed(RouterPath.tab);
      } on PostgrestException catch (error) {
        logger.e(error.message);
        state = state.copyWith(loginStatus: error.message);
      } finally {
        loading.state = false;
      }
    } else {
      state = state.copyWith(loginStatus: '必要な情報が入力されていません');
    }
  }
}
