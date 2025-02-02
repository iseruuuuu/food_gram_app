import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/core/supabase/user/repository/user_repository.dart';
import 'package:food_gram_app/ui/screen/profile/profile_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_view_model.g.dart';

@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  @override
  ProfileState build(
    String userId, {
    ProfileState initState = const ProfileState(),
  }) {
    getData(userId);
    return initState;
  }

  Future<void> getData(String userId) async {
    final length = await ref
        .read(userRepositoryProvider.notifier)
        .getOtherUserPostCount(userId);
    await length.whenOrNull(
      success: (length) async {
        final heartAmountResult = await ref
            .read(postRepositoryProvider.notifier)
            .getOtherHeartAmount(userId);
        heartAmountResult.whenOrNull(
          success: (heartAmount) {
            state = state.copyWith(
              length: length,
              heartAmount: heartAmount,
            );
          },
        );
      },
    );
  }
}
