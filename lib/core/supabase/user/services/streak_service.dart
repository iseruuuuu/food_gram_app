import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'streak_service.g.dart';

@riverpod
class StreakService extends _$StreakService {
  final logger = Logger();

  String? get _currentUserId => ref.read(currentUserProvider);
  SupabaseClient get supabase => ref.read(supabaseProvider);

  @override
  Future<void> build() async {}

  /// ストリークを更新し、新しいストリーク週数を返す（Edge Function 経由）
  /// 戻り値: (新しいストリーク週数, ストリークが更新されたか)
  Future<({int newStreakWeeks, bool isUpdated})> updateStreak() async {
    if (_currentUserId == null) {
      logger.w('User is not logged in');
      return (newStreakWeeks: 0, isUpdated: false);
    }

    try {
      final res = await supabase.functions.invoke(
        'streak-update',
        body: <String, dynamic>{},
      );
      final data = res.data;
      if (data is! Map<String, dynamic> || data['ok'] != true) {
        final errorMsg = data is Map<String, dynamic>
            ? (data['error']?.toString() ?? 'status: ${res.status}')
            : 'status: ${res.status}';
        logger.e('Failed to update streak via function: $errorMsg');
        return (newStreakWeeks: 0, isUpdated: false);
      }
      final newStreakWeeks = (data['new_streak_weeks'] as num?)?.toInt() ?? 0;
      final isUpdated = data['is_updated'] as bool? ?? false;
      return (newStreakWeeks: newStreakWeeks, isUpdated: isUpdated);
    } on Exception catch (e) {
      logger.e('Failed to update streak: $e');
      return (newStreakWeeks: 0, isUpdated: false);
    }
  }

  /// 現在のストリーク週数を取得
  Future<int> getCurrentStreakWeeks() async {
    if (_currentUserId == null) {
      return 0;
    }

    try {
      final userData = await supabase
          .from('users')
          .select('streak_weeks')
          .eq('user_id', _currentUserId!)
          .single();

      return (userData['streak_weeks'] as int?) ?? 0;
    } on PostgrestException catch (e) {
      logger.e('Failed to get streak weeks: ${e.message}');
      return 0;
    }
  }
}
