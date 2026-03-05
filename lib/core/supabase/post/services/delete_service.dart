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

  /// 投稿を削除（Edge Function 経由）
  Future<Result<void, Exception>> deletePost(Posts post) async {
    try {
      final res = await supabase.functions.invoke(
        'post-delete',
        body: {'post_id': post.id},
      );
      final data = res.data;
      final ok = data is Map<String, dynamic> && data['ok'] == true;
      if (ok) {
        return const Success(null);
      }
      final errorMsg = data is Map<String, dynamic>
          ? (data['error']?.toString() ?? 'status: ${res.status}')
          : 'status: ${res.status}';
      logger.e('Failed to delete post via function: $errorMsg');
      return Failure(Exception(errorMsg));
    } on Exception catch (e) {
      logger.e('Failed to delete post via function: $e');
      return Failure(e);
    }
  }
}
