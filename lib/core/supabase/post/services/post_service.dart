import 'dart:typed_data';

import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'post_service.g.dart';

@riverpod
class PostService extends _$PostService {
  final logger = Logger();

  String? get _currentUserId => ref.read(currentUserProvider);
  SupabaseClient get supabase => ref.read(supabaseProvider);

  @override
  Future<void> build() async {}

  /// 投稿データを作成
  Future<Result<void, Exception>> createPost({
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
      // 画像をアップロード
      final imagePath = '/$_currentUserId/$uploadImage';
      await supabase.storage.from('food').uploadBinary(imagePath, imageBytes);
      // 投稿データを作成
      final post = {
        'user_id': _currentUserId,
        'food_name': foodName,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
        'heart': 0,
        'restaurant': restaurant,
        'food_image': imagePath,
        'lat': lat,
        'lng': lng,
        'restaurant_tag': restaurantTag,
        'food_tag': foodTag,
        'is_anonymous': isAnonymous,
      };
      await supabase.from('posts').insert(post);
      return const Success(null);
    } on PostgrestException catch (e) {
      logger.e('Failed to create post: ${e.message}');
      return Failure(e);
    }
  }

  /// 投稿データを更新（データ処理）
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
        final newImagePathFull = '/$_currentUserId/$newImagePath';
        // 古い画像を削除
        await supabase.storage.from('food').remove([oldImagePath]);
        // 新しい画像をアップロード
        await supabase.storage
            .from('food')
            .uploadBinary(newImagePathFull, imageBytes);
        updates['food_image'] = newImagePathFull;
      } else {
        updates['food_image'] = posts.foodImage;
      }
      // 投稿データを更新
      await supabase.from('posts').update(updates).eq('id', posts.id);
      return const Success(null);
    } on PostgrestException catch (e) {
      logger.e('Failed to update post: ${e.message}');
      return Failure(e);
    }
  }
}
