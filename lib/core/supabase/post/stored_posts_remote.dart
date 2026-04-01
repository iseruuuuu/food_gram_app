import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 保存した投稿 ID 列から `posts` 行を取得する（メモリキャッシュ付き）。
///
/// `FetchPostService.getStoredPosts` と **同一のキャッシュキー・クエリ**を使う。
/// 保存一覧の ViewModel からは **AutoDispose の Repository / Service を経由せず**
/// `supabaseProvider` とこの関数を直接使う（await 中にプロバイダが破棄されるのを避ける）。
Future<List<Map<String, dynamic>>> fetchStoredPostRowsForIds(
  SupabaseClient supabase,
  List<String> postIds,
) async {
  if (postIds.isEmpty) {
    return [];
  }
  final intIds =
      postIds.map(int.tryParse).whereType<int>().toList(growable: false);
  if (intIds.isEmpty) {
    return [];
  }
  final sortedIds = List<int>.from(intIds)..sort();
  // 表示順は呼び出し側の ID 列で決める。.order は通知取得と同形のクエリに寄せる。
  return CacheManager().get<List<Map<String, dynamic>>>(
    key: 'saved_posts_${sortedIds.join('_')}',
    fetcher: () async {
      final rows =
          await supabase.from('posts').select().inFilter('id', sortedIds);
      final out = <Map<String, dynamic>>[];
      for (final row in rows) {
        out.add(Map<String, dynamic>.from(row as Map));
      }
      return out;
    },
    duration: const Duration(minutes: 5),
  );
}
