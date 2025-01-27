import 'package:food_gram_app/core/data/supabase/service/posts_service.dart';
import 'package:food_gram_app/core/data/supabase/service/users_service.dart';
import 'package:food_gram_app/ui/screen/profile/profile_ui_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileProvider extends _$ProfileProvider {
  @override
  ProfileUiState build(
    String userId, {
    ProfileUiState initState = const ProfileUiState(),
  }) {
    getData(userId);
    return initState;
  }

  Future<void> getData(String userId) async {
    final length = await ref.read(usersServiceProvider).getOtherLength(userId);
    final heartAmount =
        await ref.read(postsServiceProvider).getOtherHeartAmount(userId);
    state = state.copyWith(length: length, heartAmount: heartAmount);
  }
}
