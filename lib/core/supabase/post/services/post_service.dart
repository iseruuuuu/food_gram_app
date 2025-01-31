import 'dart:typed_data';

import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'post_service.g.dart';

@riverpod
class PostService extends _$PostService {
  String? get _currentUserId => supabase.auth.currentUser?.id;

  @override
  Future<void> build() async {}

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
    if (_currentUserId == null) {
      return Failure(Exception('User not authenticated'));
    }
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

  Future<void> _uploadImage(String uploadImage, Uint8List imageBytes) async {
    await supabase.storage.from('food').uploadBinary(
          '/$_currentUserId/$uploadImage',
          imageBytes,
        );
  }

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
}
