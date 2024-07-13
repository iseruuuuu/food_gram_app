import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'posts_service.g.dart';

@riverpod
PostsService postsService(PostsServiceRef ref) => PostsService();

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
}
