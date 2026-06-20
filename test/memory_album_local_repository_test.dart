import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_gram_app/core/model/memory_album.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/repository/memory_album/memory_album_local_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('create rejects empty post ids', () async {
    final repo = MemoryAlbumLocalRepository(random: Random(0));
    final result = await repo.create(
      title: 'Test',
      description: 'desc',
      postIds: const [],
    );
    expect(
      result,
      const Failure<MemoryAlbum, MemoryAlbumError>(
        MemoryAlbumError.emptyPostIds,
      ),
    );
  });

  test('create and load album', () async {
    final repo = MemoryAlbumLocalRepository(random: Random(0));
    final created = await repo.create(
      title: 'Cafe tour',
      description: 'memo',
      postIds: const [1, 2, 3],
    );
    expect(created, isA<Success<MemoryAlbum, MemoryAlbumError>>());
    final album = (created as Success<MemoryAlbum, MemoryAlbumError>).value;
    expect(album.title, 'Cafe tour');
    expect(album.postIds, [1, 2, 3]);
    expect(album.coverPostId, 1);

    final all = await repo.getAll();
    expect(all.length, 1);
    expect(all.first.id, album.id);
  });

  test('delete removes album', () async {
    final repo = MemoryAlbumLocalRepository(random: Random(0));
    final created = await repo.create(
      title: 'Trip',
      description: '',
      postIds: const [10],
    );
    final id = (created as Success<MemoryAlbum, MemoryAlbumError>).value.id;
    await repo.delete(id);
    expect(await repo.getById(id), isNull);
  });
}
