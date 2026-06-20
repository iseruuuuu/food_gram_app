import 'dart:math';

import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/memory_album.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/repository/memory_album/memory_album_repository.dart';

class MemoryAlbumLocalRepository implements MemoryAlbumRepository {
  MemoryAlbumLocalRepository({Random? random}) : _random = random ?? Random();

  final Random _random;
  final _preference = Preference();

  String _newId() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final suffix = _random.nextInt(0x7fffffff);
    return 'mem_${ts}_$suffix';
  }

  Future<MemoryAlbumStore> _load() async {
    final raw = await _preference.getString(PreferenceKey.memoryAlbums);
    return MemoryAlbumStore.fromJsonString(raw);
  }

  Future<void> _save(MemoryAlbumStore store) async {
    await _preference.setString(
      PreferenceKey.memoryAlbums,
      store.toJsonString(),
    );
  }

  @override
  Future<List<MemoryAlbum>> getAll() async {
    final store = await _load();
    return List<MemoryAlbum>.from(store.albums);
  }

  @override
  Future<MemoryAlbum?> getById(String id) async {
    final store = await _load();
    for (final album in store.albums) {
      if (album.id == id) {
        return album;
      }
    }
    return null;
  }

  @override
  Future<Result<MemoryAlbum, MemoryAlbumError>> create({
    required String title,
    required String description,
    required List<int> postIds,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return const Failure(MemoryAlbumError.emptyTitle);
    }
    if (postIds.isEmpty) {
      return const Failure(MemoryAlbumError.emptyPostIds);
    }

    final now = DateTime.now();
    final album = MemoryAlbum(
      id: _newId(),
      title: trimmed,
      description: description.trim(),
      postIds: List<int>.from(postIds),
      createdAt: now,
      updatedAt: now,
    );
    final store = await _load();
    await _save(MemoryAlbumStore(albums: [album, ...store.albums]));
    return Success(album);
  }

  @override
  Future<Result<MemoryAlbum, MemoryAlbumError>> update({
    required String id,
    required String title,
    required String description,
    required List<int> postIds,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return const Failure(MemoryAlbumError.emptyTitle);
    }
    if (postIds.isEmpty) {
      return const Failure(MemoryAlbumError.emptyPostIds);
    }

    final store = await _load();
    final index = store.albums.indexWhere((a) => a.id == id);
    if (index < 0) {
      return const Failure(MemoryAlbumError.albumNotFound);
    }

    final updated = store.albums[index].copyWith(
      title: trimmed,
      description: description.trim(),
      postIds: List<int>.from(postIds),
      updatedAt: DateTime.now(),
    );
    final albums = [...store.albums];
    albums[index] = updated;
    await _save(MemoryAlbumStore(albums: albums));
    return Success(updated);
  }

  @override
  Future<void> delete(String id) async {
    final store = await _load();
    await _save(
      MemoryAlbumStore(
        albums: store.albums.where((a) => a.id != id).toList(),
      ),
    );
  }

  @override
  Future<void> reorderAlbums(List<String> orderedIds) async {
    final store = await _load();
    final byId = {for (final a in store.albums) a.id: a};
    final reordered = <MemoryAlbum>[
      for (final id in orderedIds)
        if (byId.containsKey(id)) byId[id]!,
    ];
    for (final album in store.albums) {
      if (!orderedIds.contains(album.id)) {
        reordered.add(album);
      }
    }
    await _save(MemoryAlbumStore(albums: reordered));
  }
}
