import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/local/save_album_local_repository.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/services/fetch_post_service.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'stored_post_view_model.g.dart';

@riverpod
Future<List<Posts>> storedPostList(
  Ref ref,
  String? albumId,
) async {
  final logger = Logger();
  final preference = Preference();
  final List<String> storedPostIds;
  if (albumId != null && albumId.isNotEmpty) {
    storedPostIds =
        await SaveAlbumLocalRepository().getAlbumPostIdsOrdered(albumId);
  } else {
    storedPostIds = await preference.getStringList(PreferenceKey.storeList);
  }
  if (storedPostIds.isEmpty) {
    logger.d('no local ids food_gram.stored_posts');
    return [];
  }
  final intIds = storedPostIds.map(int.tryParse).whereType<int>().toList();
  if (intIds.isEmpty) {
    logger.d('no parseable post ids food_gram.stored_posts');
    return [];
  }
  try {
    final maps = await fetchStoredPostRowsForIds(
      ref.read(supabaseProvider),
      storedPostIds,
    ).timeout(
      const Duration(seconds: 45),
      onTimeout: () {
        throw TimeoutException(
          'fetchStoredPostRowsForIds (${storedPostIds.length} ids)',
        );
      },
    );
    final parsed = <Posts>[];
    for (final row in maps) {
      try {
        parsed.add(Posts.fromJson(row));
      } on Object catch (e, st) {
        logger.w('stored posts: skip row parse error: $e\n$st');
      }
    }
    final byId = {for (final p in parsed) p.id: p};
    final ordered = <Posts>[];
    for (final idStr in storedPostIds) {
      final id = int.tryParse(idStr);
      if (id == null) {
        continue;
      }
      final p = byId[id];
      if (p != null) {
        ordered.add(p);
      }
    }
    logger.d(
      'load ok count=${ordered.length} food_gram.stored_posts',
    );
    return ordered;
  } on PostgrestException catch (e, st) {
    logger.e('Postgrest error loading stored posts: ${e.message}\n$st');
    rethrow;
  } on TimeoutException catch (e, st) {
    logger.e('Timeout loading stored posts: $e\n$st');
    rethrow;
  } on Object catch (e, st) {
    logger.e('Error loading stored posts: $e\n$st');
    rethrow;
  }
}
