import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/user/repository/friend_repository.dart';

/// 現在ユーザーが登録しているフレンドの user_id 一覧。
/// Timeline のフレンド絞り込みで使い、keepAlive 相当（autoDispose しない）で
/// タブ切替のたびに再取得しない。
final friendUserIdsProvider = FutureProvider<List<String>>((ref) async {
  final userId = ref.watch(currentUserProvider);
  if (userId == null) {
    return const <String>[];
  }
  return ref.read(friendRepositoryProvider.notifier).getFriendUserIds();
});
