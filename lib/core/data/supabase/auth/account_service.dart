import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'account_service.g.dart';

@riverpod
AccountService accountService(AccountServiceRef ref) => AccountService();

class AccountService {
  AccountService();

  Future<Result<void, Exception>> createUsers({
    required String name,
    required String userName,
    required int image,
  }) async {
    final updates = {
      'name': name,
      'user_name': userName,
      'self_introduce': '',
      'image': 'assets/icon/icon$image.png',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'exchanged_point': 0,
    };
    try {
      await supabase.from('users').insert(updates);
      await Future.delayed(Duration(seconds: 1));
      return const Success(null);
    } on PostgrestException catch (error) {
      logger.e(error.message);
      return Failure(error);
    }
  }

  Future<Result<void, Exception>> update(
    String name,
    String userName,
    String selfIntroduce,
    String image,
  ) async {
    final user = supabase.auth.currentUser;
    final updates = {
      'name': name,
      'user_name': userName,
      'self_introduce': selfIntroduce,
      'image': 'assets/icon/icon$image.png',
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      await supabase.from('users').update(updates).match({'user_id': user!.id});
      await Future.delayed(Duration(seconds: 1));
      return const Success(null);
    } on PostgrestException catch (error) {
      logger.e(error.message);
      return Failure(error);
    }
  }
}
