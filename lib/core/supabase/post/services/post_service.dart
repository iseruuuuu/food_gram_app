import 'dart:math';
import 'dart:typed_data';

import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:logger/logger.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as maplibre;
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

  /// 特定の投稿のキャッシュを無効化
  void invalidatePostCache(int postId) {
    _cacheManager.invalidate('post_data_$postId');
  }

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
      invalidatePostsCache();
      if (_currentUserId != null) {
        invalidateUserCache(_currentUserId!);
      }
      return const Success(null);
    } on PostgrestException catch (e) {
      logger.e('Failed to create post: ${e.message}');
      return Failure(e);
    }
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
      invalidatePostsCache();
      if (_currentUserId != null) {
        invalidateUserCache(_currentUserId!);
      }
      invalidateRestaurantCache(posts.lat, posts.lng);
      invalidateNearbyCache(posts.lat, posts.lng);

      return const Success(null);
    } on PostgrestException catch (e) {
      logger.e('Failed to update post: ${e.message}');
      return Failure(e);
    }
  }

  /// 画像のアップロード処理
  Future<void> _uploadImage(String uploadImage, Uint8List imageBytes) async {
    await supabase.storage.from('food').uploadBinary(
          '/$_currentUserId/$uploadImage',
          imageBytes,
        );
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

  /// 全ての投稿を取得
  Future<List<Map<String, dynamic>>> getPosts() async {
    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'all_posts',
      fetcher: () =>
          supabase.from('posts').select().order('created_at', ascending: false),
      duration: const Duration(minutes: 2),
    );
  }

  /// 特定の投稿とそのユーザー情報を取得
  Future<Map<String, dynamic>> getPostData(
    List<Map<String, dynamic>> data,
    int index,
  ) async {
    final postId = data[index]['id'].toString();
    return _cacheManager.get<Map<String, dynamic>>(
      key: 'post_data_$postId',
      fetcher: () async {
        final postData = {
          'id': int.parse(postId),
          'user_id': data[index]['user_id'],
          'food_image': data[index]['food_image'],
          'food_name': data[index]['food_name'],
          'restaurant': data[index]['restaurant'],
          'comment': data[index]['comment'],
          'created_at': data[index]['created_at'],
          'lat': double.parse(data[index]['lat'].toString()),
          'lng': double.parse(data[index]['lng'].toString()),
          'heart': int.parse(data[index]['heart'].toString()),
          'restaurant_tag': data[index]['restaurant_tag'],
          'food_tag': data[index]['food_tag'],
          'is_anonymous': data[index]['is_anonymous'],
        };
        final userData = await supabase
            .from('users')
            .select()
            .eq('user_id', data[index]['user_id'] as String)
            .single();
        return {
          'post': postData,
          'user': userData,
        };
      },
      duration: const Duration(minutes: 5),
    );
  }

  /// 特定の投稿を取得
  Future<Result<Map<String, dynamic>, Exception>> getPost(int postId) async {
    try {
      return Success(
        await _cacheManager.get<Map<String, dynamic>>(
          key: 'post_data_$postId',
          fetcher: () async {
            final postData =
                await supabase.from('posts').select().eq('id', postId).single();
            final userData = await supabase
                .from('users')
                .select()
                .eq('user_id', postData['user_id'] as String)
                .single();
            return {
              'post': {
                'id': postId,
                'user_id': postData['user_id'],
                'food_image': postData['food_image'],
                'food_name': postData['food_name'],
                'restaurant': postData['restaurant'],
                'comment': postData['comment'],
                'created_at': postData['created_at'],
                'lat': double.parse(postData['lat'].toString()),
                'lng': double.parse(postData['lng'].toString()),
                'heart': int.parse(postData['heart'].toString()),
                'restaurant_tag': postData['restaurant_tag'],
                'food_tag': postData['food_tag'],
                'is_anonymous': postData['is_anonymous'],
              },
              'user': userData,
            };
          },
          duration: const Duration(minutes: 5),
        ),
      );
    } on PostgrestException catch (e) {
      logger.e('Failed to get post: ${e.message}');
      return Failure(e);
    }
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
    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'saved_posts_${postIds.join('_')}',
      fetcher: () => supabase
          .from('posts')
          .select()
          .inFilter('id', postIds)
          .order('created_at', ascending: false),
      duration: const Duration(minutes: 5),
    );
  }

  /// マップ表示用の全投稿を取得
  Future<Result<List<Map<String, dynamic>>, Exception>> getRestaurantPosts({
    required double lat,
    required double lng,
  }) async {
    try {
      return Success(
        await _cacheManager.get<List<Map<String, dynamic>>>(
          key: 'restaurant_posts_${lat}_$lng',
          fetcher: () async {
            final posts = await supabase
                .from('posts')
                .select()
                .gte('lat', lat - 0.00001)
                .lte('lat', lat + 0.00001)
                .gte('lng', lng - 0.00001)
                .lte('lng', lng + 0.00001)
                .order('created_at');
            final filteredPosts = posts
                .where(
                  (post) => !blockList.contains(post['user_id']),
                )
                .toList();
            return filteredPosts;
          },
          duration: const Duration(minutes: 5),
        ),
      );
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// マップ表示用の全投稿を取得🗾
  Future<List<Map<String, dynamic>>> getMapPosts() async {
    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'map_posts',
      fetcher: () async {
        final blockListState = ref.watch(blockListProvider);
        List<String> currentBlockList;
        if (blockListState is AsyncData<List<String>>) {
          currentBlockList = blockListState.value;
        } else {
          currentBlockList = <String>[];
        }
        final posts = await supabase.from('posts').select().order('created_at');
        return posts
            .where((post) => !currentBlockList.contains(post['user_id']))
            .toList();
      },
      duration: const Duration(minutes: 5),
    );
  }

  /// ユーザーIDからユーザーデータを取得
  Future<Map<String, dynamic>> getUserData(String userId) async {
    return _cacheManager.get<Map<String, dynamic>>(
      key: 'user_data_$userId',
      fetcher: () =>
          supabase.from('users').select().eq('user_id', userId).single(),
      duration: const Duration(minutes: 10),
    );
  }

  /// 投稿詳細画面用：ID順で次の投稿を取得
  Future<Result<List<Map<String, dynamic>>, Exception>> getSequentialPosts({
    required int currentPostId,
    int limit = 15,
  }) async {
    try {
      return Success(
        await _cacheManager.get<List<Map<String, dynamic>>>(
          key: 'sequential_posts_${currentPostId}_$limit',
          fetcher: () async {
            // 現在の投稿より小さいID（前の投稿）を取得
            final previousPosts = await supabase
                .from('posts')
                .select()
                .lt('id', currentPostId)
                .order('id', ascending: false)
                .limit(limit);

            // 現在の投稿より大きいID（次の投稿）を取得
            final nextPosts = await supabase
                .from('posts')
                .select()
                .gt('id', currentPostId)
                .order('id', ascending: true)
                .limit(limit);

            // ブロックリストのフィルタリング
            final filteredPreviousPosts = previousPosts
                .where((post) => !blockList.contains(post['user_id']))
                .toList();

            final filteredNextPosts = nextPosts
                .where((post) => !blockList.contains(post['user_id']))
                .toList();

            // 次の投稿を優先して、前の投稿を追加
            final combinedPosts = <Map<String, dynamic>>[];

            // 次の投稿を先に追加（ID昇順）
            combinedPosts.addAll(filteredNextPosts);

            // 足りない分を前の投稿から追加（ID降順）
            final remainingSlots = limit - combinedPosts.length;
            if (remainingSlots > 0) {
              combinedPosts.addAll(
                filteredPreviousPosts.take(remainingSlots),
              );
            }

            return combinedPosts.take(limit).toList();
          },
          duration: const Duration(minutes: 5),
        ),
      );
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// 投稿詳細画面用：関連する投稿のリストを取得（同じレストランの投稿など）
  Future<Result<List<Map<String, dynamic>>, Exception>> getRelatedPosts({
    required int currentPostId,
    required double lat,
    required double lng,
    int limit = 10,
  }) async {
    try {
      return Success(
        await _cacheManager.get<List<Map<String, dynamic>>>(
          key: 'related_posts_${currentPostId}_${lat}_${lng}_$limit',
          fetcher: () async {
            // 同じレストラン周辺の投稿を取得
            final posts = await supabase
                .from('posts')
                .select()
                .neq('id', currentPostId)
                .gte('lat', lat - 0.00001)
                .lte('lat', lat + 0.00001)
                .gte('lng', lng - 0.00001)
                .lte('lng', lng + 0.00001)
                .order('created_at', ascending: false)
                .limit(limit);

            // ブロックリストのフィルタリング
            final filteredPosts = posts
                .where((post) => !blockList.contains(post['user_id']))
                .toList();

            return filteredPosts;
          },
          duration: const Duration(minutes: 5),
        ),
      );
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// 現在地から近い投稿を10件取得
  Future<List<Map<String, dynamic>>> getNearbyPosts() async {
    final currentLocation = await ref.read(locationProvider.future);
    if (currentLocation == const maplibre.LatLng(0, 0)) {
      return [];
    }
    final lat = currentLocation.latitude;
    final lng = currentLocation.longitude;

    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'nearby_posts_${lat}_$lng',
      fetcher: () async {
        final posts = await supabase
            .from('posts')
            .select()
            .order('created_at', ascending: false);
        final filteredPosts = posts
            .where((post) => !blockList.contains(post['user_id']))
            .toList();
        final uniqueLocationPosts = <String, Map<String, dynamic>>{};
        for (final post in filteredPosts) {
          final locationKey = '${post['lat']}_${post['lng']}';
          if (!uniqueLocationPosts.containsKey(locationKey)) {
            uniqueLocationPosts[locationKey] = post;
          }
        }

        final postsWithDistance = uniqueLocationPosts.values.map((post) {
          final distance = _calculateDistance(
            lat,
            lng,
            double.parse(post['lat'].toString()),
            double.parse(post['lng'].toString()),
          );
          return {...post, 'distance': distance};
        }).toList()
          ..sort(
            (a, b) =>
                (a['distance'] as double).compareTo(b['distance'] as double),
          );

        return postsWithDistance.take(10).map((post) {
          final result = Map<String, dynamic>.from(post)..remove('distance');
          return result;
        }).toList();
      },
      duration: const Duration(minutes: 5),
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

  /// 度からラジアンに変換
  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  /// キャッシュを無効化するメソッド
  void invalidatePostsCache() {
    _cacheManager
      ..invalidate('all_posts')
      ..invalidate('map_posts')
      ..invalidate('ramen_posts');
    if (_currentUserId != null) {
      _cacheManager.invalidate('heart_amount_${_currentUserId!}');
    }
  }

  void invalidateUserCache(String userId) {
    _cacheManager
      ..invalidate('user_posts_$userId')
      ..invalidate('user_data_$userId')
      ..invalidate('heart_amount_$userId')
      ..invalidate('post_count_$userId');
  }

  void invalidateRestaurantCache(double lat, double lng) {
    _cacheManager
      ..invalidate('restaurant_posts_${lat}_$lng')
      ..invalidate('restaurant_reviews_${lat}_$lng')
      ..invalidate('story_posts_${lat}_$lng');
  }

  void invalidateNearbyCache(double lat, double lng) {
    _cacheManager.invalidate('nearby_posts_${lat}_$lng');
  }
}
