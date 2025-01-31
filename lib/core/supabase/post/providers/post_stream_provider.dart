import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_stream_provider.g.dart';

/// フード全体の投稿のストリームを提供
@riverpod
Stream<List<Map<String, dynamic>>> postStream(Ref ref) {
  final blockList = ref.watch(blockListProvider).asData?.value ?? [];
  return _filteredPostStream(null, blockList);
}

/// 自炊投稿のストリームを提供
@riverpod
Stream<List<Map<String, dynamic>>> postHomeMadeStream(Ref ref) {
  final blockList = ref.watch(blockListProvider).asData?.value ?? [];
  return _filteredPostStream('自炊', blockList);
}

/// 自分の投稿のストリームを提供
@riverpod
Stream<List<Map<String, dynamic>>> myPostStream(Ref ref) {
  final user = supabase.auth.currentUser?.id;
  if (user == null) {
    return const Stream.empty();
  }
  return supabase
      .from('posts')
      .stream(primaryKey: ['id'])
      .eq('user_id', user)
      .order('created_at');
}

/// 投稿のストリームをフィルタリングするヘルパー関数
Stream<List<Map<String, dynamic>>> _filteredPostStream(
  String? restaurantFilter,
  List<String> blockList,
) {
  final query = supabase.from('posts').stream(primaryKey: ['id']);

  if (restaurantFilter != null) {
    query.eq('restaurant', restaurantFilter);
  } else {
    query.neq('restaurant', '自炊');
  }

  return query.order('created_at').asyncMap(
        (events) => events.where((post) {
          return !blockList.contains(post['user_id']);
        }).toList(),
      );
}
