import 'package:flutter_test/flutter_test.dart';
import 'package:food_gram_app/core/model/post_count_ranking.dart';

void main() {
  const alice = PublicPostCount(
    userId: 'a',
    name: 'Alice',
    image: 'a.png',
    postCount: 3,
  );
  const bob = PublicPostCount(
    userId: 'b',
    name: 'Bob',
    image: 'b.png',
    postCount: 5,
  );
  const cara = PublicPostCount(
    userId: 'c',
    name: 'Cara',
    image: 'c.png',
    postCount: 5,
  );

  group('rankPublicPostCounts', () {
    test('orders by public post count and shares ties', () {
      final ranked = rankPublicPostCounts([alice, cara, bob]);

      expect(ranked.map((e) => e.userId), ['b', 'c', 'a']);
      expect(ranked.map((e) => e.rank), [1, 1, 3]);
    });

    test('drops blocked users before assigning ranks', () {
      final ranked = rankPublicPostCounts(
        [alice, bob],
        excludedUserIds: {'b'},
      );

      expect(ranked, hasLength(1));
      expect(ranked.single.userId, 'a');
      expect(ranked.single.rank, 1);
    });

    test('ignores empty counts', () {
      final ranked = rankPublicPostCounts(const []);

      expect(ranked, isEmpty);
    });
  });
}
