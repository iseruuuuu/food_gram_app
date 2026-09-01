import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/user/friend_result.dart';
import 'package:food_gram_app/core/supabase/user/services/friend_service.dart';
import 'package:food_gram_app/core/supabase/user/services/user_service.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'friend_repository.g.dart';

@riverpod
class FriendRepository extends _$FriendRepository {
  @override
  Future<void> build() async {}

  final logger = Logger();

  FriendService get _friendService => ref.read(friendServiceProvider.notifier);
  UserService get _userService => ref.read(userServiceProvider.notifier);

  /// ローカル保存しているフレンドの user_id 一覧
  Future<List<String>> getFriendUserIds() async {
    try {
      return await _friendService.getFriendUserIds();
    } on Exception catch (e) {
      logger.e('Unexpected error fetching friend ids: $e');
      rethrow;
    }
  }

  /// friend_code からフレンドをローカルに登録する
  Future<AddFriendResult> addFriendByCode(String rawCode) async {
    final currentUserId = ref.read(currentUserProvider);
    if (currentUserId == null) {
      return AddFriendResult.failed;
    }

    final code = _friendService.normalizeFriendCode(rawCode);
    if (code.isEmpty) {
      return AddFriendResult.emptyCode;
    }

    try {
      final currentUserJson = await _userService.getCurrentUser();
      final currentUser = Users.fromJson(currentUserJson);
      final myCode = _friendService.normalizeFriendCode(currentUser.friendCode);
      if (myCode.isNotEmpty && myCode == code) {
        return AddFriendResult.self;
      }

      final found = await _friendService.findUserByFriendCode(rawCode);
      if (found == null) {
        return AddFriendResult.notFound;
      }

      final target = Users.fromJson(found);
      if (target.userId == currentUserId) {
        return AddFriendResult.self;
      }

      final added = await _friendService.insertFriend(
        friendUserId: target.userId,
      );
      if (!added) {
        return AddFriendResult.alreadyFriend;
      }
      return AddFriendResult.success;
    } on PostgrestException catch (e) {
      logger.e('Failed to add friend: ${e.message}');
      return AddFriendResult.failed;
    } on Exception catch (e) {
      logger.e('Unexpected error adding friend: $e');
      return AddFriendResult.failed;
    }
  }
}
