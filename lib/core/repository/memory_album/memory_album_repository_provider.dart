import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/repository/memory_album/memory_album_local_repository.dart';
import 'package:food_gram_app/core/repository/memory_album/memory_album_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memory_album_repository_provider.g.dart';

@Riverpod(keepAlive: true)
MemoryAlbumRepository memoryAlbumRepository(Ref ref) {
  return MemoryAlbumLocalRepository();
}
