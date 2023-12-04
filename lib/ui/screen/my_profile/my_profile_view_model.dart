import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/screen/my_profile/my_profile_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_profile_view_model.g.dart';

@riverpod
class MyProfileViewModel extends _$MyProfileViewModel {
  @override
  MyProfileState build({
    MyProfileState initState = const MyProfileStateLoading(),
  }) {
    getData();
    return initState;
  }

  Future<void> getData() async {
    state = const MyProfileStateLoading();
    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('users')
          .select<Map<String, dynamic>>()
          .eq('user_id', userId)
          .single();
      final response =
          await supabase.from('posts').select().eq('user_id', userId).execute();
      final post = response.data as List<dynamic>;
      state = MyProfileState.data(
        name: data['name'],
        userName: data['user_name'],
        selfIntroduce: data['self_introduce'],
        image: data['image'],
        length: post.length,
      );
    } on Exception catch (_) {
      state = MyProfileStateError();
    }
  }
}
