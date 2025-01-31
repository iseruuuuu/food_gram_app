import 'dart:math';
import 'dart:typed_data';

import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'post_service.g.dart';

@riverpod
class PostService extends _$PostService {
  String get _currentUserId => supabase.auth.currentUser!.id;

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
      );
      return const Success(null);
    } on PostgrestException catch (e) {
      logger.e('Failed to create post: ${e.message}');
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
    };

    await supabase.from('posts').insert(post);
  }

  /// 全ての投稿を取得
  Future<List<Map<String, dynamic>>> getPosts() async {
    return supabase
        .from('posts')
        .select()
        .order('created_at', ascending: false);
  }

  /// 特定の投稿とそのユーザー情報を取得
  Future<Map<String, dynamic>> getPostData(
    List<Map<String, dynamic>> data,
    int index,
  ) async {
    final postData = {
      'id': int.parse(data[index]['id'].toString()),
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
    };

    final userData = await supabase
        .from('users')
        .select()
        .eq('user_id', data[index]['user_id'])
        .single();

    return {
      'post': postData,
      'user': userData,
    };
  }

  /// 自分の投稿のいいね数を取得
  Future<int> getHeartAmount() async {
    final response = await supabase
        .from('posts')
        .select('heart')
        .eq('user_id', _currentUserId);
    return response.fold<int>(0, (sum, post) => sum + (post['heart'] as int));
  }

  /// 特定ユーザーの投稿のいいねの合計数を取得
  Future<int> getOtherHeartAmount(String userId) async {
    final response =
        await supabase.from('posts').select('heart').eq('user_id', userId);
    return response.fold<int>(0, (sum, post) => sum + (post['heart'] as int));
  }

  /// 特定の位置の投稿を取得
  Future<List<Map<String, dynamic>>> getRestaurantPosts({
    required double lat,
    required double lng,
  }) async {
    return supabase
        .from('posts')
        .select()
        .gte('lat', lat - 0.00001)
        .lte('lat', lat + 0.00001)
        .gte('lng', lng - 0.00001)
        .lte('lng', lng + 0.00001)
        .order('created_at');
  }

  /// ランダムな投稿を取得（指定した投稿以外から3件）
  Future<List<Map<String, dynamic>>> getRandomPostsData(
    List<Map<String, dynamic>> data,
    int index,
  ) async {
    final random = Random();
    final remainingData = List<Map<String, dynamic>>.from(data)
      ..removeAt(index);
    return (remainingData..shuffle(random)).take(3).toList();
  }

  /// マップ表示用の全投稿を取得
  Future<List<Map<String, dynamic>>> getMapPosts() async {
    return supabase.from('posts').select().order('created_at');
  }

    /// 特定ユーザーの投稿を取得
  Future<List<Map<String, dynamic>>> getPostsFromUser(String userId) async {
    return supabase
        .from('posts')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }
}
