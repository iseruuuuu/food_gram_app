import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/user/services/user_service.dart';
import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_repository.g.dart';

@riverpod
class UserRepository extends _$UserRepository {
  @override
  Future<void> build() async {}

  /// 自分のユーザー情報を取得
  Future<Result<Users, Exception>> getCurrentUser() async {
    try {
      final data =
          await ref.read(userServiceProvider.notifier).getCurrentUser();
      return Success(Users.fromJson(data));
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// 他のユーザー情報を取得
  Future<Result<Users, Exception>> getOtherUser(String userId) async {
    try {
      final data =
          await ref.read(userServiceProvider.notifier).getOtherUser(userId);
      return Success(Users.fromJson(data));
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// 現在のユーザーの投稿数を取得
  Future<Result<int, Exception>> getCurrentUserPostCount() async {
    try {
      final count = await ref
          .read(userServiceProvider.notifier)
          .getCurrentUserPostCount();
      return Success(count);
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// 指定したユーザーの投稿数を取得
  Future<Result<int, Exception>> getOtherUserPostCount(String userId) async {
    try {
      final count = await ref
          .read(userServiceProvider.notifier)
          .getOtherUserPostCount(userId);
      return Success(count);
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// 投稿からユーザー情報を取得
  Future<Result<Users, Exception>> getUserFromPost(Posts post) async {
    try {
      final data =
          await ref.read(userServiceProvider.notifier).getUserFromPost(post);
      return Success(Users.fromJson(data));
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }
}
