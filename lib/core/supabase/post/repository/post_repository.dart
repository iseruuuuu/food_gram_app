import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/services/post_service.dart';
import 'package:food_gram_app/main.dart';
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
  Future<Result<Model, Exception>> getPost(
    List<Map<String, dynamic>> data,
    int index,
  ) async {
    try {
      final result =
          await ref.read(postServiceProvider.notifier).getPostData(data, index);
      final posts = Posts.fromJson(result['post']);
      final users = Users.fromJson(result['user']);
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

  /// ランダムな投稿を取得（指定した投稿以外から3件）
  Future<Result<List<Model>, Exception>> getRandomPosts(
    List<Map<String, dynamic>> data,
    int index,
  ) async {
    try {
      final models = <Model>[];
      final randomResult = await ref
          .read(postServiceProvider.notifier)
          .getRandomPost(data, index);
      final post = Posts.fromJson(data[index]);
      final user = Users.fromJson(randomResult);
      models.add(Model(user, post));
      final random = Random();
      final remainingData = List<Map<String, dynamic>>.from(data)
        ..removeAt(index);
      final randomData = (remainingData..shuffle(random)).take(3).toList();
      for (final item in randomData) {
        final posts = Posts.fromJson(item);
        final result = await ref
            .read(postServiceProvider.notifier)
            .getRandomPosts(data, index);
        final users = Users.fromJson(result);
        models.add(Model(users, posts));
      }
      return Success(models);
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// マップ表示用の全投稿を取得
  Future<List<Posts>> getRestaurantPosts({
    required double lat,
    required double lng,
  }) async {
    final blockList = ref.watch(blockListProvider).asData?.value ?? [];
    final data =
        await ref.read(postServiceProvider.notifier).getRestaurantPosts(
              lat: lat,
              lng: lng,
            );
    final posts = data
        .map(Posts.fromJson)
        .where((post) => !blockList.contains(post.userId))
        .toList();
    return posts;
  }

  /// 同じレストランの投稿を取得する
  Future<Result<List<Model>, Exception>> getStoryPosts({
    required double lat,
    required double lng,
  }) async {
    try {
      final blockList = ref.watch(blockListProvider).asData?.value ?? [];
      final data =
          await ref.read(postServiceProvider.notifier).getRestaurantPosts(
                lat: lat,
                lng: lng,
              );
      final posts = data
          .map(Posts.fromJson)
          .where((post) => !blockList.contains(post.userId))
          .toList();
      final models = <Model>[];
      for (var index = 0; index < posts.length; index++) {
        final userData = await ref
            .read(postServiceProvider.notifier)
            .getUserData(posts[index].userId);
        final user = Users.fromJson(userData);
        models.add(Model(user, posts[index]));
      }
      return Success(models);
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }
}

/// マップ表示用の全投稿を取得
@riverpod
Future<List<Posts>> mapRepository(Ref ref) async {
  final blockList = ref.watch(blockListProvider).asData?.value ?? [];
  final response = await ref.read(postServiceProvider.notifier).getMapPosts();
  final data = response;
  return data
      .map(Posts.fromJson)
      .where((post) => !blockList.contains(post.userId))
      .where((post) => post.lat != 0.0 && post.lng != 0)
      .toList();
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
class GetNearByPosts extends _$GetNearByPosts {
  @override
  Future<List<Posts>> build() async {
    ///  5分間キャッシュを保持
    ref.keepAlive();
    state = const AsyncValue.loading();
    final data = await ref.read(postServiceProvider.notifier).getNearbyPosts();
    return data.map(Posts.fromJson).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final data = await ref.read(postServiceProvider.notifier).getNearbyPosts();
    state = AsyncValue.data(data.map(Posts.fromJson).toList());
  }
}
