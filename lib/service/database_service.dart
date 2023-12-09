import 'dart:typed_data';

import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/model/result.dart';
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
  }) async {
    try {
      final updates = {
        'user_id': user,
        'food_name': foodName,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
        'heart': 0,
        //TODO あとでレストラン名を入れる
        'restaurant': '吉野家',
        'food_image': '/$user/$uploadImage',
        //TODO　あとでレストランからの座標を入れる
        'lat': 0.1,
        //TODO　あとでレストランからの座標を入れる
        'lng': 0.1,
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

  Future<void> upload({
    required String uploadImage,
    required Uint8List imageBytes,
  }) async {
    await supabase.storage
        .from('food')
        .uploadBinary('/$user/$uploadImage', imageBytes);
  }

  Future<Result<void, Exception>> delete(int id) async {
    try {
      await supabase.from('posts').delete().eq('id', id);
      return const Success(null);
    } on PostgrestException catch (error) {
      logger.e(error.message);
      return Failure(error);
    }
  }
}
