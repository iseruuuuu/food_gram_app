import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/post/services/post_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_detail_user_provider.g.dart';

/// 投稿に対応するユーザー情報を取得するプロバイダー
@riverpod
Future<Users> postDetailUser(Ref ref, String userId) async {
  final userData =
      await ref.read(postServiceProvider.notifier).getUserData(userId);
  return Users.fromJson(userData);
}
