import 'dart:typed_data';

import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'database_service.g.dart';

@riverpod
DatabaseService databaseService(DatabaseServiceRef ref) => DatabaseService();

class DatabaseService {
  DatabaseService();

  final user = supabase.auth.currentUser?.id;

  Future<Result<void, Exception>> post({
    required String foodName,
    required String comment,
    required String uploadImage,
    required Uint8List imageBytes,
    required double lat,
    required double lng,
    required String restaurant,
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
      };
      await upload(uploadImage: uploadImage, imageBytes: imageBytes);
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

  Future<Result<void, Exception>> setUsers({
    required String name,
    required String userName,
    required int image,
  }) async {
    final updates = {
      'name': name,
      'user_name': userName,
      'self_introduce': '',
      'image': 'assets/icon/icon$image.png',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'exchanged_point': 0,
    };
    try {
      await supabase.from('users').insert(updates);
      await Future.delayed(Duration(seconds: 2));
      return const Success(null);
    } on PostgrestException catch (error) {
      logger.e(error.message);
      return Failure(error);
    }
  }

  Future<void> upload({
    required String uploadImage,
    required Uint8List imageBytes,
  }) async {
    await supabase.storage
        .from('food')
        .uploadBinary('/$user/$uploadImage', imageBytes);
  }

  Future<Result<void, Exception>> delete(Posts posts) async {
    try {
      final deleteImage = posts.foodImage.substring(1);
      await supabase.storage.from('food').remove([deleteImage]);
      await supabase.from('posts').delete().eq('id', posts.id);
      return const Success(null);
    } on PostgrestException catch (error) {
      logger.e(error.message);
      return Failure(error);
    }
  }
}
