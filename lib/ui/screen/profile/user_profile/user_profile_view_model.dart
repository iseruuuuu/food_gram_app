import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/ui/screen/profile/user_profile/user_profile_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_profile_view_model.g.dart';

@riverpod
class UserProfileViewModel extends _$UserProfileViewModel {
  @override
  UserProfileState build(
    String userId, {
    UserProfileState initState = const UserProfileState(),
  }) {
    getData(userId);
    return initState;
  }

  Future<void> getData(String userId) async {
    final heartAmountResult = await ref
        .read(postRepositoryProvider.notifier)
        .getOtherHeartAmount(userId);
    heartAmountResult.whenOrNull(
      success: (heartAmount) {
        state = state.copyWith(heartAmount: heartAmount);
      },
    );
  }
}
