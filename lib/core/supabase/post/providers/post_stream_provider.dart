import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_stream_provider.g.dart';

final _postsStreamLog = Logger();

/// Realtime 再購読中も直前の投稿を即座に出せるよう、メモリに保持する。
List<Posts>? _cachedAllPosts;

/// Realtime が一瞬切れただけで [StreamProvider] が error になりエラー画面に飛ぶのを防ぐ。
/// 失敗時は指数バックオフで購読し直し、Riverpod にはエラーを流さない（直前の data は維持されやすい）。
Stream<List<Posts>> _postsStreamWithReconnect({
  required String label,
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
      _postsStreamLog.w(
        'postsStream completed ($label), '
        'reconnecting in ${backoff.inSeconds}s',
      );
      await Future<void>.delayed(backoff);
    } on Object catch (err, st) {
      _postsStreamLog.e(
        'postsStream error ($label), '
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

/// カテゴリ名で投稿を絞り込む（空文字は全件）。
///
/// Realtime 購読は [postsStream] の1本に集約し、切替時はここだけ使う。
List<Posts> filterPostsByCategory(List<Posts> posts, String categoryName) {
  if (categoryName.isEmpty) {
    return posts;
  }
  final categoryTagIds = foodCategory[categoryName];
  if (categoryTagIds == null) {
    _postsStreamLog.w(
      'Unknown category passed to filterPostsByCategory: "$categoryName". '
      'No posts will match.',
    );
  }
  final tagIds = categoryTagIds ?? <String>[];
  return posts.where((post) {
    final postTags = parseFoodTagIds(post.foodTag);
    return postTags.any(tagIds.contains);
  }).toList();
}

/// ブロックユーザーの投稿を除外する。
List<Posts> filterBlockedPosts(List<Posts> posts, List<String> blockList) {
  if (blockList.isEmpty) {
    return posts;
  }
  return posts.where((post) => !blockList.contains(post.userId)).toList();
}

/// 自分 + 登録済みフレンドの投稿だけ残す。
List<Posts> filterFriendPosts({
  required List<Posts> posts,
  required List<String> friendUserIds,
  required String? currentUserId,
}) {
  final allowed = <String>{
    ...friendUserIds,
    if (currentUserId != null && currentUserId.isNotEmpty) currentUserId,
  };
  if (allowed.isEmpty) {
    return const [];
  }
  return posts.where((post) => allowed.contains(post.userId)).toList();
}

/// 全投稿の Realtime Stream。
///
/// カテゴリ切替・ブロックリスト更新のたびに購読を張り直さないよう、
/// パラメータなし + keepAlive。ブロック除外は [filterBlockedPosts] で行う。
/// 再購読時は直前の一覧を先に yield し、ローディングで画面を消さない。
@Riverpod(keepAlive: true)
Stream<List<Posts>> postsStream(Ref ref) async* {
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
        return mapped;
      },
    );
  }

  final cached = _cachedAllPosts;
  if (cached != null) {
    yield cached;
  }

  yield* _postsStreamWithReconnect(
    label: 'all_posts',
    createStream: createMappedStream,
  ).map((posts) {
    _cachedAllPosts = posts;
    return posts;
  });
}

/// 自分の投稿の取得のためのStreamProvider
@riverpod
Stream<List<Posts>> myPostStream(Ref ref) {
  final supabase = ref.read(supabaseProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const Stream<List<Posts>>.empty();
  }

  Stream<List<Posts>> createMappedStream() {
    return supabase
        .from('posts')
        .stream(primaryKey: ['id'])
        .eq('user_id', user)
        .order('created_at')
        .map((events) {
          final mapped = <Posts>[];
          for (final e in events) {
            try {
              mapped.add(Posts.fromJson(e));
            } on Object catch (err, st) {
              _postsStreamLog.w(
                'myPostStream: skip invalid post (fromJson failed)',
                error: err,
                stackTrace: st,
              );
            }
          }
          return mapped;
        });
  }

  return _postsStreamWithReconnect(
    label: 'my_posts',
    createStream: createMappedStream,
  );
}
