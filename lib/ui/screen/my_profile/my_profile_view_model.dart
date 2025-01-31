import 'package:food_gram_app/core/data/supabase/service/posts_service.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/user/repository/user_repository.dart';
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
      final results = await Future.wait([
        ref.read(userRepositoryProvider.notifier).getCurrentUser(),
        ref.read(userRepositoryProvider.notifier).getCurrentUserPostCount(),
      ]);
      final heartAmount = await ref.read(postsServiceProvider).getHeartAmount();
      final userResult = results[0] as Result<Users, Exception>;
      final postCountResult = results[1] as Result<int, Exception>;
      userResult.when(
        success: (users) => postCountResult.when(
          success: (length) => state = MyProfileState.data(
            users: users,
            length: length,
            heartAmount: heartAmount,
          ),
          failure: (_) => state = MyProfileStateError(),
        ),
        failure: (_) => state = MyProfileStateError(),
      );
    } on Exception catch (error) {
      logger.e(error);
      state = MyProfileStateError();
    }
  }
}
