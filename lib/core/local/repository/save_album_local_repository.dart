import 'dart:math';

import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/save_album.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// アルバム ID 一覧は [PreferenceKey.saveAlbumIds]（StringList）。
/// 各アルバムの名前は `fg_save_album_name_<id>`（String）、
/// 投稿 ID 列は `fg_save_album_posts_<id>`（StringList）。
class SaveAlbumLocalRepository {
  SaveAlbumLocalRepository({Random? random}) : _random = random ?? Random();

  static const String _namePrefix = 'fg_save_album_name_';
  static const String _postsPrefix = 'fg_save_album_posts_';

  final Random _random;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  String _nameKey(String albumId) => '$_namePrefix$albumId';
  String _postsKey(String albumId) => '$_postsPrefix$albumId';

  String _newAlbumId() {
    return 'alb_${DateTime.now().microsecondsSinceEpoch}_'
        '${_random.nextInt(0x7fffffff)}';
  }

  Future<List<SaveAlbum>> loadAlbums() async {
    final p = await _prefs;
    final ids = p.getStringList(PreferenceKey.saveAlbumIds.name) ?? [];
    final out = <SaveAlbum>[];
    for (final id in ids) {
      final name = p.getString(_nameKey(id)) ?? '';
      out.add(SaveAlbum(id: id, name: name.isEmpty ? id : name));
    }
    return out;
  }

  Future<Set<String>> albumIdsContainingPost(int postId) async {
    final pid = postId.toString();
    final p = await _prefs;
    final ids = p.getStringList(PreferenceKey.saveAlbumIds.name) ?? [];
    final out = <String>{};
    for (final id in ids) {
      final list = p.getStringList(_postsKey(id)) ?? [];
      if (list.contains(pid)) {
        out.add(id);
      }
    }
    return out;
  }

  Future<List<String>> getAlbumPostIdsOrdered(String albumId) async {
    final p = await _prefs;
    return List<String>.from(
      p.getStringList(_postsKey(albumId)) ?? const <String>[],
    );
  }

  Future<SaveAlbumIssue?> createAlbum({
    required String name,
    required bool isPremium,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return SaveAlbumIssue.emptyName;
    }
    final p = await _prefs;
    final ids = List<String>.from(
      p.getStringList(PreferenceKey.saveAlbumIds.name) ?? const <String>[],
    );
    final maxAlbums = isPremium
        ? SaveAlbumLimits.premiumMaxAlbums
        : SaveAlbumLimits.freeMaxAlbums;
    if (ids.length >= maxAlbums) {
      return SaveAlbumIssue.albumLimitFree;
    }
    final id = _newAlbumId();
    ids.add(id);
    await p.setStringList(PreferenceKey.saveAlbumIds.name, ids);
    await p.setString(_nameKey(id), trimmed);
    await p.setStringList(_postsKey(id), const <String>[]);
    return null;
  }

  /// 保存解除時: 全アルバムから該当投稿を外す
  Future<void> removePostFromAllAlbums(int postId) async {
    final pid = postId.toString();
    final p = await _prefs;
    final ids = p.getStringList(PreferenceKey.saveAlbumIds.name) ?? [];
    for (final id in ids) {
      final key = _postsKey(id);
      final list = List<String>.from(p.getStringList(key) ?? const <String>[]);
      if (list.remove(pid)) {
        await p.setStringList(key, list);
      }
    }
  }

  /// チェックボックス確定時: 全アルバムについてメンバーシップを同期
  Future<SaveAlbumIssue?> setPostAlbumMembership({
    required int postId,
    required Set<String> desiredAlbumIds,
    required bool isPremium,
  }) async {
    final p = await _prefs;
    final storeList = p.getStringList(PreferenceKey.storeList.name) ?? [];
    final pid = postId.toString();
    if (!storeList.contains(pid)) {
      return SaveAlbumIssue.postNotInSavedList;
    }

    final allAlbumIds =
        p.getStringList(PreferenceKey.saveAlbumIds.name) ?? const <String>[];
    final maxPer = isPremium
        ? SaveAlbumLimits.premiumMaxPostsPerAlbum
        : SaveAlbumLimits.freeMaxPostsPerAlbum;

    for (final albumId in allAlbumIds) {
      final key = _postsKey(albumId);
      final current = List<String>.from(
        p.getStringList(key) ?? const <String>[],
      );
      final want = desiredAlbumIds.contains(albumId);
      final has = current.contains(pid);
      if (want && !has && current.length >= maxPer) {
        return SaveAlbumIssue.postLimitFree;
      }
    }

    for (final albumId in allAlbumIds) {
      final key = _postsKey(albumId);
      final current = List<String>.from(
        p.getStringList(key) ?? const <String>[],
      );
      final want = desiredAlbumIds.contains(albumId);
      final has = current.contains(pid);
      if (want && !has) {
        current.add(pid);
        await p.setStringList(key, current);
      } else if (!want && has) {
        current.remove(pid);
        await p.setStringList(key, current);
      }
    }
    return null;
  }
}
