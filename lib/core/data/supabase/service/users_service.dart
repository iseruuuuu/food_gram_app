import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'users_service.g.dart';

@riverpod
UsersService usersService(UsersServiceRef ref) => UsersService();

class UsersService {
  UsersService();

  final userId = supabase.auth.currentUser!.id;

  Future<Map<String, dynamic>> getUsers() async {
    final data =
        await supabase.from('users').select().eq('user_id', userId).single();
    return data;
  }

  Future<int> getLength() async {
    final response =
        await supabase.from('posts').select().eq('user_id', userId);
    return response.length;
  }

  Future<Users> getUsersFromPost(Posts post) async {
    final userId = post.userId;
    final dynamic postUserId =
        await supabase.from('users').select().eq('user_id', userId).single();
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
    return users;
  }
}
