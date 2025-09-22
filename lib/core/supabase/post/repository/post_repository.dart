import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
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

  /// 近い順（初期投稿の緯度経度から距離昇順）
  Future<Result<List<Posts>, Exception>> getNearbyFromInitial({
    required Posts initialPost,
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
          posts.where((p) => p.id != initialPost.id).take(15).toList();
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
