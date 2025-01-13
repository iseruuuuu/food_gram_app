import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/data/supabase/block_list.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'posts_service.g.dart';

@riverpod
PostsService postsService(Ref ref) => PostsService();

class PostsService {
  PostsService();

  final userId = supabase.auth.currentUser!.id;

  Future<int> getHeartAmount() async {
    var heartAmount = 0;
    final list =
        await supabase.from('posts').select('heart').eq('user_id', userId);
    for (var i = 0; i < list.length; i++) {
      final int value = list[i]['heart'];
      heartAmount += value;
    }
    return heartAmount;
  }

  Future<Model> getPost(List<Map<String, dynamic>> data, int index) async {
    final posts = Posts(
      id: int.parse(data[index]['id'].toString()),
      userId: data[index]['user_id'],
      foodImage: data[index]['food_image'],
      foodName: data[index]['food_name'],
      restaurant: data[index]['restaurant'],
      comment: data[index]['comment'],
      createdAt: DateTime.parse(data[index]['created_at']),
      lat: double.parse(data[index]['lat'].toString()),
      lng: double.parse(data[index]['lng'].toString()),
      heart: int.parse(data[index]['heart'].toString()),
      restaurantTag: data[index]['restaurant_tag'],
      foodTag: data[index]['food_tag'],
    );
    final dynamic postUserId = await supabase
        .from('users')
        .select()
        .eq('user_id', data[index]['user_id'])
        .single();
    final users = Users(
      id: postUserId['id'],
      userId: postUserId['user_id'],
      name: postUserId['name'],
      userName: postUserId['user_name'],
      selfIntroduce: postUserId['self_introduce'],
      image: postUserId['image'],
      createdAt: DateTime.parse(postUserId['created_at']),
      updatedAt: DateTime.parse(postUserId['updated_at']),
      exchangedPoint: postUserId['exchanged_point'],
    );
    return Model(users, posts);
  }
}

@riverpod
Future<List<Posts>> mapService(Ref ref) async {
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
  Ref ref, {
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
