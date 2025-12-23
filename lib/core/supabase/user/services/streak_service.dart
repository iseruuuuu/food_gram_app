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

  /// ストリークを更新し、新しいストリーク週数を返す
  /// 戻り値: (新しいストリーク週数, ストリークが更新されたか)
  Future<({int newStreakWeeks, bool isUpdated})> updateStreak() async {
    if (_currentUserId == null) {
      logger.w('User is not logged in');
      return (newStreakWeeks: 0, isUpdated: false);
    }

    try {
      // 現在のユーザー情報を取得
      final userData = await supabase
          .from('users')
          .select('last_post_date, streak_weeks')
          .eq('user_id', _currentUserId!)
          .single();

      final lastPostDateStr = userData['last_post_date'] as String?;
      final currentStreakWeeks = (userData['streak_weeks'] as int?) ?? 0;
      final now = DateTime.now();

      int newStreakWeeks;
      bool isUpdated;

      if (lastPostDateStr == null) {
        // 初回投稿
        newStreakWeeks = 1;
        isUpdated = true;
      } else {
        final lastPostDate = DateTime.parse(lastPostDateStr);
        final daysDifference = now.difference(lastPostDate).inDays;

        if (daysDifference < 7) {
          // 1週間以内：ストリークは更新しない
          newStreakWeeks = currentStreakWeeks;
          isUpdated = false;
        } else if (daysDifference >= 7 && daysDifference <= 14) {
          // 1週間後〜2週間以内：ストリークを継続
          newStreakWeeks = currentStreakWeeks + 1;
          isUpdated = true;
        } else {
          // 2週間以上経過：ストリークをリセット
          newStreakWeeks = 1;
          isUpdated = true;
        }
      }

      // データベースを更新
      if (isUpdated) {
        await supabase.from('users').update({
          'last_post_date': now.toIso8601String(),
          'streak_weeks': newStreakWeeks,
        }).eq('user_id', _currentUserId!);
      }

      return (newStreakWeeks: newStreakWeeks, isUpdated: isUpdated);
    } on PostgrestException catch (e) {
      logger.e('Failed to update streak: ${e.message}');
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
