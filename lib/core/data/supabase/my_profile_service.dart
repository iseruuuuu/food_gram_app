import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_profile_service.g.dart';

@riverpod
MyProfileService myProfileService(MyProfileServiceRef ref) =>
    MyProfileService();

class MyProfileService {
  MyProfileService();

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

//TODO いいね数を取得する
}
