import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'account_service.g.dart';

@riverpod
AccountService accountService(Ref ref) => AccountService();

class AccountService {
  AccountService();

  Future<Result<void, Exception>> createUsers({
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
      await Future.delayed(Duration(seconds: 1));
      return const Success(null);
    } on PostgrestException catch (error) {
      logger.e(error.message);
      return Failure(error);
    }
  }

  Future<Result<void, Exception>> update({
    required String name,
    required String userName,
    required String selfIntroduce,
    required String image,
    Uint8List? imageBytes,
    String? uploadImage,
  }) async {
    final user = supabase.auth.currentUser;
    final updates = {
      'name': name,
      'user_name': userName,
      'self_introduce': selfIntroduce,
      'image': (uploadImage == '')
          ? 'assets/icon/icon$image.png'
          : '/${user!.id}/$uploadImage',
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      if (uploadImage != '' && imageBytes != null) {
        await _upload(uploadImage: uploadImage!, imageBytes: imageBytes);
        final userData = await supabase
            .from('users')
            .select('image')
            .eq('user_id', user!.id)
            .single();
        final currentImage = userData['image'] as String?;
        final deleteImagePath = currentImage!.startsWith('/')
            ? currentImage.substring(1)
            : currentImage;
        await supabase.storage.from('user').remove([deleteImagePath]);
      }
      await supabase.from('users').update(updates).match({'user_id': user!.id});
      return const Success(null);
    } on PostgrestException catch (error) {
      logger.e(error.message);
      return Failure(error);
    }
  }

  Future<void> _upload({
    required String uploadImage,
    required Uint8List imageBytes,
  }) async {
    final user = supabase.auth.currentUser?.id;
    await supabase.storage
        .from('user')
        .uploadBinary('/$user/$uploadImage', imageBytes);
  }
}
