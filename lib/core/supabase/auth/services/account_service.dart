import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'account_service.g.dart';

@riverpod
AccountService accountService(Ref ref) => AccountService(ref);

class AccountService {
  AccountService(this.ref);

  final Ref ref;

  String? get _currentUserId => ref.read(currentUserProvider);

  SupabaseClient get supabase => ref.read(supabaseProvider);

  Future<Result<void, Exception>> createUsers({
    required String name,
    required String userName,
    required int image,
  }) async {
    final updates = {
      'user_id': _currentUserId,
      'name': name,
      'user_name': userName,
      'self_introduce': '',
      'image': 'assets/icon/icon$image.png',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'exchanged_point': 0,
      'is_subscribe': false,
      'tag': '',
    };

    try {
      await supabase.from('users').insert(updates);
      return const Success(null);
    } on PostgrestException catch (error) {
      logger.e('Failed to create user: ${error.message}');
      return Failure(error);
    }
  }

  Future<Result<void, Exception>> update({
    required String name,
    required String userName,
    required String selfIntroduce,
    required String image,
    required String favoriteTags,
    Uint8List? imageBytes,
    String? uploadImage,
  }) async {
    if (_currentUserId == null) {
      return Failure(Exception('User not authenticated'));
    }
    try {
      final updates = {
        'name': name,
        'user_name': userName,
        'self_introduce': selfIntroduce,
        'image': _getImagePath(image, uploadImage),
        'updated_at': DateTime.now().toIso8601String(),
        'tag': favoriteTags,
      };

      if (uploadImage != null && uploadImage.isNotEmpty && imageBytes != null) {
        await _handleImageUpdate(uploadImage, imageBytes);
      }

      await supabase
          .from('users')
          .update(updates)
          .match({'user_id': _currentUserId!});
      return const Success(null);
    } on PostgrestException catch (error) {
      logger.e('Failed to update user: ${error.message}');
      return Failure(error);
    }
  }

  String _getImagePath(String image, String? uploadImage) {
    if (uploadImage == null || uploadImage.isEmpty) {
      return 'assets/icon/icon$image.png';
    }
    return '/$_currentUserId/$uploadImage';
  }

  Future<void> _handleImageUpdate(
    String uploadImage,
    Uint8List imageBytes,
  ) async {
    final userData = await supabase
        .from('users')
        .select('image')
        .eq('user_id', _currentUserId!)
        .single();

    final currentImage = userData['image'] as String?;
    if (currentImage != null && currentImage.startsWith('/')) {
      final deleteImagePath = currentImage.substring(1);
      await supabase.storage.from('user').remove([deleteImagePath]);
    }

    await _upload(uploadImage: uploadImage, imageBytes: imageBytes);
  }

  Future<void> _upload({
    required String uploadImage,
    required Uint8List imageBytes,
  }) async {
    await supabase.storage
        .from('user')
        .uploadBinary('/$_currentUserId/$uploadImage', imageBytes);
  }

  Future<Result<void, Exception>> updateIsSubscribe() async {
    if (_currentUserId == null) {
      return Failure(Exception('User not authenticated'));
    }
    try {
      await supabase
          .from('users')
          .update({'is_subscribe': true}).match({'user_id': _currentUserId!});
      return const Success(null);
    } on PostgrestException catch (error) {
      logger.e('Failed to update subscription: ${error.message}');
      return Failure(error);
    }
  }

  Future<bool> isUserRegistered() async {
    if (_currentUserId == null) {
      return false;
    }
    final response = await supabase
        .from('users')
        .select()
        .eq('user_id', _currentUserId!)
        .count();
    return response.data.isNotEmpty;
  }
}
