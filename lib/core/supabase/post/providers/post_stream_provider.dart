import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_stream_provider.g.dart';

final _postsStreamLog = Logger();

/// Realtime が一瞬切れただけで [StreamProvider] が error になりエラー画面に飛ぶのを防ぐ。
/// 失敗時は指数バックオフで購読し直し、Riverpod にはエラーを流さない（直前の data は維持されやすい）。
Stream<List<Posts>> _postsStreamWithReconnect({
  required String categoryName,
  required Stream<List<Posts>> Function() createStream,
}) async* {
  const initialBackoff = Duration(seconds: 1);
  const maxBackoff = Duration(seconds: 30);
  var backoff = initialBackoff;
  while (true) {
    try {
      await for (final posts in createStream()) {
        backoff = initialBackoff;
        yield posts;
      }
      return;
    } on Object catch (err, st) {
      _postsStreamLog.e(
        'postsStream error (category: "$categoryName"), '
        'reconnecting in ${backoff.inSeconds}s',
        error: err,
        stackTrace: st,
      );
      await Future<void>.delayed(backoff);
      final nextSeconds =
          (backoff.inSeconds * 2).clamp(1, maxBackoff.inSeconds);
      backoff = Duration(seconds: nextSeconds);
    }
  }
}

/// 全取得・カテゴリーごとの取得のためのStreamProvider
@riverpod
Stream<List<Posts>> postsStream(
  Ref ref,
  String categoryName,
) {
  final blockList = ref.watch(blockListProvider).asData?.value ?? [];
  final supabase = ref.read(supabaseProvider);

  Stream<List<Posts>> createMappedStream() {
    final query =
        supabase.from('posts').stream(primaryKey: ['id']).order('created_at');
    return query.asyncMap(
      (events) {
        final mapped = <Posts>[];
        for (final e in events) {
          try {
            mapped.add(Posts.fromJson(e));
          } on Object catch (err, st) {
            _postsStreamLog.w(
              'postsStream: skip invalid post (fromJson failed)',
              error: err,
              stackTrace: st,
            );
          }
        }
        final filtered =
            mapped.where((post) => !blockList.contains(post.userId)).toList();
        if (categoryName.isNotEmpty) {
          final foodEmojis = foodCategory[categoryName];
          if (foodEmojis == null) {
            _postsStreamLog.w(
              'Unknown category passed to postsStream: "$categoryName". '
              'No posts will match.',
            );
          }
          final emojis = foodEmojis ?? <String>[];
          final result =
              filtered.where((post) => emojis.contains(post.foodTag)).toList();
          return result;
        }
        return filtered;
      },
    );
  }

  return _postsStreamWithReconnect(
    categoryName: categoryName,
    createStream: createMappedStream,
  );
}

/// 自分の投稿の取得のためのStreamProvider
@riverpod
Stream<List<Posts>> myPostStream(Ref ref) {
  final supabase = ref.read(supabaseProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const Stream<List<Posts>>.empty();
  }
  return supabase
      .from('posts')
      .stream(primaryKey: ['id'])
      .eq('user_id', user)
      .order('created_at')
      .map((events) => events.map(Posts.fromJson).toList());
}
