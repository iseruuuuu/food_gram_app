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

  /// 画像をストレージにアップロードし、投稿データをデータベースに挿入する
  Future<Result<void, Exception>> createPost({
    required String foodName,
    required String comment,
    required List<String> uploadImages,
    required Map<String, Uint8List> imageBytesMap,
    required String restaurant,
    required double lat,
    required double lng,
    required String foodTag,
    required double star,
    required bool isAnonymous,
  }) async {
    try {
      // 複数画像をアップロード
      final imagePaths = <String>[];
      for (final uploadImage in uploadImages) {
        final fileName = uploadImage.split('/').last;
        final imagePath = '/$_currentUserId/$fileName';
        final imageBytes = imageBytesMap[uploadImage];
        if (imageBytes != null) {
          await supabase.storage.from('food').uploadBinary(
                imagePath,
                imageBytes,
                fileOptions: const FileOptions(
                  upsert: true,
                  contentType: 'image/jpeg',
                ),
              );
          imagePaths.add(imagePath);
        }
      }
      // カンマ区切りで保存
      final foodImage = imagePaths.join(',');
      // 投稿データを作成
      final post = {
        'user_id': _currentUserId,
        'food_name': foodName,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
        'heart': 0,
        'restaurant': restaurant,
        'food_image': foodImage,
        'lat': lat,
        'lng': lng,
        'restaurant_tag': '',
        'food_tag': foodTag,
        'star': star,
        'is_anonymous': isAnonymous,
      };

      // 投稿の insert は Edge Function 経由で行う
      final res = await supabase.functions.invoke(
        'post-create',
        body: post,
      );
      final data = res.data;
      final ok = data is Map<String, dynamic> && data['ok'] == true;
      if (!ok) {
        final errorMsg = data is Map<String, dynamic>
            ? (data['error']?.toString() ?? 'status: ${res.status}')
            : 'status: ${res.status}';
        logger.e('Failed to create post via function: $errorMsg');
        return Failure(Exception(errorMsg));
      }

      return const Success(null);
    } on StorageException catch (e) {
      logger.e('Failed to upload images: ${e.message}');
      return Failure(e);
    } on Exception catch (e) {
      logger.e('Failed to create post: $e');
      return Failure(e);
    }
  }

  /// 投稿データを更新
  Future<Result<void, Exception>> updatePost({
    required Posts posts,
    required String foodName,
    required String comment,
    required String restaurant,
    required String foodTag,
    required double lat,
    required double lng,
    required double star,
    required bool isAnonymous,
    required List<String> newImagePaths,
    required Map<String, Uint8List> imageBytesMap,
    required List<String> existingImagePaths,
  }) async {
    try {
      // 変更がある場合は更新用のマップを作成
      final updates = {
        'food_name': foodName,
        'comment': comment,
        'restaurant': restaurant,
        'restaurant_tag': '',
        'food_tag': foodTag,
        'lat': lat,
        'lng': lng,
        'star': star,
        'is_anonymous': isAnonymous,
      };

      // 新しい画像をアップロード
      final newUploadedPaths = <String>[];
      for (final imagePath in newImagePaths) {
        final fileName = imagePath.split('/').last;
        final storagePath = '/$_currentUserId/$fileName';
        final imageBytes = imageBytesMap[imagePath];
        if (imageBytes != null) {
          try {
            await supabase.storage.from('food').uploadBinary(
                  storagePath,
                  imageBytes,
                  fileOptions: const FileOptions(
                    upsert: true,
                    contentType: 'image/jpeg',
                  ),
                );
            newUploadedPaths.add(storagePath);
          } on StorageException catch (e) {
            logger.e('Failed to upload image $imagePath: ${e.message}');
            // アップロードに失敗した画像はスキップ
          }
        }
      }

      // 既存の画像パスと新しい画像パスを結合
      final allImagePaths = [...existingImagePaths, ...newUploadedPaths];
      final foodImage = allImagePaths.join(',');
      updates['food_image'] = foodImage;

      // 旧画像を削除（既存画像から削除されたもの）
      final oldImagePaths = posts.foodImage.isNotEmpty
          ? posts.foodImage.split(',').where((path) => path.isNotEmpty).toList()
          : <String>[];
      final imagesToDelete = oldImagePaths
          .where((oldPath) => !existingImagePaths.contains(oldPath))
          .map((path) => path.startsWith('/') ? path.substring(1) : path)
          .where((path) => path.isNotEmpty)
          .toList();

      if (imagesToDelete.isNotEmpty) {
        try {
          await supabase.storage.from('food').remove(imagesToDelete);
        } on StorageException catch (e) {
          logger.e('Failed to delete old images: ${e.message}');
          // 削除に失敗しても続行
        }
      }
      // Edge Function 経由で投稿データを更新
      final payload = {'post_id': posts.id, ...updates};
      final res = await supabase.functions.invoke('post-update', body: payload);
      final data = res.data;
      final isHttpSuccess = res.status >= 200 && res.status < 300;
      var ok = false;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('ok')) {
          ok = data['ok'] == true;
        } else {
          ok = isHttpSuccess;
        }
      } else {
        ok = isHttpSuccess;
      }
      if (!ok) {
        final errorMsg = data is Map<String, dynamic>
            ? (data['error']?.toString() ?? 'status: ${res.status}')
            : 'status: ${res.status}';
        logger.e('Failed to update post via function: $errorMsg');
        return Failure(Exception(errorMsg));
      }
      return const Success(null);
    } on Exception catch (e) {
      logger.e('Failed to update post: $e');
      return Failure(e);
    }
  }
}
