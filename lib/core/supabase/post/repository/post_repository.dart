import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/post/services/post_service.dart';
import 'package:food_gram_app/core/utils/geo_distance.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'post_repository.g.dart';

@riverpod
class PostRepository extends _$PostRepository {
  @override
  Future<void> build() async {}
  final logger = Logger();

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

  /// 投稿詳細画面【タイムライン】：ID順で次の投稿のリストを取得
  Future<Result<List<Model>, Exception>> getSequentialPosts({
    required int currentPostId,
  }) async {
    try {
      final service = ref.read(postServiceProvider.notifier);
      final result = await service.getSequentialPosts(
        currentPostId: currentPostId,
      );
      return await result.when(
        success: (data) async {
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
          final futures = picked.map((postData) async {
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
      final data = await ref
          .read(postServiceProvider.notifier)
          .getPostsFromUserPaged(userId, limit: 60);
      return Success(data.map(Posts.fromJson).toList());
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// 特定ユーザーの投稿を追加取得（ページング）
  Future<Result<List<Posts>, Exception>> getPostsFromUserMore(
    String userId, {
    required int beforeId,
    int limit = 60,
  }) async {
    try {
      final data = await ref
          .read(postServiceProvider.notifier)
          .getPostsFromUserPaged(userId, limit: limit, beforeId: beforeId);
      return Success(data.map(Posts.fromJson).toList());
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// 近い順（初期投稿の緯度経度から距離昇順）
  Future<Result<List<Posts>, Exception>> getNearbyFromInitial({
    required Posts initialPost,
    int limit = 20,
  }) async {
    try {
      final data =
          await ref.read(postServiceProvider.notifier).getNearbyPosts();
      final posts = data.map(Posts.fromJson).toList();
      // 初期投稿と同一座標を起点に距離昇順
      posts.sort((a, b) {
        final da = geoKilometers(
          lat1: initialPost.lat,
          lon1: initialPost.lng,
          lat2: a.lat,
          lon2: a.lng,
        );
        final db = geoKilometers(
          lat1: initialPost.lat,
          lon1: initialPost.lng,
          lat2: b.lat,
          lon2: b.lng,
        );
        return da.compareTo(db);
      });
      final result =
          posts.where((p) => p.id != initialPost.id).take(limit).toList();
      return Success(result);
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// レストラン名で取得（新しい順）
  Future<Result<List<Posts>, Exception>> getByRestaurantName({
    required String restaurant,
  }) async {
    try {
      final data = await ref
          .read(postServiceProvider.notifier)
          .getPostsByRestaurantName(restaurant);
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
}

/// 特定ユーザーの投稿を取得
@riverpod
Future<List<Map<String, dynamic>>> profileRepository(
  Ref ref, {
  required String userId,
}) async {
  return ref.read(postServiceProvider.notifier).getPostsFromUser(userId);
}
