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

  /// 全ての投稿を取得
  Future<List<Map<String, dynamic>>> getPosts() async {
    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'all_posts',
      fetcher: () =>
          supabase.from('posts').select().order('created_at', ascending: false),
      duration: const Duration(minutes: 2),
    );
  }

  /// 自分の全投稿に対するいいね数の合計を取得
  Future<int> getHeartAmount() async {
    return _cacheManager.get<int>(
      key: 'heart_amount_${_currentUserId!}',
      fetcher: () async {
        final response = await supabase
            .from('posts')
            .select('heart')
            .eq('user_id', _currentUserId!);
        return response.fold<int>(
          0,
          (sum, post) => sum + (post['heart'] as int),
        );
      },
      duration: const Duration(minutes: 2),
    );
  }

  /// 特定ユーザーの投稿のいいねの合計数を取得
  Future<int> getOtherHeartAmount(String userId) async {
    return _cacheManager.get<int>(
      key: 'heart_amount_$userId',
      fetcher: () async {
        final response =
            await supabase.from('posts').select('heart').eq('user_id', userId);
        return response.fold<int>(
          0,
          (sum, post) => sum + (post['heart'] as int),
        );
      },
      duration: const Duration(minutes: 2),
    );
  }

  /// 特定ユーザーの投稿を取得
  Future<List<Map<String, dynamic>>> getPostsFromUser(String userId) async {
    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'user_posts_$userId',
      fetcher: () => supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .eq('is_anonymous', false)
          .order('created_at', ascending: false),
      duration: const Duration(minutes: 5),
    );
  }

  /// 保存した投稿IDのリストから投稿を取得
  Future<List<Map<String, dynamic>>> getStoredPosts(
    List<String> postIds,
  ) async {
    if (postIds.isEmpty) {
      return [];
    }
    // 数値IDへ変換（無効なIDは除外）
    final intIds =
        postIds.map(int.tryParse).whereType<int>().toList(growable: false);
    if (intIds.isEmpty) {
      return [];
    }
    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'saved_posts_${intIds.join('_')}',
      fetcher: () => supabase
          .from('posts')
          .select()
          .inFilter('id', intIds)
          .order('created_at', ascending: false),
      duration: const Duration(minutes: 5),
    );
  }

  /// レストラン名で投稿を取得（新しい順）
  Future<List<Map<String, dynamic>>> getPostsByRestaurantName(
    String restaurant,
  ) async {
    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'restaurant_name_posts_$restaurant',
      fetcher: () async {
        final posts = await supabase
            .from('posts')
            .select()
            .eq('restaurant', restaurant)
            .order('created_at', ascending: false);
        return posts
            .where((post) => !blockList.contains(post['user_id']))
            .toList();
      },
      duration: const Duration(minutes: 5),
    );
  }
}
