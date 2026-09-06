import 'package:flutter_test/flutter_test.dart';
import 'package:food_gram_app/core/model/post_detail_feed.dart';
import 'package:food_gram_app/core/model/posts.dart';

Posts _post(int id, {DateTime? createdAt}) {
  return Posts(
    id: id,
    foodImage: 'user/food.jpg',
    foodName: 'Food $id',
    restaurant: '店',
    comment: '',
    createdAt: createdAt ?? DateTime(2026, 1, id),
    lat: 0,
    lng: 0,
    userId: 'user',
    heart: 0,
    star: 4,
    foodTag: '',
    isAnonymous: false,
  );
}

void main() {
  group('takePostsAround', () {
    test('初期投稿の前後だけを切り出し、上方向の残りを残す', () {
      final posts = List<Posts>.generate(
        8,
        (index) => _post(8 - index),
      );
      final initial = posts[4];
      final result = takePostsAround(
        sortedNewestFirst: posts,
        initial: initial,
        newerLimit: 2,
        olderLimit: 2,
      );

      expect(result.posts.map((post) => post.id), [6, 5, 4, 3, 2]);
      expect(result.hasMoreNewer, isTrue);
      expect(result.hasMoreOlder, isTrue);
    });

    test('先頭の投稿では上方向の追加がない', () {
      final posts = [_post(3), _post(2), _post(1)];
      final result = takePostsAround(
        sortedNewestFirst: posts,
        initial: posts.first,
        newerLimit: 2,
        olderLimit: 2,
      );

      expect(result.posts.map((post) => post.id), [3, 2, 1]);
      expect(result.hasMoreNewer, isFalse);
      expect(result.hasMoreOlder, isFalse);
    });

    test('リストに無い初期投稿を挿入して前後を取る', () {
      final result = takePostsAround(
        sortedNewestFirst: [_post(5), _post(4), _post(2)],
        initial: _post(3),
        newerLimit: 1,
        olderLimit: 1,
      );

      expect(result.posts.map((post) => post.id), [4, 3, 2]);
      expect(result.hasMoreNewer, isTrue);
      expect(result.hasMoreOlder, isFalse);
    });
  });

  group('takeNewerPage / takeOlderPage', () {
    final posts = [_post(5), _post(4), _post(3), _post(2), _post(1)];

    test('上方向はカーソルより新しい投稿を新しい順で返す', () {
      final page = takeNewerPage(
        sortedNewestFirst: posts,
        cursor: _post(3),
        limit: 2,
      );
      expect(page.map((post) => post.id), [5, 4]);
    });

    test('下方向はカーソルより古い投稿を新しい順で返す', () {
      final page = takeOlderPage(
        sortedNewestFirst: posts,
        cursor: _post(3),
        limit: 2,
      );
      expect(page.map((post) => post.id), [2, 1]);
    });
  });

  group('mergePostsNewestFirst', () {
    test('重複を除いて新しい順にマージする', () {
      final merged = mergePostsNewestFirst(
        [_post(3), _post(2)],
        [_post(4), _post(3), _post(1)],
      );
      expect(merged.map((post) => post.id), [4, 3, 2, 1]);
    });
  });
}
