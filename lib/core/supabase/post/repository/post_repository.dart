import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/supabase/post/services/detail_post_service.dart';
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

  /// 複数の投稿とそのユーザー情報を取得（投稿詳細画面のリスト用）
  Future<Result<List<Model>, Exception>> getPostsWithUsers(
    List<int> postIds,
  ) async {
    try {
      if (postIds.isEmpty) {
        return const Success(<Model>[]);
      }
      final service = ref.read(detailPostServiceProvider.notifier);
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
      final posts = await ref.read(getNearByPostsProvider.future);
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
