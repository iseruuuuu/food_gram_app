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
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      return Failure(Exception('User not authenticated'));
    }

    try {
      final res = await supabase.functions.invoke(
        'user-create',
        body: {
          'name': name,
          'user_name': userName,
          'image': image,
        },
      );
      final data = res.data;
      final ok = data is Map<String, dynamic> && data['ok'] == true;
      if (!ok) {
        final errorMsg = data is Map<String, dynamic>
            ? (data['error']?.toString() ?? 'status: ${res.status}')
            : 'status: ${res.status}';
        logger.e('Failed to create user via function: $errorMsg');
        return Failure(Exception(errorMsg));
      }
      return const Success(null);
    } on FunctionException catch (error) {
      final msg = error.reasonPhrase ?? error.details ?? error;
      logger.e('Failed to invoke user-create: $msg');
      return Failure(Exception(msg.toString()));
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

    String? uploadedAvatarPath;
    try {
      final userData = await _getCurrentUserData();
      final updates = _createBaseUpdates(
        name: name,
        userName: userName,
        selfIntroduce: selfIntroduce,
        favoriteTags: favoriteTags,
      );
      uploadedAvatarPath = await _handleImageUpdateIfNeeded(
        updates: updates,
        userData: userData,
        image: image,
        imageBytes: imageBytes,
        uploadImage: uploadImage,
      );
      final payload = <String, dynamic>{
        'user_id': _currentUserId,
        'name': updates['name'],
        'user_name': updates['user_name'],
        'self_introduce': updates['self_introduce'],
        'tag': updates['tag'],
      };
      if (updates.containsKey('image')) {
        payload['image'] = updates['image'];
      }
      final res = await supabase.functions.invoke(
        'account-update',
        body: payload,
      );
      final data = res.data;
      final ok = data is Map<String, dynamic> && data['ok'] == true;
      if (!ok) {
        final errorMsg = data is Map<String, dynamic>
            ? (data['error']?.toString() ?? 'status: ${res.status}')
            : 'status: ${res.status}';
        await _rollbackUploadedAvatar(uploadedAvatarPath);
        logger.e('Failed to update user via function: $errorMsg');
        return Failure(Exception(errorMsg));
      }
      return const Success(null);
    } on PostgrestException catch (error) {
      logger.e('Failed to update user: ${error.message}');
      return Failure(error);
    } on FunctionException catch (error) {
      final msg = error.reasonPhrase ?? error.details ?? error;
      logger.e('Failed to invoke account-update: $msg');
      // 502/504 等でサーバーは更新済みの可能性があるため、DB を確認してからロールバック
      final applied = await _didServerApplyAvatarUpdate(uploadedAvatarPath);
      if (!applied) {
        await _rollbackUploadedAvatar(uploadedAvatarPath);
      }
      return Failure(Exception(msg.toString()));
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

  /// 新規アップロードしたアバターのストレージパス（先頭スラッシュなし）を返す。
  /// 関数失敗時のロールバック用。アップロードしていなければ null。
  Future<String?> _handleImageUpdateIfNeeded({
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
      return '$_currentUserId/$uploadImage';
    }
    if (_shouldUpdateWithIcon(image, currentImage)) {
      updates['image'] = 'assets/icon/icon$image.png';
    } else if (!isSubscribe) {
      updates['image'] = 'assets/icon/icon$image.png';
    }
    return null;
  }

  /// FunctionException 時、サーバー側で更新が適用済みかどうかを DB の image で判定する。
  /// 適用済みなら true（ロールバックしない）、未適用なら false（ロールバックしてよい）。
  Future<bool> _didServerApplyAvatarUpdate(String? uploadedAvatarPath) async {
    if (uploadedAvatarPath == null || uploadedAvatarPath.isEmpty) {
      return false;
    }
    try {
      final row = await supabase
          .from('users')
          .select('image')
          .eq('user_id', _currentUserId!)
          .maybeSingle();
      final currentImage = row?['image'] as String?;
      return currentImage == '/$uploadedAvatarPath';
    } on PostgrestException catch (_) {
      return false;
    }
  }

  Future<void> _rollbackUploadedAvatar(String? storagePath) async {
    if (storagePath == null || storagePath.isEmpty) {
      return;
    }
    try {
      await supabase.storage.from('user').remove([storagePath]);
    } on StorageException catch (e) {
      logger.e('Failed to rollback uploaded avatar: ${e.message}');
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
    if (supabase.auth.currentUser?.id == null) {
      return Failure(Exception('User not authenticated'));
    }
    try {
      final res = await supabase.functions.invoke('user-subscribe');
      final data = res.data;
      final ok = data is Map<String, dynamic> && data['ok'] == true;
      if (!ok) {
        final errorMsg = data is Map<String, dynamic>
            ? (data['error']?.toString() ?? 'status: ${res.status}')
            : 'status: ${res.status}';
        logger.e('Failed to update subscription via function: $errorMsg');
        return Failure(Exception(errorMsg));
      }
      return const Success(null);
    } on FunctionException catch (error) {
      final msg = error.reasonPhrase ?? error.details ?? error;
      logger.e('Failed to invoke user-subscribe: $msg');
      return Failure(Exception(msg.toString()));
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
