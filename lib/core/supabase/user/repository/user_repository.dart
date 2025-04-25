import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/user/services/user_service.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_repository.g.dart';

@riverpod
class UserRepository extends _$UserRepository {
  @override
  Future<void> build() async {}

  final logger = Logger();

  /// 自分のユーザー情報を取得
  Future<Result<Users, Exception>> getCurrentUser() async {
    return _handleDatabaseOperation(() async {
      final data =
          await ref.read(userServiceProvider.notifier).getCurrentUser();
      return Users.fromJson(data);
    });
  }

  /// 他のユーザー情報を取得
  Future<Result<Users, Exception>> getOtherUser(String userId) async {
    return _handleDatabaseOperation(() async {
      final data =
          await ref.read(userServiceProvider.notifier).getOtherUser(userId);
      return Users.fromJson(data);
    });
  }

  /// 現在のユーザーの投稿数を取得
  Future<Result<int, Exception>> getCurrentUserPostCount() async {
    return _handleDatabaseOperation(() async {
      return ref.read(userServiceProvider.notifier).getCurrentUserPostCount();
    });
  }

  /// 指定したユーザーの投稿数を取得
  Future<Result<int, Exception>> getOtherUserPostCount(String userId) async {
    return _handleDatabaseOperation(() async {
      return ref
          .read(userServiceProvider.notifier)
          .getOtherUserPostCount(userId);
    });
  }

  /// 投稿からユーザー情報を取得
  Future<Result<Users, Exception>> getUserFromPost(Posts post) async {
    return _handleDatabaseOperation(() async {
      final data =
          await ref.read(userServiceProvider.notifier).getUserFromPost(post);
      return Users.fromJson(data);
    });
  }

  /// 共通のエラーハンドリングラッパー
  Future<Result<T, Exception>> _handleDatabaseOperation<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Success(result);
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }
}
