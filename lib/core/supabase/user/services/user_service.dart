import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_service.g.dart';

@riverpod
class UserService extends _$UserService {
  String get _currentUserId => supabase.auth.currentUser!.id;

  @override
  Future<void> build() async {}

  /// 自分のユーザー情報を取得
  Future<Map<String, dynamic>> getCurrentUser() async {
    return supabase
        .from('users')
        .select()
        .eq('user_id', _currentUserId)
        .single();
  }

  /// 他のユーザー情報を取得
  Future<Map<String, dynamic>> getOtherUser(String userId) async {
    return supabase.from('users').select().eq('user_id', userId).single();
  }

  /// 自分のユーザーの投稿数を取得
  Future<int> getCurrentUserPostCount() async {
    final response =
        await supabase.from('posts').select().eq('user_id', _currentUserId);
    return response.length;
  }

  /// 指定したユーザーの投稿数を取得
  Future<int> getOtherUserPostCount(String userId) async {
    final response =
        await supabase.from('posts').select().eq('user_id', userId);
    return response.length;
  }

  /// 投稿から指定したユーザー情報を取得
  Future<Map<String, dynamic>> getUserFromPost(Posts post) async {
    return supabase.from('users').select().eq('user_id', post.userId).single();
  }
}
