import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/post/services/post_service.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/main.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as maplibre;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'post_repository.g.dart';

@riverpod
class PostRepository extends _$PostRepository {
  @override
  Future<void> build() async {}

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
    List<Map<String, dynamic>> data,
    int index,
  ) async {
    try {
      final result =
          await ref.read(postServiceProvider.notifier).getPostData(data, index);
      final posts = Posts.fromJson(result['post'] as Map<String, dynamic>);
      final users = Users.fromJson(result['user'] as Map<String, dynamic>);
      return Success(Model(users, posts));
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
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

  /// 同じレストランの投稿とユーザー情報を取得
  Future<Result<List<Model>, Exception>> getStoryPosts({
    required double lat,
    required double lng,
  }) async {
    final result = await ref.read(postServiceProvider.notifier).getStoryPosts(
          lat: lat,
          lng: lng,
        );
    return result.when(
      success: (data) => Success(
        data
            .map(
              (item) => Model(
                Users.fromJson(item['user'] as Map<String, dynamic>),
                Posts.fromJson(item['post'] as Map<String, dynamic>),
              ),
            )
            .toList(),
      ),
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

/// カテゴリーが🍜の投稿を取得
@riverpod
Future<List<Posts>> mapRamenRepository(Ref ref) async {
  final response =
      await ref.read(postServiceProvider.notifier).getRamenMapPosts();
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
  /// 投稿データの取得
  final posts = await ref.watch(postStreamProvider.future);
  final currentLocation = await ref.read(locationProvider.future);
  if (currentLocation == const maplibre.LatLng(0, 0)) {
    return [];
  }

  /// 同じ位置の投稿をフィルタリング（最新のもののみ残す）
  final uniqueLocationPosts = <String, Posts>{};
  for (final post in posts.map(Posts.fromJson)) {
    final locationKey = '${post.lat}_${post.lng}';
    if (!uniqueLocationPosts.containsKey(locationKey)) {
      uniqueLocationPosts[locationKey] = post;
    }
  }

  /// 距離計算と並び替え
  final postsWithDistance = uniqueLocationPosts.values.map((post) {
    final distance = _calculateDistance(
      currentLocation.latitude,
      currentLocation.longitude,
      post.lat,
      post.lng,
    );
    return (post: post, distance: distance);
  }).toList()
    ..sort((a, b) => a.distance.compareTo(b.distance));
  return postsWithDistance.take(10).map((item) => item.post).toList();
}

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
      final models = <Model>[];
      for (var index = 0; index < data.length; index++) {
        final userData = await ref
            .read(postServiceProvider.notifier)
            .getUserData(data[index]['user_id'] as String);
        final user = Users.fromJson(userData);
        final posts = Posts.fromJson(data[index]);
        models.add(Model(user, posts));
      }
      return Success(models);
    },
    failure: Failure.new,
  );
}

/// 2点間の距離を計算（Haversine公式）
double _calculateDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const double earthRadius = 6371;
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

double _toRadians(double degree) {
  return degree * pi / 180;
}
