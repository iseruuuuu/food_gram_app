import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'account_service.g.dart';

@riverpod
AccountService accountService(Ref ref) => AccountService(ref);

class AccountService {
  AccountService(this.ref);

  final logger = Logger();

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
      'last_post_date': null,
      'streak_weeks': 0,
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
      final userData = await _getCurrentUserData();
      final updates = _createBaseUpdates(
        name: name,
        userName: userName,
        selfIntroduce: selfIntroduce,
        favoriteTags: favoriteTags,
      );

      await _handleImageUpdateIfNeeded(
        updates: updates,
        userData: userData,
        image: image,
        imageBytes: imageBytes,
        uploadImage: uploadImage,
      );

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

  Future<Map<String, dynamic>> _getCurrentUserData() async {
    final userData = await supabase
        .from('users')
        .select('is_subscribe, image')
        .eq('user_id', _currentUserId!)
        .single();
    return userData;
  }

  Map<String, dynamic> _createBaseUpdates({
    required String name,
    required String userName,
    required String selfIntroduce,
    required String favoriteTags,
  }) {
    return {
      'name': name,
      'user_name': userName,
      'self_introduce': selfIntroduce,
      'updated_at': DateTime.now().toIso8601String(),
      'tag': favoriteTags,
    };
  }

  Future<void> _handleImageUpdateIfNeeded({
    required Map<String, dynamic> updates,
    required Map<String, dynamic> userData,
    required String image,
    Uint8List? imageBytes,
    String? uploadImage,
  }) async {
    final isSubscribe = userData['is_subscribe'] as bool;
    final currentImage = userData['image'] as String;

    if (_shouldUpdateWithUploadedImage(uploadImage, imageBytes)) {
      await _handleImageUpdate(uploadImage!, imageBytes!);
      updates['image'] = '/$_currentUserId/$uploadImage';
    } else if (_shouldUpdateWithIcon(image, currentImage)) {
      updates['image'] = 'assets/icon/icon$image.png';
    } else if (!isSubscribe) {
      updates['image'] = 'assets/icon/icon$image.png';
    }
  }

  bool _shouldUpdateWithUploadedImage(
    String? uploadImage,
    Uint8List? imageBytes,
  ) {
    return uploadImage != null && uploadImage.isNotEmpty && imageBytes != null;
  }

  bool _shouldUpdateWithIcon(String image, String currentImage) {
    return image != '0' && !currentImage.startsWith('/');
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
