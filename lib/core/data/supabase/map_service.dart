import 'package:food_gram_app/core/data/supabase/post_stream.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_service.g.dart';

@riverpod
Future<List<Posts>> mapService(MapServiceRef ref) async {
  final blockList = ref.watch(blockListProvider).asData?.value ?? [];
  final response = await supabase.from('posts').select().order('created_at');
  final data = response;
  return data
      .map(Posts.fromJson)
      .where((post) => !blockList.contains(post.userId))
      .where((post) => post.lat != 0.0 && post.lng != 0)
      .toList();
}

@riverpod
Future<List<Posts>> getRestaurant(
  GetRestaurantRef ref, {
  required double lat,
  required double lng,
}) async {
  final blockList = ref.watch(blockListProvider).asData?.value ?? [];
  final response = await supabase
      .from('posts')
      .select()
      .gte('lat', lat - 0.00001)
      .lte('lat', lat + 0.00001)
      .gte('lng', lng - 0.00001)
      .lte('lng', lng + 0.00001)
      .order('created_at');
  final data = response;
  final result = data
      .map((json) {
        return Posts.fromJson(json);
      })
      .where((post) => !blockList.contains(post.userId))
      .toList();
  return result;
}
