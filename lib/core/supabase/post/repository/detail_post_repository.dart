import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/post_deail_list_mode.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/fetch_post_repository.dart';
import 'package:food_gram_app/core/supabase/post/services/detail_post_service.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'detail_post_repository.g.dart';

@riverpod
class DetailPostRepository extends _$DetailPostRepository {
  @override
  Future<void> build() async {}
  final logger = Logger();

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

  Future<Result<List<Posts>, Exception>> getPostsFromUser(String userId) async {
    try {
      final data = await ref
          .read(detailPostServiceProvider.notifier)
          .getPostsFromUserPaged(userId, limit: 60);
      return Success(data.map(Posts.fromJson).toList());
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// ユーザーデータを取得
  Future<Map<String, dynamic>> getUserData(String userId) async {
    final service = ref.read(detailPostServiceProvider.notifier);
    return service.getUserData(userId);
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

  /// 投稿詳細画面のリスト（Posts のみ）を mode ごとに返す
  Future<List<Posts>> getPostDetailList({
    required Posts initialPost,
    required PostDetailListMode mode,
    String? profileUserId,
    String? restaurant,
  }) async {
    switch (mode) {
      case PostDetailListMode.timeline:
        {
          final sequentialPostsResult =
              await getSequentialPosts(currentPostId: initialPost.id);
          return sequentialPostsResult.when(
            success: (models) => [
              initialPost,
              ...models.map((m) => m.posts),
            ],
            failure: (_) => [initialPost],
          );
        }
      case PostDetailListMode.myprofile:
        {
          final currentUser = ref.watch(currentUserProvider);
          if (currentUser == null) {
            return [initialPost];
          }
          final userPostsResult = await getPostsFromUser(currentUser);
          return userPostsResult.when(
            success: (posts) {
              final sorted = [...posts]
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              final others = sorted.where((p) {
                if (p.id == initialPost.id) {
                  return false;
                }
                final isBefore = p.createdAt.isBefore(initialPost.createdAt);
                final isSameAndLowerId =
                    p.createdAt.isAtSameMomentAs(initialPost.createdAt) &&
                        p.id < initialPost.id;
                return isBefore || isSameAndLowerId;
              }).toList(growable: false);
              return [initialPost, ...others];
            },
            failure: (_) => [initialPost],
          );
        }
      case PostDetailListMode.profile:
        {
          final userId = profileUserId;
          if (userId == null || userId.isEmpty) {
            return [initialPost];
          }
          final userPostsResult = await getPostsFromUser(userId);
          return userPostsResult.when(
            success: (posts) {
              final sorted = [...posts]
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              final others = sorted.where((p) {
                if (p.id == initialPost.id) {
                  return false;
                }
                final isBefore = p.createdAt.isBefore(initialPost.createdAt);
                final isSameAndLowerId =
                    p.createdAt.isAtSameMomentAs(initialPost.createdAt) &&
                        p.id < initialPost.id;
                return isBefore || isSameAndLowerId;
              }).toList(growable: false);
              return [initialPost, ...others];
            },
            failure: (_) => [initialPost],
          );
        }
      case PostDetailListMode.nearby:
        {
          final relatedPostsResult = await getRelatedPosts(
            currentPostId: initialPost.id,
            lat: initialPost.lat,
            lng: initialPost.lng,
          );
          return relatedPostsResult.when(
            success: (models) => [
              initialPost,
              ...models.map((m) => m.posts),
            ],
            failure: (_) => [initialPost],
          );
        }
      case PostDetailListMode.search:
        {
          final name = restaurant ?? initialPost.restaurant;
          final postRepo = ref.read(fetchPostRepositoryProvider.notifier);
          final restaurantPostsResult =
              await postRepo.getByRestaurantName(restaurant: name);
          return restaurantPostsResult.when(
            success: (posts) {
              final others = posts
                  .where((p) => p.id != initialPost.id)
                  .toList(growable: false);
              return [initialPost, ...others];
            },
            failure: (_) => [initialPost],
          );
        }
      case PostDetailListMode.stored:
        {
          final storeList =
              await Preference().getStringList(PreferenceKey.storeList);
          if (storeList.isEmpty) {
            return <Posts>[];
          }
          final idOrder = storeList.map(int.tryParse).whereType<int>().toList()
            ..sort((a, b) => b.compareTo(a));
          if (idOrder.isEmpty) {
            return <Posts>[];
          }
          final postRepo = ref.read(fetchPostRepositoryProvider.notifier);
          final storedPostsResult = await postRepo.getStoredPosts(storeList);
          return storedPostsResult.when(
            success: (posts) {
              final mapById = {for (final p in posts) p.id: p};
              final ordered = idOrder
                  .map((id) => mapById[id])
                  .whereType<Posts>()
                  .toList(growable: false);
              final index = ordered.indexWhere((p) => p.id == initialPost.id);
              final tail = index >= 0 && index + 1 < ordered.length
                  ? ordered.sublist(index + 1)
                  : <Posts>[];
              return [initialPost, ...tail];
            },
            failure: (_) => [initialPost],
          );
        }
      // no default; all enum cases are covered above
    }
  }
}
