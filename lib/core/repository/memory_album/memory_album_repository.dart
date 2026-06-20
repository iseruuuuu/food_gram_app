import 'package:food_gram_app/core/model/memory_album.dart';
import 'package:food_gram_app/core/model/result.dart';

abstract class MemoryAlbumRepository {
  Future<List<MemoryAlbum>> getAll();

  Future<MemoryAlbum?> getById(String id);

  Future<Result<MemoryAlbum, MemoryAlbumError>> create({
    required String title,
    required String description,
    required List<int> postIds,
    required bool isPremium,
  });

  Future<Result<MemoryAlbum, MemoryAlbumError>> update({
    required String id,
    required String title,
    required String description,
    required List<int> postIds,
  });

  Future<void> delete(String id);

  Future<void> reorderAlbums(List<String> orderedIds);
}
