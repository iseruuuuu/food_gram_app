import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:food_gram_app/core/home_widget/map_stats_home_widget_sync.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:home_widget/home_widget.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 最近の自分の投稿（料理写真・店名・料理名・日付）を iOS ホームウィジェット（RecentPostWidget）へ同期する。
///
/// 画像は WidgetKit のメモリ制限（約 30MB）を超えないよう 600px 以下・JPEG 品質 80 に縮小し、
/// App Group コンテナ（`group.com.FoodGram.ios`）に保存してパスを `UserDefaults` に書き込む。
class RecentPostHomeWidgetSync {
  RecentPostHomeWidgetSync._();

  static final _log = Logger();

  static const appGroupId = MapStatsHomeWidgetSync.appGroupId;
  static const iosWidgetKind = 'RecentPostWidget';
  static const payloadKey = 'recent_post_payload';
  static const _cachedStorageKeyPref = 'recent_post_cached_storage_key';
  static const _imageBase64Pref = 'recent_post_image_base64';

  static const _syncDebounceDuration = Duration(milliseconds: 500);
  static const _maxThumbnailDimension = 600;
  static const _jpegQuality = 80;

  static Timer? _debounceTimer;
  static List<Posts>? _pendingPosts;
  static Future<void>? _syncChain;

  /// 投稿一覧から最新の画像付き投稿を選び、非同期（デバウンス付き）でウィジェットへ同期する。
  static void scheduleSyncFromPosts(List<Posts> posts) {
    if (!Platform.isIOS) {
      return;
    }
    _pendingPosts = List<Posts>.from(posts);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_syncDebounceDuration, () {
      _debounceTimer = null;
      final latestPosts = _pendingPosts;
      _pendingPosts = null;
      if (latestPosts == null) {
        return;
      }
      _syncChain = (_syncChain ?? Future<void>.value()).then(
        (_) => syncFromPosts(latestPosts),
      );
      unawaited(_syncChain);
    });
  }

  /// 投稿一覧から最新の自分の投稿をウィジェットに反映する。
  static Future<void> syncFromPosts(List<Posts> posts) async {
    if (!Platform.isIOS) {
      return;
    }
    try {
      final latest = _pickLatestPostWithImage(posts);
      if (latest == null) {
        await _clearCachedThumbnailInAppGroup();
        await HomeWidget.saveWidgetData<String?>(payloadKey, null);
        await HomeWidget.updateWidget(
          name: iosWidgetKind,
          iOSName: iosWidgetKind,
        );
        return;
      }

      final storageKey = latest.firstFoodImage;
      final publicUrl = storageKey.isEmpty
          ? ''
          : Supabase.instance.client.storage
              .from('food')
              .getPublicUrl(storageKey);

      final imageFileName = await _ensureThumbnailInAppGroup(
        postId: latest.id,
        storageKey: storageKey,
        imageUrl: publicUrl,
      );

      final locale = LocaleSettings.currentLocale;
      final localeTag =
          (locale.countryCode != null && locale.countryCode!.isNotEmpty)
              ? '${locale.languageCode}_${locale.countryCode}'
              : locale.languageCode;
      final formattedDate = DateFormat.yMMMd(localeTag).format(
        latest.createdAt.toLocal(),
      );

      final payload = <String, dynamic>{
        'postId': latest.id,
        'restaurant': latest.restaurant.trim(),
        'foodName': latest.foodName.trim(),
        'foodTag': latest.foodTag.trim(),
        'star': latest.star,
        'createdAtDisplay': formattedDate,
        'imageFileName': imageFileName,
        'imageUrl': publicUrl,
      };

      await HomeWidget.saveWidgetData<String>(
        payloadKey,
        jsonEncode(payload),
      );
      await HomeWidget.updateWidget(
        name: iosWidgetKind,
        iOSName: iosWidgetKind,
      );
    } on Exception catch (e, st) {
      _log.w(
        'RecentPostHomeWidgetSync.syncFromPosts failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  static Posts? _pickLatestPostWithImage(List<Posts> posts) {
    if (posts.isEmpty) {
      return null;
    }
    final withImages = posts.where((p) => p.firstFoodImage.isNotEmpty).toList();
    final candidates = withImages.isNotEmpty ? withImages : posts;
    candidates.sort((a, b) {
      final cmp = b.createdAt.compareTo(a.createdAt);
      if (cmp != 0) {
        return cmp;
      }
      return b.id.compareTo(a.id);
    });
    return candidates.first;
  }

  /// App Group 内の UserDefaults に縮小 JPEG（Base64）も保持しつつ、
  /// Swift 側で即座に描画できるようにする。
  static Future<String?> _ensureThumbnailInAppGroup({
    required int postId,
    required String storageKey,
    required String imageUrl,
  }) async {
    if (storageKey.isEmpty || imageUrl.isEmpty) {
      await _clearCachedThumbnailInAppGroup();
      return null;
    }
    try {
      final cachedKey = await HomeWidget.getWidgetData<String>(
        _cachedStorageKeyPref,
      );
      final cachedBase64 = await HomeWidget.getWidgetData<String>(
        _imageBase64Pref,
      );
      if (cachedKey == storageKey &&
          cachedBase64 != null &&
          cachedBase64.isNotEmpty) {
        return 'cached_$postId.jpg';
      }

      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);
      try {
        final request = await client.getUrl(Uri.parse(imageUrl));
        final response =
            await request.close().timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) {
          await _clearCachedThumbnailInAppGroup();
          return null;
        }
        final bytes = await _consolidateBytes(response);
        if (bytes.isEmpty) {
          await _clearCachedThumbnailInAppGroup();
          return null;
        }
        final resizedBytes = _resizeForWidget(bytes);
        final base64Image = base64Encode(resizedBytes);
        await HomeWidget.saveWidgetData<String>(
          _imageBase64Pref,
          base64Image,
        );
        await HomeWidget.saveWidgetData<String>(
          _cachedStorageKeyPref,
          storageKey,
        );
        return 'cached_$postId.jpg';
      } finally {
        client.close();
      }
    } on Object catch (e, st) {
      _log.w(
        'RecentPostHomeWidgetSync thumbnail download failed',
        error: e,
        stackTrace: st,
      );
      await _clearCachedThumbnailInAppGroup();
      return null;
    }
  }

  static Future<void> _clearCachedThumbnailInAppGroup() async {
    try {
      await HomeWidget.saveWidgetData<String?>(_imageBase64Pref, null);
      await HomeWidget.saveWidgetData<String?>(_cachedStorageKeyPref, null);
    } on Object catch (e, st) {
      _log.w(
        'RecentPostHomeWidgetSync clear cached thumbnail failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  static Future<List<int>> _consolidateBytes(
    HttpClientResponse response,
  ) async {
    final chunks = <List<int>>[];
    await response.forEach(chunks.add);
    return chunks.expand((e) => e).toList();
  }

  static List<int> _resizeForWidget(List<int> rawBytes) {
    try {
      final decoded = img.decodeImage(
        rawBytes is Uint8List ? rawBytes : Uint8List.fromList(rawBytes),
      );
      if (decoded == null) {
        return rawBytes;
      }
      final baked = img.bakeOrientation(decoded);
      final img.Image target;
      if (baked.width <= _maxThumbnailDimension &&
          baked.height <= _maxThumbnailDimension) {
        target = baked;
      } else if (baked.width >= baked.height) {
        target = img.copyResize(
          baked,
          width: _maxThumbnailDimension,
          interpolation: img.Interpolation.average,
        );
      } else {
        target = img.copyResize(
          baked,
          height: _maxThumbnailDimension,
          interpolation: img.Interpolation.average,
        );
      }
      return img.encodeJpg(target, quality: _jpegQuality);
    } on Object {
      return rawBytes;
    }
  }
}
