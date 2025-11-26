import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/user/repository/user_repository.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'is_subscribe_provider.g.dart';

/// 現在ログインしているユーザーのサブスクリプション状態を保持するProvider
/// ログイン後に自動的にデータを取得し、アプリ全体でアクセス可能
@Riverpod(keepAlive: true)
class IsSubscribe extends _$IsSubscribe {
  final logger = Logger();

  @override
  Future<bool> build() async {
    // currentUserProviderの変更を監視
    final userId = ref.watch(currentUserProvider);

    // ユーザーがログインしていない場合はfalseを返す
    if (userId == null) {
      return false;
    }

    // サブスクリプション状態を取得
    return _fetchSubscriptionStatus();
  }

  /// サブスクリプション状態を取得
  Future<bool> _fetchSubscriptionStatus() async {
    try {
      final result =
          await ref.read(userRepositoryProvider.notifier).getCurrentUser();
      return result.when(
        success: (user) => user.isSubscribe,
        failure: (error) {
          logger.e('Failed to fetch current user data: $error');
          return false;
        },
      );
    } on Exception catch (e) {
      logger.e('Unexpected error fetching user data: $e');
      return false;
    }
  }

  /// サブスクリプション状態を再取得（更新時などに使用）
  Future<void> refresh() async {
    state = const AsyncValue<bool>.loading();
    state = await AsyncValue.guard(_fetchSubscriptionStatus);
  }

  /// サブスクリプション状態をクリア（ログアウト時などに使用）
  void clear() {
    state = const AsyncValue<bool>.data(false);
  }
}
