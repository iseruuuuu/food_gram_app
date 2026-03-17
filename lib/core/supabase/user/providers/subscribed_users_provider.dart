import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'subscribed_users_provider.g.dart';

/// サブスク登録ユーザーのIDを取得するProvider
@riverpod
class SubscribedUsers extends _$SubscribedUsers {
  SupabaseClient get supabase => ref.read(supabaseProvider);

  @override
  Future<List<String>> build() async {
    return _getSubscribedUserIds();
  }

  /// サブスク登録しているユーザーIDのリストを取得
  Future<List<String>> _getSubscribedUserIds() async {
    final response =
        await supabase.from('users').select('user_id').eq('is_subscribe', true);
    return (response as List<dynamic>)
        .map((user) => (user as Map<String, dynamic>)['user_id'] as String)
        .toList();
  }
}

/// 指定した userId がサブスクユーザーに含まれるかどうか。
/// 行単位で watch することで、サブスク一覧更新時に該当行だけ再ビルドされる。
@riverpod
bool isSubscribed(Ref ref, String? userId) {
  final subscribed = ref.watch(subscribedUsersProvider);
  return subscribed.when(
    data: (list) => userId != null && list.contains(userId),
    loading: () => false,
    error: (_, __) => false,
  );
}
