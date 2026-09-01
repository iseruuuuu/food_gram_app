import 'package:flutter/material.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/supabase/user/friend_result.dart';
import 'package:food_gram_app/core/supabase/user/providers/friend_user_ids_provider.dart';
import 'package:food_gram_app/core/supabase/user/repository/friend_repository.dart';
import 'package:food_gram_app/core/supabase/user/repository/user_repository.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/screen/friend/friend_add_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'friend_add_view_model.g.dart';

@riverpod
class FriendAddViewModel extends _$FriendAddViewModel {
  @override
  FriendAddState build({
    FriendAddState initState = const FriendAddState(),
  }) {
    _loadMyFriendCode();
    return initState;
  }

  Loading get loading => ref.read(loadingProvider.notifier);

  void _logAddFailed() {
    ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
          name: AnalyticsEvent.friendAddFailed,
        );
  }

  Future<void> _loadMyFriendCode() async {
    final result =
        await ref.read(userRepositoryProvider.notifier).getCurrentUser();
    result.when(
      success: (user) {
        state = state.copyWith(
          myFriendCode: user.friendCode,
          isLoadingCode: false,
        );
      },
      failure: (_) {
        state = state.copyWith(isLoadingCode: false);
      },
    );
  }

  /// フレンド追加。成功時 true。
  Future<bool> addFriend(BuildContext context, String rawCode) async {
    final t = Translations.of(context);
    loading.state = true;
    final result = await ref
        .read(friendRepositoryProvider.notifier)
        .addFriendByCode(rawCode);
    loading.state = false;
    if (!context.mounted) {
      return result == AddFriendResult.success;
    }
    switch (result) {
      case AddFriendResult.success:
        ref.invalidate(friendUserIdsProvider);
        ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
              name: AnalyticsEvent.friendAddSuccess,
            );
        SnackBarHelper().openSuccessSnackBar(
          context,
          t.friend.addSuccess,
          '',
        );
        return true;
      case AddFriendResult.notFound:
        _logAddFailed();
        SnackBarHelper().openErrorSnackBar(context, t.friend.notFound, '');
      case AddFriendResult.self:
        _logAddFailed();
        SnackBarHelper().openErrorSnackBar(context, t.friend.cannotAddSelf, '');
      case AddFriendResult.alreadyFriend:
        _logAddFailed();
        SnackBarHelper().openErrorSnackBar(context, t.friend.alreadyFriend, '');
      case AddFriendResult.emptyCode:
        SnackBarHelper().openErrorSnackBar(context, t.friend.emptyCode, '');
      case AddFriendResult.failed:
        _logAddFailed();
        SnackBarHelper().openErrorSnackBar(context, t.friend.addFailed, '');
    }
    return false;
  }
}
