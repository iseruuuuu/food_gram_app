import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';

/// サブスク登録ユーザーのIDを取得するProvider
final subscribedUsersProvider = FutureProvider<List<String>>((ref) async {
  final supabase = ref.read(supabaseProvider);
  final response =
      await supabase.from('users').select('user_id').eq('is_subscribe', true);
  return (response as List<dynamic>)
      .map((user) => (user as Map<String, dynamic>)['user_id'] as String)
      .toList();
});

/// 指定した userId がサブスクユーザーに含まれるかどうか。
/// 行単位で watch することで、サブスク一覧更新時に該当行だけ再ビルドされる。
final isSubscribedProvider = Provider.family<bool, String?>((ref, userId) {
  final subscribed = ref.watch(subscribedUsersProvider);
  return subscribed.when(
    data: (list) => userId != null && list.contains(userId),
    loading: () => false,
    error: (_, __) => false,
  );
});
