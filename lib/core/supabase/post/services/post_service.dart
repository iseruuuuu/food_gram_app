import 'dart:math';
import 'dart:typed_data';

import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/main.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as maplibre;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'post_service.g.dart';

@riverpod
class PostService extends _$PostService {
  String? get _currentUserId => ref.read(currentUserProvider);

  SupabaseClient get supabase => ref.read(supabaseProvider);

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
        .eq('user_id', _currentUserId!);
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

  /// マップ表示用の全投稿を取得
  Future<List<Map<String, dynamic>>> getMapPosts() async {
    return supabase.from('posts').select().order('created_at');
  }

  /// カテゴリーが🍜の投稿を取得
  Future<List<Map<String, dynamic>>> getRamenMapPosts() async {
    return supabase
        .from('posts')
        .select()
        .eq('food_tag', '🍜')
        .order('created_at', ascending: false);
  }

  /// 特定ユーザーの投稿を取得
  Future<List<Map<String, dynamic>>> getPostsFromUser(String userId) async {
    return supabase
        .from('posts')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  /// ユーザーIDからユーザーデータを取得
  Future<Map<String, dynamic>> getUserData(String userId) async {
    final response =
        await supabase.from('users').select().eq('user_id', userId).single();
    return response;
  }

  /// 現在地から近い投稿を10件取得（同じ位置の投稿は最新のもののみ）
  Future<List<Map<String, dynamic>>> getNearbyPosts() async {
    final posts = await supabase
        .from('posts')
        .select()
        .order('created_at', ascending: false);
    final currentLocationFuture = ref.read(locationProvider.future);
    final currentLocation = await currentLocationFuture;
    if (currentLocation == maplibre.LatLng(0, 0)) {
      return [];
    }

    // 同じ位置の投稿をフィルタリング（最新のもののみ残す）
    final uniqueLocationPosts = <String, Map<String, dynamic>>{};
    for (final post in posts) {
      final locationKey = '${post['lat']}_${post['lng']}';
      if (!uniqueLocationPosts.containsKey(locationKey)) {
        uniqueLocationPosts[locationKey] = post;
      }
    }

    /// 各投稿に現在地からの距離を計算して追加
    final postsWithDistance = uniqueLocationPosts.values.map((post) {
      final distance = _calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        double.parse(post['lat'].toString()),
        double.parse(post['lng'].toString()),
      );
      return {...post, 'distance': distance};
    }).toList()
      ..sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
      );
    return postsWithDistance.take(10).map((post) {
      final result = Map<String, dynamic>.from(post)..remove('distance');
      return result;
    }).toList();
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
}
