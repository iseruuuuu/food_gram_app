import 'dart:typed_data';

import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'post_service.g.dart';

@riverpod
class PostService extends _$PostService {
  final logger = Logger();
  final _cacheManager = CacheManager();

  String? get _currentUserId => ref.read(currentUserProvider);

  SupabaseClient get supabase => ref.read(supabaseProvider);

  List<String> get blockList =>
      ref.watch(blockListProvider).asData?.value ?? [];

  @override
  Future<void> build() async {}

  /// 新規投稿を作成
  Future<Result<void, Exception>> post({
    required String foodName,
    required String comment,
    required String uploadImage,
    required Uint8List imageBytes,
    required String restaurant,
    required double lat,
    required double lng,
    required String restaurantTag,
    required String foodTag,
    required bool isAnonymous,
  }) async {
    try {
      await _uploadImage(uploadImage, imageBytes);
      await _createPost(
        foodName: foodName,
        comment: comment,
        uploadImage: uploadImage,
        restaurant: restaurant,
        lat: lat,
        lng: lng,
        restaurantTag: restaurantTag,
        foodTag: foodTag,
        isAnonymous: isAnonymous,
      );
      // 新規投稿後は関連するキャッシュを無効化
      _cacheManager.invalidatePostsCache();
      if (_currentUserId != null) {
        _cacheManager.invalidateUserCache(_currentUserId!);
      }
      return const Success(null);
    } on PostgrestException catch (e) {
      logger.e('Failed to create post: ${e.message}');
      return Failure(e);
    }
  }

  /// 投稿データの作成処理
  Future<void> _createPost({
    required String foodName,
    required String comment,
    required String uploadImage,
    required String restaurant,
    required double lat,
    required double lng,
    required String restaurantTag,
    required String foodTag,
    required bool isAnonymous,
  }) async {
    final post = {
      'user_id': _currentUserId,
      'food_name': foodName,
      'comment': comment,
      'created_at': DateTime.now().toIso8601String(),
      'heart': 0,
      'restaurant': restaurant,
      'food_image': '/$_currentUserId/$uploadImage',
      'lat': lat,
      'lng': lng,
      'restaurant_tag': restaurantTag,
      'food_tag': foodTag,
      'is_anonymous': isAnonymous,
    };

    await supabase.from('posts').insert(post);
  }

  /// 画像のアップロード処理
  Future<void> _uploadImage(String uploadImage, Uint8List imageBytes) async {
    await supabase.storage.from('food').uploadBinary(
          '/$_currentUserId/$uploadImage',
          imageBytes,
        );
  }

  /// 投稿を編集
  Future<Result<void, Exception>> updatePost({
    required Posts posts,
    required String foodName,
    required String comment,
    required String restaurant,
    required String restaurantTag,
    required String foodTag,
    required double lat,
    required double lng,
    required bool isAnonymous,
    String? newImagePath,
    Uint8List? imageBytes,
  }) async {
    try {
      // 全てのフィールドが同じかチェック
      final isUnchanged = foodName == posts.foodName &&
          comment == posts.comment &&
          restaurant == posts.restaurant &&
          restaurantTag == posts.restaurantTag &&
          foodTag == posts.foodTag &&
          lat == posts.lat &&
          lng == posts.lng &&
          isAnonymous == posts.isAnonymous &&
          (newImagePath == null ||
              '/$_currentUserId/$newImagePath' == posts.foodImage);

      if (isUnchanged) {
        return const Success(null);
      }

      // 変更がある場合は更新用のマップを作成
      final updates = {
        'food_name': foodName,
        'comment': comment,
        'restaurant': restaurant,
        'restaurant_tag': restaurantTag,
        'food_tag': foodTag,
        'lat': lat,
        'lng': lng,
        'is_anonymous': isAnonymous,
      };

      // 新しい画像がある場合、古い画像を削除してから新しい画像をアップロード
      if (newImagePath != null && imageBytes != null) {
        final oldImagePath = posts.foodImage.substring(1).replaceAll('//', '/');
        // 古い画像を削除
        await supabase.storage.from('food').remove([oldImagePath]);
        // 新しい画像をアップロード
        await _uploadImage(newImagePath, imageBytes);
        updates['food_image'] = '/$_currentUserId/$newImagePath';
      } else {
        updates['food_image'] = posts.foodImage;
      }

      await supabase.from('posts').update(updates).eq('id', posts.id);

      // キャッシュの無効化
      _cacheManager.invalidatePostsCache();
      if (_currentUserId != null) {
        _cacheManager.invalidateUserCache(_currentUserId!);
      }
      _cacheManager.invalidateRestaurantCache(posts.lat, posts.lng);
      _cacheManager.invalidateNearbyCache(posts.lat, posts.lng);

      return const Success(null);
    } on PostgrestException catch (e) {
      logger.e('Failed to update post: ${e.message}');
      return Failure(e);
    }
  }

}
