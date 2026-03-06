import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  /// 自分のユーザーのいいね数合計を取得
  Future<Result<int, Exception>> getCurrentUserHeartAmount() async {
    return _handleDatabaseOperation(() async {
      return ref.read(userServiceProvider.notifier).getCurrentUserHeartAmount();
    });
  }

  /// 特定のユーザーのいいね数合計を取得
  Future<Result<int, Exception>> getOtherUserHeartAmount(String userId) async {
    return _handleDatabaseOperation(() async {
      return ref
          .read(userServiceProvider.notifier)
          .getOtherUserHeartAmount(userId);
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

  /// エラーハンドリング用のヘルパーメソッド
  Future<Result<T, Exception>> _handleDatabaseOperation<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Success(result);
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    } on Exception catch (e) {
      logger.e('Unexpected error: $e');
      return Failure(e);
    }
  }
}
