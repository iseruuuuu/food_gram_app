import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/services/detail_post_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'detail_post_repository.g.dart';

@riverpod
class DetailPostRepository extends _$DetailPostRepository {
  @override
  Future<void> build() async {}

  /// 特定の投稿を取得
  Future<Result<Posts, Exception>> getPost(int postId) async {
    try {
      final service = ref.read(detailPostServiceProvider.notifier);
      final result = await service.getPost(postId);
      return result.when(
        success: (data) =>
            Success(Posts.fromJson(data['post'] as Map<String, dynamic>)),
        failure: Failure.new,
      );
    } on PostgrestException catch (e) {
      return Failure(e);
    }
  }

  /// ユーザーデータを取得
  Future<Result<Model, Exception>> getPostData(
    List<Posts> posts,
    int index,
  ) async {
    try {
      final service = ref.read(detailPostServiceProvider.notifier);
      if (index < 0 || index >= posts.length) {
        return Failure(Exception('index out of range: $index'));
      }
      final selectedPost = posts[index];
      final userId = selectedPost.userId;
      if (userId.isEmpty) {
        return Failure(Exception('empty userId (index=$index)'));
      }
      final userData = await service.getUserData(userId);
      final user = Users.fromJson(userData);
      return Success(Model(user, selectedPost));
    } on PostgrestException catch (e) {
      return Failure(e);
    }
  }

  /// 指定した投稿IDより新しい投稿のリストを取得する
  Future<Result<List<Model>, Exception>> getSequentialPosts({
    required int currentPostId,
  }) async {
    try {
      final service = ref.read(detailPostServiceProvider.notifier);
      final result =
          await service.getSequentialPosts(currentPostId: currentPostId);
      return await result.when(
        success: (data) async {
          final blockList =
              ref.read(blockListProvider).asData?.value ?? const <String>[];
          final sorted = [...data]..sort(
              (a, b) => ((b['id'] as num).toInt())
                  .compareTo((a['id'] as num).toInt()),
            );
          final seen = <int>{};
          final picked = <Map<String, dynamic>>[];
          for (final m in sorted) {
            final id = (m['id'] as num).toInt();
            if (id >= currentPostId) {
              continue;
            }
            if (seen.add(id)) {
              picked.add(m);
              if (picked.length >= 15) {
                break;
              }
            }
          }
          final filtered = picked
              .where((m) => !blockList.contains(m['user_id'] as String? ?? ''))
              .toList(growable: false);
          final futures = filtered.map((postData) async {
            final userId = postData['user_id'] as String?;
            if (userId == null) {
              return null;
            }
            final userData = await service.getUserData(userId);
            return Model(Users.fromJson(userData), Posts.fromJson(postData));
          }).toList();
          final models =
              (await Future.wait<Model?>(futures)).whereType<Model>().toList();
          return Success<List<Model>, Exception>(models);
        },
        failure: (e) async => Failure<List<Model>, Exception>(e),
      );
    } on PostgrestException catch (e) {
      return Failure<List<Model>, Exception>(e);
    }
  }

  /// 指定した投稿IDと同じレストランの投稿のリストを取得する
  Future<Result<List<Model>, Exception>> getRelatedPosts({
    required int currentPostId,
    required double lat,
    required double lng,
  }) async {
    try {
      final service = ref.read(detailPostServiceProvider.notifier);
      final result = await service.getRelatedPosts(
        currentPostId: currentPostId,
        lat: lat,
        lng: lng,
      );
      return await result.when(
        success: (data) async {
          final blockList =
              ref.read(blockListProvider).asData?.value ?? const <String>[];
          final filtered = data
              .where((m) => !blockList.contains(m['user_id'] as String? ?? ''))
              .toList(growable: false);
          final futures = filtered.map((postData) async {
            final userId = postData['user_id'] as String?;
            if (userId == null) {
              return null;
            }
            final userData = await service.getUserData(userId);
            return Model(Users.fromJson(userData), Posts.fromJson(postData));
          }).toList();
          final models =
              (await Future.wait<Model?>(futures)).whereType<Model>().toList();
          return Success<List<Model>, Exception>(models);
        },
        failure: (e) async => Failure<List<Model>, Exception>(e),
      );
    } on PostgrestException catch (e) {
      return Failure<List<Model>, Exception>(e);
    }
  }
}
