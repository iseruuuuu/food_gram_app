import 'package:flutter/material.dart';
import 'package:food_gram_app/provider/loading.dart';
import 'package:food_gram_app/screen/authentication/new_account_state.dart';
import 'package:food_gram_app/screen/tab/tab_screen.dart';
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

  final supabase = Supabase.instance.client;
  final nameTextController = TextEditingController();
  final userNameTextController = TextEditingController();

  Future<void> setUsers(BuildContext context) async {
    state = state.copyWith(loginStatus: '');
    if (nameTextController.text.isNotEmpty &&
        userNameTextController.text.isNotEmpty) {
      loading.state = true;
      final name = nameTextController.text.trim();
      final userName = userNameTextController.text.trim();
      final updates = {
        'name': name,
        'user_name': userName,
        'self_introduce': '',
        'image': 'assets/image/food.png',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      try {
        await supabase.from('users').insert(updates);
        state = state.copyWith(loginStatus: 'アカウントの登録が完了しました');
        await Future.delayed(Duration(seconds: 2));
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TabScreen(),
          ),
        );
      } on PostgrestException catch (error) {
        state = state.copyWith(loginStatus: error.message);
        print(error);
      } finally {
        loading.state = false;
      }
    } else {
      state = state.copyWith(loginStatus: '必要な情報が入力されていません');
    }
  }
}
