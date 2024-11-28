import 'dart:typed_data';

import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'post_service.g.dart';

@riverpod
PostService postService(PostServiceRef ref) => PostService();

class PostService {
  PostService();

  final user = supabase.auth.currentUser?.id;

  Future<Result<void, Exception>> post({
    required String foodName,
    required String comment,
    required String uploadImage,
    required Uint8List imageBytes,
    required double lat,
    required double lng,
    required String restaurant,
    required String restaurantTag,
    required String foodTag,
  }) async {
    try {
      final updates = {
        'user_id': user,
        'food_name': foodName,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
        'heart': 0,
        'restaurant': restaurant,
        'food_image': '/$user/$uploadImage',
        'lat': lat,
        'lng': lng,
        'restaurant_tag': restaurantTag,
        'food_tag': foodTag,
      };
      await _upload(uploadImage: uploadImage, imageBytes: imageBytes);
      await supabase.from('posts').insert(updates);
      await Future.delayed(Duration(seconds: 2));
      return const Success(null);
    } on PostgrestException catch (error) {
      logger.e(error.message);
      return Failure(error);
    } on Exception catch (error) {
      logger.e(error);
      return Failure(error);
    }
  }

  Future<void> _upload({
    required String uploadImage,
    required Uint8List imageBytes,
  }) async {
    await supabase.storage
        .from('food')
        .uploadBinary('/$user/$uploadImage', imageBytes);
  }
}
