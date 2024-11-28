import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/env.dart';
import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'delete_service.g.dart';

@riverpod
DeleteService deleteService(DeleteServiceRef ref) => DeleteService();

class DeleteService {
  DeleteService();

  final user = supabase.auth.currentUser?.id;

  Future<Result<void, Exception>> delete(Posts posts) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        return Failure(Exception('User not logged in'));
      }

      /// 自分の投稿またはマスターアカウントのみ削除可能
      final isMaster = currentUser.id == Env.masterAccount;
      final postOwner = posts.userId;
      if (postOwner != currentUser.id && !isMaster) {
        return Failure(Exception('Not authorized to delete this post'));
      }
      final deleteImage = posts.foodImage.substring(1);
      await supabase.storage.from('food').remove([deleteImage]);
      await supabase.from('posts').delete().eq('id', posts.id);
      return const Success(null);
    } on PostgrestException catch (error) {
      logger.e(error.message);
      return Failure(error);
    }
  }
}
