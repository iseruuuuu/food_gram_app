import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/post/services/map_post_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'map_post_repository.g.dart';

@riverpod
class MapPostRepository extends _$MapPostRepository {
  @override
  Future<void> build() async {}

  /// マップ表示のレストランの投稿を全部取得ロジック
  Future<Result<List<Posts>, Exception>> getRestaurantPosts({
    required double lat,
    required double lng,
  }) async {
    final result = await ref
        .read(mapPostServiceProvider.notifier)
        .getRestaurantPosts(lat: lat, lng: lng);
    return result.when(
      success: (data) => Success(data.map(Posts.fromJson).toList()),
      failure: Failure.new,
    );
  }

  /// レストラン名で投稿一覧を取得（Repository経由）
  Future<List<Posts>> getPostsByRestaurantName({
    required String name,
  }) async {
    final data = await ref
        .read(mapPostServiceProvider.notifier)
        .getPostsByRestaurantName(name);
    return data.map(Posts.fromJson).toList();
  }
}

/// マップ表示のレストランの投稿を全部取得するProvider
@riverpod
Future<List<Posts>> mapRepository(Ref ref) async {
  final response =
      await ref.read(mapPostServiceProvider.notifier).getMapPosts();
  return response.map(Posts.fromJson).toList();
}

/// 現在地から近い投稿を20件取得するProvider
@riverpod
Future<List<Posts>> getNearByPosts(Ref ref) async {
  try {
    final data =
        await ref.read(mapPostServiceProvider.notifier).getNearbyPosts();
    final posts = data.map(Posts.fromJson).toList();
    return posts;
  } on PostgrestException catch (_) {
    return [];
  }
}

/// 特定のレストランの投稿一覧を取得するProvider
@riverpod
Future<Result<List<Model>, Exception>> restaurantReviews(
  Ref ref, {
  required double lat,
  required double lng,
}) async {
  final result = await ref
      .read(mapPostServiceProvider.notifier)
      .getRestaurantPosts(lat: lat, lng: lng);
  return result.when(
    success: (data) async {
      final service = ref.read(mapPostServiceProvider.notifier);
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

/// 自分の投稿だけを取得するマップ用Provider
@riverpod
Future<List<Posts>> myMapRepository(Ref ref) async {
  final response =
      await ref.read(mapPostServiceProvider.notifier).getMyMapPosts();
  return response.map(Posts.fromJson).toList();
}
