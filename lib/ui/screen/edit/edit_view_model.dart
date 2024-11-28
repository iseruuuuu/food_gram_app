import 'package:flutter/material.dart';
import 'package:food_gram_app/core/data/supabase/auth/account_service.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/screen/edit/edit_state.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_view_model.g.dart';

@riverpod
class EditViewModel extends _$EditViewModel {
  @override
  EditState build({
    EditState initState = const EditState(),
  }) {
    getProfile();
    return initState;
  }

  final nameTextController = TextEditingController();
  final useNameTextController = TextEditingController();
  final selfIntroduceTextController = TextEditingController();

  Loading get loading => ref.read(loadingProvider.notifier);

  Future<void> getProfile() async {
    await Future.delayed(Duration.zero);
    loading.state = true;
    final userId = supabase.auth.currentUser!.id;
    final data =
        await supabase.from('users').select().eq('user_id', userId).single();
    nameTextController.text = data['name'];
    useNameTextController.text = data['user_name'];
    selfIntroduceTextController.text = data['self_introduce'];
    state = state.copyWith(number: extractNumber(data['image']));
    loading.state = false;
  }

  String extractNumber(String path) {
    final regExp = RegExp(r'\d+');
    final Match? match = regExp.firstMatch(path);
    return match?.group(0) ?? '';
  }

  Future<bool> update() async {
    primaryFocus?.unfocus();
    loading.state = true;
    final result = await ref.read(accountServiceProvider).update(
          nameTextController.text,
          useNameTextController.text,
          selfIntroduceTextController.text,
          state.number,
        );
    result.when(
      success: (_) {
        return true;
      },
      failure: (error) {
        state = state.copyWith(status: error.toString());
        return false;
      },
    );
    loading.state = false;
    return true;
  }

  void selectIcon(int number) {
    state = state.copyWith(number: number);
  }
}
