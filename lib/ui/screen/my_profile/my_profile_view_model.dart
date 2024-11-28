import 'package:food_gram_app/core/data/supabase/service/posts_service.dart';
import 'package:food_gram_app/core/data/supabase/service/users_service.dart';
import 'package:food_gram_app/core/model/users.dart';
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
      final users = await ref.read(usersServiceProvider).getUsers();
      final length = await ref.read(usersServiceProvider).getLength();
      final heartAmount = await ref.read(postsServiceProvider).getHeartAmount();
      state = MyProfileState.data(
        users: Users.fromJson(users),
        length: length,
        heartAmount: heartAmount,
      );
    } on Exception catch (error) {
      logger.e(error);
      state = MyProfileStateError();
    }
  }
}
