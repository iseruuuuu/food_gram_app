import 'package:food_gram_app/core/local/save_album_local_repository.dart';
import 'package:food_gram_app/core/model/save_album.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'save_album_notifier.g.dart';

@riverpod
class SaveAlbumNotifier extends _$SaveAlbumNotifier {
  final SaveAlbumLocalRepository _repo = SaveAlbumLocalRepository();

  @override
  Future<List<SaveAlbum>> build() async => _repo.loadAlbums();

  bool get _isPremium => ref.read(isSubscribeProvider).value ?? false;

  /// 明示的に [AsyncLoading] にしない（チップ行が消えてダイアログ表示中のツリーが壊れやすいため）
  Future<void> reload() async {
    state = await AsyncValue.guard(_repo.loadAlbums);
  }

  Future<SaveAlbumIssue?> createAlbum(String rawName) async {
    final issue =
        await _repo.createAlbum(name: rawName, isPremium: _isPremium);
    if (issue == null) {
      await reload();
    }
    return issue;
  }

  Future<SaveAlbumIssue?> applyMembership({
    required int postId,
    required Set<String> albumIds,
  }) async {
    final issue = await _repo.setPostAlbumMembership(
      postId: postId,
      desiredAlbumIds: albumIds,
      isPremium: _isPremium,
    );
    if (issue == null) {
      await reload();
    }
    return issue;
  }

  Future<Set<String>> initialSelectionForPost(int postId) =>
      _repo.albumIdsContainingPost(postId);
}
