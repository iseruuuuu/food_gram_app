import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'heart_service.g.dart';

@riverpod
class HeartService extends _$HeartService {
  final _logger = Logger();

  SupabaseClient get _supabase => ref.read(supabaseProvider);

  @override
  Future<void> build() async {}

  /// いいねを加算（Edge Function 経由）
  Future<Result<void, Exception>> incrementHeart(int postId) async {
    try {
      final res = await _supabase.functions.invoke(
        'post-heart',
        body: {'action': 'increment', 'post_id': postId},
      );
      final data = res.data;
      final ok = data is Map<String, dynamic> && data['ok'] == true;
      if (ok) {
        return const Success(null);
      }
      final errorMsg = data is Map<String, dynamic>
          ? (data['error']?.toString() ?? 'status: ${res.status}')
          : 'status: ${res.status}';
      return Failure(Exception(errorMsg));
    } on Exception catch (e) {
      _logger.e('incrementHeart failed: $e');
      return Failure(e);
    }
  }

  /// いいねを減算（Edge Function 経由）
  Future<Result<void, Exception>> decrementHeart(int postId) async {
    try {
      final res = await _supabase.functions.invoke(
        'post-heart',
        body: {'action': 'decrement', 'post_id': postId},
      );
      final data = res.data;
      final ok = data is Map<String, dynamic> && data['ok'] == true;
      if (ok) {
        return const Success(null);
      }
      final errorMsg = data is Map<String, dynamic>
          ? (data['error']?.toString() ?? 'status: ${res.status}')
          : 'status: ${res.status}';
      return Failure(Exception(errorMsg));
    } on Exception catch (e) {
      _logger.e('decrementHeart failed: $e');
      return Failure(e);
    }
  }
}
