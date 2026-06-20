import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/memory_album.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/repository/memory_album/memory_album_repository_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/fetch_post_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memory_album_view_model.g.dart';

@riverpod
class MemoryAlbumListViewModel extends _$MemoryAlbumListViewModel {
  @override
  Future<List<MemoryAlbum>> build() async {
    return ref.read(memoryAlbumRepositoryProvider).getAll();
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteAlbum(String id) async {
    await ref.read(memoryAlbumRepositoryProvider).delete(id);
    await reload();
  }

  Future<void> reorder(List<MemoryAlbum> albums) async {
    state = AsyncData(albums);
    await ref.read(memoryAlbumRepositoryProvider).reorderAlbums(
          albums.map((a) => a.id).toList(),
        );
  }
}

@riverpod
class MemoryAlbumDetailViewModel extends _$MemoryAlbumDetailViewModel {
  @override
  Future<MemoryAlbum?> build(String albumId) async {
    return ref.read(memoryAlbumRepositoryProvider).getById(albumId);
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }
}

@riverpod
Future<List<Posts>> memoryAlbumPosts(
  Ref ref,
  List<int> postIds,
) async {
  if (postIds.isEmpty) {
    return [];
  }
  final idStrings = postIds.map((e) => e.toString()).toList();
  final result = await ref
      .read(fetchPostRepositoryProvider.notifier)
      .getStoredPosts(idStrings);

  return result.when(
    success: (posts) {
      final byId = {for (final p in posts) p.id: p};
      return [
        for (final id in postIds)
          if (byId[id] != null) byId[id]!,
      ];
    },
    failure: (_) => throw Exception('Failed to load memory album posts'),
  );
}
