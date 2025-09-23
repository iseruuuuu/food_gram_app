import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'delete_service.g.dart';

@riverpod
class DeleteService extends _$DeleteService {
  final logger = Logger();

  SupabaseClient get supabase => ref.read(supabaseProvider);

  @override
  Future<void> build() async {}

  /// 投稿を削除（データ処理）
  Future<Result<void, Exception>> deletePost(Posts post) async {
    try {
      await _deletePostImage(post.foodImage);
      await _deletePostData(post.id);
      return const Success(null);
    } on PostgrestException catch (e) {
      logger.e('Failed to delete post: ${e.message}');
      return Failure(e);
    } on StorageException catch (e) {
      logger.e('Failed to delete image: ${e.message}');
      return Failure(e);
    }
  }

  /// 投稿画像を削除
  Future<void> _deletePostImage(String foodImage) async {
    /// 先頭の'/'を削除し、二重スラッシュを単一スラッシュに置換
    final imagePath = foodImage.substring(1).replaceAll('//', '/');
    await supabase.storage.from('food').remove([imagePath]);
    //TODO おそらく、管理者が消そうとすると、ストレージの削除ができていない気がする
    //TODO 理由としては、Policiesの問題
  }

  /// 投稿データを削除
  Future<void> _deletePostData(int postId) async {
    await supabase.from('posts').delete().eq('id', postId);
  }
}
