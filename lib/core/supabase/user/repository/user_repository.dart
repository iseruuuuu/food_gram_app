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

  /// 現在のユーザーの投稿数を取得
  Future<Result<int, Exception>> getCurrentUserPostCount() async {
    return _handleDatabaseOperation(() async {
      return ref.read(userServiceProvider.notifier).getCurrentUserPostCount();
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

  /// 全ユーザー情報を取得
  Future<Result<List<Users>, Exception>> getAllUsers() async {
    return _handleDatabaseOperation(() async {
      final data = await ref.read(userServiceProvider.notifier).getAllUsers();
      return data.map(Users.fromJson).toList();
    });
  }

  /// ユーザー情報と投稿数を含むデータを取得
  Future<Result<List<Map<String, dynamic>>, Exception>>
      getUsersWithPostCount() async {
    return _handleDatabaseOperation(() async {
      return ref.read(userServiceProvider.notifier).getUsersWithPostCount();
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

/// ユーザー検索用のプロバイダー
@riverpod
Future<List<Map<String, dynamic>>> usersWithPostCountProvider(Ref ref) async {
  final result =
      await ref.read(userRepositoryProvider.notifier).getUsersWithPostCount();
  return result.when(
    success: (data) => data,
    failure: (error) => throw Exception(error.toString()),
  );
}
