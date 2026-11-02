import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_service.g.dart';

@Riverpod(keepAlive: true)
class DeleteService extends _$DeleteService {
  final _logger = Logger();

  @override
  Future<void> build() async {}

  /// 投稿を削除（Edge Function 経由）
  Future<Result<void, Exception>> deletePost(Posts post) async {
    try {
      final res = await ref
          .read(supabaseProvider)
          .functions
          .invoke(
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
      _logger.e('Failed to delete post via function: $errorMsg');
      return Failure(Exception(errorMsg));
    } on Exception catch (e) {
      _logger.e('Failed to delete post via function: $e');
      return Failure(e);
    }
  }
}
