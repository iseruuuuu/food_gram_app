import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/memory_album.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/repository/memory_album/memory_album_local_repository.dart';
import 'package:food_gram_app/core/supabase/post/repository/fetch_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memory_album_view_model.g.dart';

@riverpod
class MemoryAlbumListViewModel extends _$MemoryAlbumListViewModel {
  final _repo = MemoryAlbumLocalRepository();

  @override
  Future<List<MemoryAlbum>> build() async {
    return _repo.getAll();
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteAlbum(String id) async {
    await _repo.delete(id);
    await reload();
  }

  Future<void> reorder(List<MemoryAlbum> albums) async {
    state = AsyncData(albums);
    await _repo.reorderAlbums(albums.map((a) => a.id).toList());
  }

  Future<MemoryAlbumError?> createAlbum({
    required String title,
    required String description,
    required List<int> postIds,
  }) async {
    final isPremium = await ref.read(isSubscribeProvider.future);
    final result = await _repo.create(
      title: title,
      description: description,
      postIds: postIds,
      isPremium: isPremium,
    );
    return result.when(
      success: (_) {
        ref.invalidateSelf();
        return null;
      },
      failure: (error) => error,
    );
  }
}

@riverpod
class MemoryAlbumDetailViewModel extends _$MemoryAlbumDetailViewModel {
  final _repo = MemoryAlbumLocalRepository();

  @override
  Future<MemoryAlbum?> build(String albumId) async {
    return _repo.getById(albumId);
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  Future<MemoryAlbumError?> updateAlbum({
    required String title,
    required String description,
    required List<int> postIds,
  }) async {
    final result = await _repo.update(
      id: albumId,
      title: title,
      description: description,
      postIds: postIds,
    );
    return result.when(
      success: (_) {
        ref.invalidateSelf();
        ref.invalidate(memoryAlbumListViewModelProvider);
        return null;
      },
      failure: (error) => error,
    );
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
