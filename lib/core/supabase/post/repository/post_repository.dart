import 'dart:typed_data';

import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/services/post_service.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'post_repository.g.dart';

@riverpod
class PostRepository extends _$PostRepository {
  final logger = Logger();
  final _cacheManager = CacheManager();

  String? get _currentUserId => ref.read(currentUserProvider);
  PostService get _postService => ref.read(postServiceProvider.notifier);

  @override
  Future<void> build() async {}

  /// 新規投稿を作成
  Future<Result<void, Exception>> createPost({
    required String foodName,
    required String comment,
    required List<String> uploadImages,
    required Map<String, Uint8List> imageBytesMap,
    required String restaurant,
    required double lat,
    required double lng,
    required String foodTag,
    required double star,
    required bool isAnonymous,
  }) async {
    try {
      final result = await _postService.createPost(
        foodName: foodName,
        comment: comment,
        uploadImages: uploadImages,
        imageBytesMap: imageBytesMap,
        restaurant: restaurant,
        lat: lat,
        lng: lng,
        foodTag: foodTag,
        star: star,
        isAnonymous: isAnonymous,
      );
      if (result is Success) {
        // キャッシュの無効化
        _cacheManager.invalidatePostsCache();
        if (_currentUserId != null) {
          _cacheManager.invalidateUserCache(_currentUserId!);
        }
      }
      return result;
    } on PostgrestException catch (e) {
      logger.e('Failed to create post: $e');
      return Failure(Exception(e.toString()));
    }
  }

  /// 投稿を編集
  Future<Result<void, Exception>> updatePost({
    required Posts posts,
    required String foodName,
    required String comment,
    required String restaurant,
    required String foodTag,
    required double lat,
    required double lng,
    required double star,
    required bool isAnonymous,
    required List<String> newImagePaths,
    required Map<String, Uint8List> imageBytesMap,
    required List<String> existingImagePaths,
  }) async {
    try {
      final result = await _postService.updatePost(
        posts: posts,
        foodName: foodName,
        comment: comment,
        restaurant: restaurant,
        foodTag: foodTag,
        lat: lat,
        lng: lng,
        star: star,
        isAnonymous: isAnonymous,
        newImagePaths: newImagePaths,
        imageBytesMap: imageBytesMap,
        existingImagePaths: existingImagePaths,
      );
      if (result is Success) {
        // キャッシュの無効化
        _cacheManager.invalidatePostsCache();
        if (_currentUserId != null) {
          _cacheManager.invalidateUserCache(_currentUserId!);
        }
        _cacheManager.invalidateRestaurantCache(posts.lat, posts.lng);
        _cacheManager.invalidateNearbyCache(posts.lat, posts.lng);
      }
      return result;
    } on PostgrestException catch (e) {
      logger.e('Failed to update post: $e');
      return Failure(Exception(e.toString()));
    }
  }
}
