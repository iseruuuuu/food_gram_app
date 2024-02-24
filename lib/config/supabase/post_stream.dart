import 'package:food_gram_app/config/shared_preference/shared_preference.dart';
import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_stream.g.dart';

@riverpod
Stream<List<Map<String, dynamic>>> postStream(PostStreamRef ref) {
  final blockList = ref.watch(blockListProvider).asData?.value ?? [];
  return supabase
      .from('posts')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .asyncMap(
        (events) => events.where((post) {
          return !blockList.contains(post['user_id']);
        }).toList(),
      );
}

@riverpod
Future<List<String>> blockList(BlockListRef ref) {
  final preference = Preference();
  return preference.getStringList(PreferenceKey.blockList);
}

@riverpod
Stream<List<Map<String, dynamic>>> myPostStream(PostStreamRef ref) {
  final user = supabase.auth.currentUser?.id;
  return supabase
      .from('posts')
      .stream(primaryKey: ['id'])
      .eq('user_id', user!)
      .order('created_at');
}
