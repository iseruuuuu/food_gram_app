import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as fcm;
import 'package:logger/logger.dart';

/// 画像ディスクキャッシュ。
///
/// - 起動・バックグラウンド復帰では消さない（再ダウンロードで真っ白になるのを防ぐ）
/// - 件数と期限で上限をかけ、古いものから自動削除する
/// - 設定の「キャッシュ削除」でのみ空にする
///
/// [clear] は呼び出し時点のエントリを削除する。進行中のダウンロード自体は
/// キャンセルしない。連続呼び出しは直列化し、実行中の clear を共有する。
final class FoodGramImageCache {
  FoodGramImageCache._();

  static const _key = 'foodGramImageCache';
  static final _logger = Logger();
  static Future<void>? _clearInFlight;

  /// ディスク上限。1枚 300〜800KB 想定で、だいたい 60〜160MB 程度。
  static const int maxCachedImages = 200;
  static const Duration stalePeriod = Duration(days: 14);

  static final fcm.CacheManager instance = fcm.CacheManager(
    fcm.Config(
      _key,
      stalePeriod: stalePeriod,
      maxNrOfCacheObjects: maxCachedImages,
    ),
  );

  /// [CachedNetworkImage] / [CachedNetworkImageProvider] の既定キャッシュを差し替える。
  static void installAsDefault() {
    CachedNetworkImageProvider.defaultCacheManager = instance;
  }

  /// 画像用ディスクキャッシュと Flutter のメモリ画像キャッシュを空にする。
  ///
  /// このアプリでは [DefaultCacheManager] を画像（CachedNetworkImage）以外に
  /// 使っていないため、移行前に溜まった旧画像キャッシュも合わせて消す。
  static Future<void> clear() {
    final inFlight = _clearInFlight;
    if (inFlight != null) {
      return inFlight;
    }
    return _clearInFlight = _clearInternal().whenComplete(() {
      _clearInFlight = null;
    });
  }

  static Future<void> _clearInternal() async {
    await Future.wait<void>([
      _emptySafely(instance.emptyCache, 'foodGramImageCache'),
      // 旧 DefaultCacheManager（libCachedImageData）に残った画像のみ対象。
      _emptySafely(
        fcm.DefaultCacheManager().emptyCache,
        'DefaultCacheManager',
      ),
    ]);
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  }

  static Future<void> _emptySafely(
    Future<void> Function() emptyCache,
    String label,
  ) async {
    try {
      await emptyCache();
    } on Object catch (error, stackTrace) {
      _logger.e(
        'Failed to empty $label: $error',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 起動時向け。失敗してもアプリ起動は続行する。
  static Future<void> clearBestEffort() async {
    try {
      await clear();
    } on Object catch (error, stackTrace) {
      _logger.e(
        'Image cache cleanup failed during startup: $error',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
