import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/post/services/post_service.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'post_repository.g.dart';

@riverpod
class PostRepository extends _$PostRepository {
  @override
  Future<void> build() async {}
  final logger = Logger();

  /// 全ての投稿を取得
  Future<Result<List<Posts>, Exception>> getPosts() async {
    try {
      final data = await ref.read(postServiceProvider.notifier).getPosts();
      return Success(data.map(Posts.fromJson).toList());
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// 特定の投稿とそのユーザー情報を取得
  Future<Result<Model, Exception>> getPostData(
    List<Posts> posts,
    int index,
  ) async {
    try {
      final post = posts[index];
      final userData =
          await ref.read(postServiceProvider.notifier).getUserData(post.userId);
      final user = Users.fromJson(userData);
      return Success(Model(user, post));
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// 特定の投稿を取得
  Future<Result<Posts, Exception>> getPost(int postId) async {
    try {
      final result =
          await ref.read(postServiceProvider.notifier).getPost(postId);
      return result.when(
        success: (data) =>
            Success(Posts.fromJson(data['post'] as Map<String, dynamic>)),
        failure: Failure.new,
      );
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// 複数の投稿とそのユーザー情報を取得（投稿詳細画面のリスト用）
  Future<Result<List<Model>, Exception>> getPostsWithUsers(
    List<int> postIds,
  ) async {
    try {
      if (postIds.isEmpty) {
        return const Success(<Model>[]);
      }
      final service = ref.read(postServiceProvider.notifier);
      final futures = postIds.map((postId) async {
        final result = await service.getPost(postId);
        return result.when(
          success: (data) async {
            final posts = Posts.fromJson(data['post'] as Map<String, dynamic>);
            final users = Users.fromJson(data['user'] as Map<String, dynamic>);
            return Model(users, posts);
          },
          failure: (error) async {
            logger.e('Failed to get post $postId: $error');
            return null;
          },
        );
      }).toList();
      final models =
          (await Future.wait<Model?>(futures)).whereType<Model>().toList();
      return Success<List<Model>, Exception>(models);
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure<List<Model>, Exception>(e);
    }
  }

  /// 投稿詳細画面用：ID順で次の投稿のリストを取得
  Future<Result<List<Model>, Exception>> getSequentialPosts({
    required int currentPostId,
    int limit = 10,
  }) async {
    try {
      final service = ref.read(postServiceProvider.notifier);
      final result = await service.getSequentialPosts(
        currentPostId: currentPostId,
        limit: limit,
      );
      return await result.when(
        success: (data) async {
          final futures = data.map((postData) async {
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
      logger.e('Database error: ${e.message}');
      return Failure<List<Model>, Exception>(e);
    }
  }

  /// 投稿詳細画面用：関連する投稿のリストを取得（同じレストランの投稿など）
  Future<Result<List<Model>, Exception>> getRelatedPosts({
    required int currentPostId,
    required double lat,
    required double lng,
    int limit = 10,
  }) async {
    try {
      final service = ref.read(postServiceProvider.notifier);
      final result = await service.getRelatedPosts(
        currentPostId: currentPostId,
        lat: lat,
        lng: lng,
        limit: limit,
      );
      return await result.when(
        success: (data) async {
          final futures = data.map((postData) async {
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
      logger.e('Database error: ${e.message}');
      return Failure<List<Model>, Exception>(e);
    }
  }

  /// 自分の全投稿に対するいいね数の合計を取得
  Future<Result<int, Exception>> getHeartAmount() async {
    try {
      final amount =
          await ref.read(postServiceProvider.notifier).getHeartAmount();
      return Success(amount);
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// 特定ユーザーの投稿のいいねの合計数を取得
  Future<Result<int, Exception>> getOtherHeartAmount(String userId) async {
    try {
      final amount = await ref
          .read(postServiceProvider.notifier)
          .getOtherHeartAmount(userId);
      return Success(amount);
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// 特定ユーザーの投稿を取得
  Future<Result<List<Posts>, Exception>> getPostsFromUser(String userId) async {
    try {
      final data =
          await ref.read(postServiceProvider.notifier).getPostsFromUser(userId);
      return Success(data.map(Posts.fromJson).toList());
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// 保存した投稿IDのリストから投稿を取得
  Future<Result<List<Posts>, Exception>> getStoredPosts(
    List<String> postIds,
  ) async {
    try {
      if (postIds.isEmpty) {
        return const Success(<Posts>[]);
      }
      final data =
          await ref.read(postServiceProvider.notifier).getStoredPosts(postIds);
      return Success(data.map(Posts.fromJson).toList());
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// マップ表示用の全投稿を取得
  Future<Result<List<Posts>, Exception>> getRestaurantPosts({
    required double lat,
    required double lng,
  }) async {
    final result =
        await ref.read(postServiceProvider.notifier).getRestaurantPosts(
              lat: lat,
              lng: lng,
            );

    return result.when(
      success: (data) => Success(data.map(Posts.fromJson).toList()),
      failure: Failure.new,
    );
  }
}

/// マップ表示用の全投稿を取得🗾
@riverpod
Future<List<Posts>> mapRepository(Ref ref) async {
  final response = await ref.read(postServiceProvider.notifier).getMapPosts();
  return response.map(Posts.fromJson).toList();
}

/// 特定ユーザーの投稿を取得
@riverpod
Future<List<Map<String, dynamic>>> profileRepository(
  Ref ref, {
  required String userId,
}) async {
  return ref.read(postServiceProvider.notifier).getPostsFromUser(userId);
}

/// 現在地から近い投稿を10件取得
@riverpod
Future<List<Posts>> getNearByPosts(Ref ref) async {
  try {
    final data = await ref.read(postServiceProvider.notifier).getNearbyPosts();
    final posts = data.map(Posts.fromJson).toList();
    return posts;
  } on PostgrestException catch (_) {
    return [];
  }
}

/// 2点間の距離を計算（Haversine公式）
// 距離計算は未使用のため削除

/// 特定のレストランの投稿一覧を取得するプロバイダー
@riverpod
Future<Result<List<Model>, Exception>> restaurantReviews(
  Ref ref, {
  required double lat,
  required double lng,
}) async {
  final result =
      await ref.read(postServiceProvider.notifier).getRestaurantPosts(
            lat: lat,
            lng: lng,
          );

  return result.when(
    success: (data) async {
      final service = ref.read(postServiceProvider.notifier);
      final futures = data.map((postData) async {
        final userId = postData['user_id'] as String?;
        if (userId == null) {
          return null;
        }
        final userData = await service.getUserData(userId);
        final user = Users.fromJson(userData);
        final posts = Posts.fromJson(postData);
        return Model(user, posts);
      }).toList();
      final models =
          (await Future.wait<Model?>(futures)).whereType<Model>().toList();
      return Success<List<Model>, Exception>(models);
    },
    failure: Failure<List<Model>, Exception>.new,
  );
}
