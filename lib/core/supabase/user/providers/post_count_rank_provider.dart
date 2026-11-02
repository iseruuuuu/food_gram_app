import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/user/repository/user_repository.dart';

/// 投稿数に基づく全体ランキング（1始まり）。プロフィール表示対象の userId を family に渡す。
// ignore: specify_nonobvious_property_types
final postCountRankProvider = FutureProvider.family<int, String>(
  (ref, userId) async {
    final result =
        await ref.read(userRepositoryProvider.notifier).getPostCountRank(
              userId,
            );
    return result.when(
      success: (v) => v,
      failure: (e) => throw e,
    );
  },
);
