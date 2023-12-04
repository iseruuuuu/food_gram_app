import 'package:flutter/cupertino.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/screen/edit/edit_state.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final data = await supabase
        .from('users')
        .select<Map<String, dynamic>>()
        .eq('user_id', userId)
        .single();
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
    final user = supabase.auth.currentUser;
    final updates = {
      'name': nameTextController.text,
      'user_name': useNameTextController.text,
      'self_introduce': selfIntroduceTextController.text,
      'image': 'assets/icon/icon${state.number}.png',
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      await supabase.from('users').update(updates).match({'user_id': user!.id});
      return true;
    } on PostgrestException catch (error) {
      logger.e(error.message);
      state = state.copyWith(status: error.message);
      return false;
    } finally {
      loading.state = false;
    }
  }

  void selectIcon(int number) {
    state = state.copyWith(number: number);
  }
}
