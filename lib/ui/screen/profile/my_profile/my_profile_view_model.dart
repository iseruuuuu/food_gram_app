import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/post/repository/fetch_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/repository/user_repository.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/my_profile_state.dart';
import 'package:logger/logger.dart';
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

  final logger = Logger();

  Future<void> getData() async {
    state = const MyProfileStateLoading();
    try {
      final results = await Future.wait([
        ref.read(userRepositoryProvider.notifier).getCurrentUser(),
        ref.read(userRepositoryProvider.notifier).getCurrentUserPostCount(),
        ref.read(fetchPostRepositoryProvider.notifier).getHeartAmount(),
      ]);

      final userResult = results[0] as Result<Users, Exception>;
      final postCountResult = results[1] as Result<int, Exception>;
      final heartAmountResult = results[2] as Result<int, Exception>;

      userResult.when(
        success: (users) => postCountResult.when(
          success: (length) => heartAmountResult.when(
            success: (heartAmount) => state = MyProfileState.data(
              users: users,
              length: length,
              heartAmount: heartAmount,
            ),
            failure: (_) => state = const MyProfileStateError(),
          ),
          failure: (_) => state = const MyProfileStateError(),
        ),
        failure: (_) => state = const MyProfileStateError(),
      );
    } on Exception catch (error) {
      logger.e(error);
      state = const MyProfileStateError();
    }
  }

  void setUser(Users user) {
    state.whenOrNull(
      data: (_, length, heartAmount) {
        state = MyProfileState.data(
          users: user,
          length: length,
          heartAmount: heartAmount,
        );
      },
    );
  }
}
