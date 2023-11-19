import 'package:food_gram_app/screen/my_profile/my_profile_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'my_profile_view_model.g.dart';

@riverpod
class MyProfileViewModel extends _$MyProfileViewModel {
  @override
  MyProfileState build({
    MyProfileState initState = const MyProfileState(
      name: '',
      userName: '',
      selfIntroduce: '',
      image: 'assets/icon/icon0.png',
    ),
  }) {
    getProfile();
    return initState;
  }

  final supabase = Supabase.instance.client;

  Future<void> getProfile() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('users')
        .select<Map<String, dynamic>>()
        .eq('user_id', userId)
        .single();
    state = state.copyWith(
      name: data['name'],
      userName: data['user_name'],
      selfIntroduce: data['self_introduce'],
      image: data['image'],
    );
  }
}
