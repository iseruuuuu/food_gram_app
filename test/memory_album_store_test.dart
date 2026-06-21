import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_gram_app/core/model/memory_album.dart';

void main() {
  MemoryAlbum validAlbum({String id = 'mem_1'}) {
    return MemoryAlbum(
      id: id,
      title: 'Cafe tour',
      description: 'memo',
      postIds: const [1, 2],
      createdAt: DateTime.parse('2024-01-01T00:00:00.000'),
      updatedAt: DateTime.parse('2024-01-02T00:00:00.000'),
    );
  }

  test('fromJsonString keeps valid albums when one entry is malformed', () {
    final raw = jsonEncode({
      'v': 1,
      'albums': [
        validAlbum(id: 'mem_ok').toJson(),
        {'id': 'mem_bad', 'title': 'broken'},
        validAlbum(id: 'mem_ok2').toJson(),
      ],
    });

    final store = MemoryAlbumStore.fromJsonString(raw);

    expect(store.albums.length, 2);
    expect(store.albums.map((a) => a.id), ['mem_ok', 'mem_ok2']);
  });

  test('fromJsonString returns empty store for invalid top-level json', () {
    final store = MemoryAlbumStore.fromJsonString('{not json');

    expect(store.albums, isEmpty);
  });

  test('fromJsonString returns empty store for empty input', () {
    expect(MemoryAlbumStore.fromJsonString('').albums, isEmpty);
  });

  test('tryFromJson returns null for invalid album json', () {
    expect(MemoryAlbum.tryFromJson({'id': 'x'}), isNull);
    expect(MemoryAlbum.tryFromJson('not a map'), isNull);
  });

  test('MemoryAlbumPostIdsKey compares by value not identity', () {
    final a = MemoryAlbumPostIdsKey.from(const [1, 2, 3]);
    final b = MemoryAlbumPostIdsKey.from(const [1, 2, 3]);
    final c = MemoryAlbumPostIdsKey.from(const [3, 2, 1]);

    expect(a, equals(b));
    expect(a, isNot(equals(c)));
    expect(a.hashCode, equals(b.hashCode));
  });
}
