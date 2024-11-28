import 'package:food_gram_app/core/data/supabase/block_list.dart';
import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_stream.g.dart';

@riverpod
Stream<List<Map<String, dynamic>>> postStream(PostStreamRef ref) {
  final blockList = ref.watch(blockListProvider).asData?.value ?? [];
  return _filteredPostStream(null, blockList);
}

@riverpod
Stream<List<Map<String, dynamic>>> postHomeMadeStream(
  PostHomeMadeStreamRef ref,
) {
  final blockList = ref.watch(blockListProvider).asData?.value ?? [];
  return _filteredPostStream('自炊', blockList);
}

@riverpod
Stream<List<Map<String, dynamic>>> myPostStream(PostStreamRef ref) {
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
